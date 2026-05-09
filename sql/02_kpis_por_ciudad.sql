# ── QUERY 1: Estadísticas base ────────────────────────────────
# Guarda esto en sql/02_kpis_por_ciudad.sql

q1 = """
SELECT
    localidad,
    anio,
    COUNT(*)                          AS total_manzanas,
    ROUND(AVG(valor_ref_m2))          AS valor_medio,
    ROUND(PERCENTILE_CONT(0.5)
          WITHIN GROUP (ORDER BY valor_ref_m2))
                                      AS valor_mediano,
    ROUND(MIN(valor_ref_m2))          AS valor_minimo,
    ROUND(MAX(valor_ref_m2))          AS valor_maximo,
    ROUND(STDDEV(valor_ref_m2))       AS desviacion_std,
    ROUND(PERCENTILE_CONT(0.25)
          WITHIN GROUP (ORDER BY valor_ref_m2))
                                      AS percentil_25,
    ROUND(PERCENTILE_CONT(0.75)
          WITHIN GROUP (ORDER BY valor_ref_m2))
                                      AS percentil_75
FROM valor_referencia
GROUP BY localidad, anio
ORDER BY localidad, anio;
"""

kpis_base = sql(q1)
print(f"✓ Query 1 ejecutada: {len(kpis_base)} filas")
kpis_base.head(6)


#======================================================================================

# ── QUERY 2: Variación año a año con LAG ─────────────────────
# Esto es lo que distingue un analista que sabe SQL real

q2 = """
WITH base AS (
    SELECT
        localidad,
        anio,
        ROUND(PERCENTILE_CONT(0.5)
              WITHIN GROUP (ORDER BY valor_ref_m2)) AS valor_mediano
    FROM valor_referencia
    GROUP BY localidad, anio
),
con_variacion AS (
    SELECT
        localidad,
        anio,
        valor_mediano,
        LAG(valor_mediano) OVER (
            PARTITION BY localidad
            ORDER BY anio
        )                                           AS valor_anio_anterior,
        LAG(anio) OVER (
            PARTITION BY localidad
            ORDER BY anio
        )                                           AS anio_anterior,
        ROUND(
            (valor_mediano - LAG(valor_mediano) OVER (
                PARTITION BY localidad ORDER BY anio
            )) * 100.0 /
            NULLIF(LAG(valor_mediano) OVER (
                PARTITION BY localidad ORDER BY anio
            ), 0)
        , 2)                                        AS variacion_pct
    FROM base
)
SELECT
    localidad,
    anio,
    anio_anterior,
    valor_mediano,
    valor_anio_anterior,
    variacion_pct,
    CASE
        WHEN variacion_pct >= 20  THEN 'Alta valorización'
        WHEN variacion_pct >= 10  THEN 'Valorización moderada'
        WHEN variacion_pct >= 0   THEN 'Estable'
        WHEN variacion_pct IS NULL THEN 'Año base'
        ELSE                           'Desvalorización'
    END                                             AS categoria
FROM con_variacion
ORDER BY anio, variacion_pct DESC NULLS LAST;
"""

variacion = sql(q2)
print(f"✓ Query 2 ejecutada: {len(variacion)} filas")
variacion[variacion["anio"] == 2024].to_string(index=False)

#======================================================================================

# ── QUERY 3: Ranking de localidades por valor ─────────────────
q3 = """
WITH medianas AS (
    SELECT
        localidad,
        anio,
        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY valor_ref_m2)    AS valor_mediano
    FROM valor_referencia
    GROUP BY localidad, anio
)
SELECT
    anio,
    localidad,
    ROUND(valor_mediano::numeric)                               AS valor_mediano,
    RANK()       OVER (PARTITION BY anio ORDER BY valor_mediano DESC) AS rank_valor,
    DENSE_RANK() OVER (PARTITION BY anio ORDER BY valor_mediano DESC) AS dense_rank,
    NTILE(4)     OVER (PARTITION BY anio ORDER BY valor_mediano DESC) AS cuartil,
    ROUND((valor_mediano * 100.0 /
          SUM(valor_mediano) OVER (PARTITION BY anio))::numeric, 2) AS pct_sobre_total,
    ROUND((valor_mediano * 100.0 /
          AVG(valor_mediano) OVER (PARTITION BY anio))::numeric, 2) AS indice_vs_promedio
FROM medianas
ORDER BY anio, rank_valor;
"""

ranking = sql(q3)
print(f"✓ Query 3 ejecutada: {len(ranking)} filas")
r2024 = ranking[ranking["anio"] == 2024]
print("\nTop 5 — Mayor valor:")
print(r2024.head(5).to_string(index=False))
print("\nBottom 5 — Menor valor:")
print(r2024.tail(5).to_string(index=False))

#======================================================================================


             # ── QUERY 4: Índice de brecha — KPI de desigualdad ───────────
# Mide cuántas veces vale más el suelo en la localidad más cara vs la más barata

q4 = """
WITH medianas AS (
    SELECT
        localidad,
        anio,
        PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY valor_ref_m2)    AS valor_mediano
    FROM valor_referencia
    GROUP BY localidad, anio
),
extremos AS (
    SELECT
        anio,
        MAX(valor_mediano)              AS valor_top,
        MIN(valor_mediano)              AS valor_bottom,
        AVG(valor_mediano)              AS valor_promedio
    FROM medianas
    GROUP BY anio
),
con_nombres AS (
    SELECT
        e.anio,
        e.valor_top,
        e.valor_bottom,
        e.valor_promedio,
        MAX(m.localidad)
            FILTER (WHERE m.valor_mediano = e.valor_top)    AS localidad_top,
        MAX(m.localidad)
            FILTER (WHERE m.valor_mediano = e.valor_bottom) AS localidad_bottom
    FROM extremos e
    JOIN medianas m ON m.anio = e.anio
    GROUP BY e.anio, e.valor_top, e.valor_bottom, e.valor_promedio
)
SELECT
    anio,
    localidad_top,
    ROUND(valor_top::numeric)                               AS valor_zona_premium,
    localidad_bottom,
    ROUND(valor_bottom::numeric)                            AS valor_zona_popular,
    ROUND((valor_top / NULLIF(valor_bottom,0))::numeric, 1) AS indice_brecha,
    ROUND(valor_promedio::numeric)                          AS valor_promedio_ciudad
FROM con_nombres
ORDER BY anio;
"""

brecha = sql(q4)
print("✓ Query 4 ejecutada — Índice de Brecha (KPI #3)")
print("=" * 60)
print(brecha.to_string(index=False))   