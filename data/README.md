"""# 🔀 Datos del Proyecto



Los archivos de datos \*\*no están versionados\*\* en este repositorio

por su tamaño. Esta guía explica cómo descargarlos y organizarlos

para reproducir el análisis.



\---



\## 📂📂Estructura esperada



data/

├── raw/                          # Datos originales sin modificar

│   └── bogota/

│       ├── valor\_referencia\_m\_2024.zip

│       ├── valor\_ref\_2022.zip

│       └── valor\_ref\_m\_2021.zip

│

├── external/                     # Capas geoespaciales

│   └── bogota/

│       ├── valor\_referencia\_m\_2024/   # Shapefile extraído

│       ├── valor\_ref\_2022/            # Shapefile extraído

│       ├── valor\_ref\_m\_2021/          # Shapefile extraído

│       └── localidades\_bogota.gpkg    # Límites de localidades

│

└── processed/                    # Generados por los notebooks

├── bogota\_valor\_ref\_unificado.gpkg

├── bogota\_valor\_localidades.gpkg

├── kpis\_localidad.csv

├── variacion\_interanual.csv

├── indice\_brecha.csv

└── resumen\_ciudad.csv



\---



\## 🔻🔻Fuentes de descarga



\### Valor de referencia por m² — UAECD Bogotá



Descarga manual desde el portal de Datos Abiertos Bogotá:



| Archivo                            | Año  | URL                                                                                           |

|------------------------------------|------|-----------------------------------------------------------------------------------------------|

| valor\_referencia\_m\_2024.zip        | 2024 | \[Descargar](https://datosabiertos.bogota.gov.co/dataset/a0ad3bf4-1e97-4cf9-b853-76558158036f) |

| valor\_ref\_2022.zip                 | 2022 | \[Descargar](https://datosabiertos.bogota.gov.co/dataset/a0ad3bf4-1e97-4cf9-b853-76558158036f) |

| valor\_ref\_m\_2021.zip               | 2021 | \[Descargar](https://datosabiertos.bogota.gov.co/dataset/a0ad3bf4-1e97-4cf9-b853-76558158036f) |



Guarda los ZIPs en `data/raw/bogota/` y ejecuta el notebook

`01\_exploracion\_eda.ipynb` — extrae y procesa automáticamente.



\###🗺️🗺️ Localidades de Bogotá



Descarga manual desde Datos Abiertos Bogotá:



| Archivo                 | Formato    | URL                                              |

|-------------------------|------------|--------------------------------------------------|

| localidades\_bogota.gpkg | GeoPackage | \[Descargar](https://datosabiertos.bogota.gov.co) |



Guarda en `data/external/bogota/`.



\---



\## 📊📊Descripción de los datasets procesados



| Archivo | Descripción | Filas |

|---------------------------------|-----------------------------------------|-------  |

| bogota\_valor\_ref\_unificado.gpkg | Dataset limpio unificado 2021·2022·2024 | 124.245 |

| bogota\_valor\_localidades.gpkg   | Dataset con spatial join a localidades  | 124.245 |

| kpis\_localidad.csv              | KPIs agregados por localidad y año      | 58      |

| variacion\_interanual.csv        | Variación % año a año por localidad     | 58      |

| indice\_brecha.csv               | Índice de brecha territorial por año    | 3       |

| resumen\_ciudad.csv              |  Mediana real de la ciudad por año      | 3       |



\---



\## 📓Notas técnicas



\- Los Shapefiles originales usan \*\*EPSG:4326\*\*

\- Las localidades usan \*\*EPSG:4686\*\* — reproyectadas a 4326 antes del join

\- Los datos procesados se generan ejecutando los notebooks en orden: `01 → 02 → 03 → 04`

\- La base de datos PostgreSQL debe crearse manualmente antes del notebook 03

&#x20; (ver instrucciones en `sql/01\_crear\_esquema.sql`)

"""





