-- ============================================================
-- 01_crear_esquema.sql
-- Esquema relacional del proyecto mercado inmobiliario Bogotá
-- Autor: [Tu nombre]
-- Fecha: 2024
-- ============================================================

-- ── Tabla de localidades ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS localidades (
    cod_localidad   VARCHAR(5)    PRIMARY KEY,
    localidad       VARCHAR(50)   NOT NULL,
    area_km2        NUMERIC(10,4),
    total_personas  INTEGER,
    total_hombres   INTEGER,
    total_mujeres   INTEGER,
    total_viviendas INTEGER
);

-- ── Tabla principal de valores de referencia ──────────────────
CREATE TABLE IF NOT EXISTS valor_referencia (
    id              SERIAL        PRIMARY KEY,
    manzana_cod     VARCHAR(20)   NOT NULL,
    cod_localidad   VARCHAR(5)    REFERENCES localidades(cod_localidad),
    localidad       VARCHAR(50),
    valor_ref_m2    NUMERIC(15,2) NOT NULL,
    anio            SMALLINT      NOT NULL,
    CONSTRAINT chk_valor_positivo CHECK (valor_ref_m2 > 0),
    CONSTRAINT chk_anio           CHECK (anio BETWEEN 2015 AND 2030)
);

-- ── Índices para performance ──────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_vr_localidad ON valor_referencia(localidad);
CREATE INDEX IF NOT EXISTS idx_vr_anio      ON valor_referencia(anio);
CREATE INDEX IF NOT EXISTS idx_vr_manzana   ON valor_referencia(manzana_cod);

-- ── Tabla de KPIs calculados (para Power BI) ──────────────────
CREATE TABLE IF NOT EXISTS kpis_localidad (
    id              SERIAL        PRIMARY KEY,
    localidad       VARCHAR(50)   NOT NULL,
    anio            SMALLINT      NOT NULL,
    valor_mediano   NUMERIC(15,2),
    valor_medio     NUMERIC(15,2),
    valor_minimo    NUMERIC(15,2),
    valor_maximo    NUMERIC(15,2),
    total_manzanas  INTEGER,
    CONSTRAINT uq_kpi UNIQUE (localidad, anio)
);

COMMENT ON TABLE valor_referencia IS
    'Valor de referencia comercial por m² por manzana catastral — Bogotá D.C.';
COMMENT ON TABLE kpis_localidad IS
    'KPIs agregados por localidad y año — alimenta el dashboard Power BI';