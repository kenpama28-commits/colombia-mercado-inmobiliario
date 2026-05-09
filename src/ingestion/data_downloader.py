"""
data_downloader.py
------------------
Descarga automatizada de fuentes tabulares desde la API de Datos Abiertos Colombia.
Genera logs de cada descarga y un archivo metadata.json con hashes de integridad.

Uso:
    python src/ingestion/data_downloader.py
"""

import os
import json
import hashlib
import logging
import requests
import pandas as pd
import yaml
from datetime import datetime
from pathlib import Path
from time import sleep

# ── Configuración de logging ──────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.FileHandler("logs/descarga.log", encoding="utf-8"),
        logging.StreamHandler()  # también imprime en consola
    ]
)
log = logging.getLogger(__name__)


# ── Funciones utilitarias ─────────────────────────────────────────────────────

def cargar_config(ruta: str = "src/ingestion/config.yaml") -> dict:
    """Carga el archivo de configuración YAML."""
    with open(ruta, "r", encoding="utf-8") as f:
        return yaml.safe_load(f)


def calcular_hash(ruta_archivo: str) -> str:
    """Calcula el hash MD5 de un archivo para verificar integridad."""
    hash_md5 = hashlib.md5()
    with open(ruta_archivo, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


def guardar_metadata(metadata: dict, ruta: str = "data/raw/metadata.json"):
    """Guarda o actualiza el archivo de metadata de descargas."""
    # Si ya existe, carga y actualiza — no sobreescribe todo
    if Path(ruta).exists():
        with open(ruta, "r", encoding="utf-8") as f:
            existente = json.load(f)
        existente.update(metadata)
        metadata = existente

    with open(ruta, "w", encoding="utf-8") as f:
        json.dump(metadata, f, ensure_ascii=False, indent=2)


# ── Descarga desde Socrata API (datos.gov.co) ─────────────────────────────────

def descargar_socrata(nombre: str, url: str, destino: str,
                      limite: int = 5_000,
                      filtro_where: str = "") -> bool:
    """
    Descarga datos desde Socrata con escritura por chunks.
    Nunca acumula todo en RAM — escribe cada página directo al CSV.
    """
    log.info(f"Iniciando descarga: {nombre}")
    Path(destino).parent.mkdir(parents=True, exist_ok=True)

    total_registros = 0
    offset = 0
    primer_chunk = True

    try:
        while True:
            params = {
                "$limit": limite,
                "$offset": offset,
                "$order": ":id"
            }

            # Filtro opcional por ciudad
            if filtro_where:
                params["$where"] = filtro_where

            response = requests.get(url, params=params, timeout=30)
            response.raise_for_status()

            datos_pagina = response.json()

            if not datos_pagina:
                break

            df_chunk = pd.DataFrame(datos_pagina)

            # ── Escritura incremental: no acumula en RAM ──────────────
            modo = "w" if primer_chunk else "a"        # primera vez escribe header
            header = primer_chunk                       # solo escribe header una vez
            df_chunk.to_csv(destino, mode=modo,
                            header=header, index=False, encoding="utf-8")
            primer_chunk = False
            # ─────────────────────────────────────────────────────────

            total_registros += len(df_chunk)
            log.info(f"  → Chunk guardado: {total_registros:,} registros acumulados")

            if len(datos_pagina) < limite:
                break

            offset += limite
            sleep(0.3)

        log.info(f"  ✓ Completo: {destino} | {total_registros:,} registros totales")

        guardar_metadata({
            nombre: {
                "url": url,
                "destino": destino,
                "filas": total_registros,
                "hash_md5": calcular_hash(destino),
                "descargado_el": datetime.now().isoformat(),
                "filtro_aplicado": filtro_where or "ninguno",
                "estado": "exitoso"
            }
        })
        return True

    except requests.exceptions.HTTPError as e:
        log.error(f"  ✗ Error HTTP en {nombre}: {e}")
    except requests.exceptions.ConnectionError:
        log.error(f"  ✗ Sin conexión al descargar {nombre}")
    except Exception as e:
        log.error(f"  ✗ Error inesperado en {nombre}: {e}")

    return False


# ── Script principal ──────────────────────────────────────────────────────────

def main():
    log.info("=" * 60)
    log.info("INICIO DE PIPELINE DE DESCARGA DE DATOS")
    log.info(f"Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    log.info("=" * 60)

    config = cargar_config()
    fuentes = config["fuentes_tabulares"]

    resultados = {}

    for clave, info in fuentes.items():
        exito = descargar_socrata(
            nombre=info["nombre"],
            url=info["url"],
            destino=info["destino"],
            filtro_where=info.get("filtro_where", "")
        )
        resultados[clave] = "✓ OK" if exito else "✗ FALLO"
        sleep(1)  # pausa entre datasets

    # Resumen final en consola y log
    log.info("\n" + "=" * 60)
    log.info("RESUMEN DE DESCARGA")
    log.info("=" * 60)
    for clave, estado in resultados.items():
        log.info(f"  {estado}  {clave}")

    exitosos = sum(1 for v in resultados.values() if "OK" in v)
    log.info(f"\nTotal: {exitosos}/{len(resultados)} datasets descargados correctamente.")
    log.info("Metadata guardada en: data/raw/metadata.json")


if __name__ == "__main__":
    main()