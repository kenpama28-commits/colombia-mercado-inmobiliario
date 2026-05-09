\# 🏙️ Análisis del Mercado Inmobiliario Urbano — Bogotá D.C.



!\[Python](https://img.shields.io/badge/Python-3.11-blue?logo=python)

!\[PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-blue?logo=postgresql)

!\[Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?logo=powerbi)

!\[GeoPandas](https://img.shields.io/badge/GeoPandas-Spatial%20Analysis-green)

!\[Status](https://img.shields.io/badge/Status-Completado-brightgreen)



\## 📊 Dashboard Interactivo



🔗 \*\*\[Ver dashboard en Power BI](https://app.powerbi.com/groups/me/reports/3f498484-2f57-4908-bce3-e35b21d79498?ctid=577fc1d8-0922-458e-87bf-ec4f455eb600\&pbi\_source=linkShare)\*\*



!\[Resumen Ejecutivo](dashboard/screenshots/screenshot\_01\_resumen\_ejecutivo.png)



\---



\## 📋 Descripción



Análisis end-to-end del valor comercial del suelo urbano en Bogotá D.C.

utilizando datos oficiales del catastro distrital (UAECD) para los años

2021, 2022 y 2024. El proyecto combina análisis geoespacial, ingeniería

de datos y visualización ejecutiva para identificar patrones de

valorización territorial y desigualdad en el mercado inmobiliario.



> \*\*Pregunta de negocio:\*\* ¿Qué factores territoriales determinan el valor

> del suelo urbano en Bogotá y cómo ha evolucionado la brecha entre zonas

> premium y populares entre 2021 y 2024?



\---



\## 🎯 Hallazgos Principales



| KPI                           | Valor                 | Interpretación                |

|-------------------------------|-----------------------|-------------------------------|

| Valorización ciudad 2021→2024 | \*\*+13.2%\*\*            | Reactivación post-pandemia    |

| Mayor valorización            | \*\*Candelaria +35.0%\*\* | Convergencia territorial      |

| Única desvalorización         | \*\*Chapinero -14.8%\*\*  | Recomposición mercado premium |

| Índice de brecha 2021         | \*\*7.5x\*\*              | Chapinero vs Usme             |

| Índice de brecha 2024         | \*\*5.7x\*\*              | Reducción de la desigualdad   |

| Valor mediano ciudad 2024     | \*\*$2.150.000/m²\*\*     | Referencia comercial          |

| Manzanas analizadas           | \*\*124.245\*\*           | Cobertura total Bogotá        |



\---



\## 🗺️ Visualizaciones



| | |

|---|---|

| !\[Análisis Localidad](dashboard/screenshots/screenshot\_02\_analisis\_localidad.png) | !\[Brecha Territorial](dashboard/screenshots/screenshot\_03\_brecha\_territorial.png) |

| \*\*Análisis por Localidad\*\* — comparativo 3 años | \*\*Brecha Territorial\*\* — desigualdad del suelo |



!\[Mapa Valorización](dashboard/screenshots/screenshot\_04\_mapa\_valorizacion.png)

\*Mapa interactivo de valorización 2021→2024 por localidad\*



\---



\## 🛠️ Stack Tecnológico



| Categoría            | Herramientas                         |

|----------------------|--------------------------------------|

| Lenguaje             | Python 3.11                          |

| Base de datos        | PostgreSQL 18 + PostGIS              |

| Análisis geoespacial | GeoPandas · PyOGRIO · Folium         |

| Visualización        | Power BI · Matplotlib · Seaborn      |

| Ingeniería de datos  | SQLAlchemy · Requests · YAML         |

| SQL avanzado         | CTEs · Window Functions · PERCENTILE |

| Control de versión   | Git · GitHub                         |



\---



\## 📁 Estructura del Proyecto



colombia-mercado-inmobiliario/

│

├── 📄 README.md

├── 📄 requirements.txt

│

├── 📁 src/

│   ├── 📁 ingestion/

│   │   ├── config.yaml          # URLs y parámetros centralizados

│   │   ├── data\_downloader.py   # Descarga con paginación y logging

│   │   └── geo\_downloader.py    # Capas geoespaciales

│   ├── etl\_pipeline.py          # Funciones de limpieza reutilizables

│   ├── kpi\_calculator.py        # Cálculo de KPIs de negocio

│   └── geo\_utils.py             # Utilidades geoespaciales

│

├── 📁 notebooks/

│   ├── 01\_exploracion\_eda.ipynb         # EDA y calidad de datos

│   ├── 02\_limpieza\_transformacion.ipynb # ETL y spatial join

│   ├── 03\_analisis\_sql\_kpis.ipynb       # PostgreSQL y KPIs

│   ├── 04\_visualizaciones\_mapas.ipynb   # Folium y matplotlib

│   └── 05\_informe\_final.ipynb           # Síntesis ejecutiva

│

├── 📁 sql/

│   ├── 01\_crear\_esquema.sql      # Esquema relacional con constraints

│   ├── 02\_kpis\_por\_ciudad.sql    # Estadísticas base

│   ├── 03\_analisis\_estrato.sql   # Variación interanual con LAG

│   └── 04\_window\_functions.sql   # RANK · NTILE · Índice de brecha

│

├── 📁 dashboard/

│   ├── mercado\_inmobiliario.pbix

│   └── 📁 screenshots/

│

└── 📁 reports/

└── 📁 figures/ 



\---



\## 🔄 Metodología



1.INGESTA          Descarga automatizada desde UAECD Bogotá

Pipeline con paginación, logging y hash MD5

↓

2\.EXPLORACIÓN      EDA: 127K registros · 3 años · 20 localidades

Detección de nulos, ceros y geometrías inválidas

↓

3\.TRANSFORMACIÓN   Estandarización de esquema entre 3 datasets

Spatial join manzanas → localidades

Deduplicación con DISTINCT ON en PostgreSQL

↓

4\.ANÁLISIS SQL     Window functions: LAG · RANK · PERCENTILE\_CONT

CTEs anidados · Índice de brecha territorial

↓

5\.VISUALIZACIÓN    5 gráficas · 3 mapas Folium · Dashboard Power BI

3 páginas ejecutivas · 4 medidas DAX





\---



\## ⚙️ Reproducibilidad



```bash

\# 1. Clonar el repositorio

git clone https://github.com/kenpama28-commits/colombia-mercado-inmobiliario.git

cd colombia-mercado-inmobiliario



\# 2. Crear entorno virtual

python -m venv venv

venv\\\\Scripts\\\\activate

pip install -r requirements.txt



\# 3. Descargar datos geoespaciales

python src/ingestion/geo\_downloader.py



\# 4. Configurar PostgreSQL

\# Crear base: mercado\_inmobiliario

\# Ejecutar: sql/01\_crear\_esquema.sql



\# 5. Ejecutar notebooks en orden

\# 01 → 02 → 03 → 04

```



\---



\## 📂 Fuentes de Datos



| Dataset                  | Fuente                        | Registros |

|--------------------------|-------------------------------|-----------|

| Valor referencia m² 2024 | UAECD — Datos Abiertos Bogotá | 42.036    |

| Valor referencia m² 2022 | UAECD — Datos Abiertos Bogotá | 41.584    |

| Valor referencia m² 2021 | UAECD — Datos Abiertos Bogotá | 43.958    |

| Localidades Bogotá       | Datos Abiertos Bogotá         | 20        |



> Los datos no están versionados por su tamaño.

> Ver `data/README.md` para instrucciones de descarga.



\---



\## 👤 Autor



\*\*Kevin Palacio Martinez\*\*


\[!\[GitHub](https://img.shields.io/badge/GitHub-Portafolio-black?logo=github)](https://github.com/kenpama28-commits)



\---



\*Datos fuente: UAECD Catastro Distrital — Datos Abiertos Bogotá D.C.\*

"""





