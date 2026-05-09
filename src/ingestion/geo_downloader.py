"""
geo_downloader.py
-----------------
Descarga automatizada de capas geoespaciales para el análisis.
Guarda GeoJSON en data/external/ listos para usar con geopandas y Folium.

Uso:
    python src/ingestion/geo_downloader.py
"""

import logging
import requests
import yaml
from pathlib import Path
from time import sleep
from datetime import datetime

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.FileHandler("logs/descarga.log", encoding="utf-8"),
        logging.StreamHandler()
    ]
)
log = logging.getLogger(__name__)


def descargar_geojson(nombre: str, url: str, destino: str) -> bool:
    """Descarga un archivo GeoJSON y lo guarda localmente."""
    log.info(f"Descargando capa geoespacial: {nombre}")
    Path(destino).parent.mkdir(parents=True, exist_ok=True)

    try:
        response = requests.get(url, timeout=60)
        response.raise_for_status()

        with open(destino, "w", encoding="utf-8") as f:
            f.write(response.text)

        size_kb = Path(destino).stat().st_size / 1024
        log.info(f"  ✓ Guardado: {destino} | {size_kb:.1f} KB")
        return True

    except Exception as e:
        log.error(f"  ✗ Error descargando {nombre}: {e}")
        return False


def main():
    with open("src/ingestion/config.yaml", "r", encoding="utf-8") as f:
        config = yaml.safe_load(f)

    fuentes_geo = config["fuentes_geoespaciales"]

    log.info("INICIO DESCARGA DE CAPAS GEOESPACIALES")

    for clave, info in fuentes_geo.items():
        descargar_geojson(
            nombre=info["nombre"],
            url=info["url"],
            destino=info["destino"]
        )
        sleep(1)


if __name__ == "__main__":
    main()