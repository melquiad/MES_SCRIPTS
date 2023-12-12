-- Tables d'import des données

CREATE TABLE public.aurel91 (
    xl2 INT4,
    yl2 INT4,
    annee_deb INT2,
    annee_fin INT2,
    mois INT2,
    rmoy NUMERIC,
    nbjrr NUMERIC,
    tnmoy NUMERIC,
    txmoy NUMERIC,
    nbjgel NUMERIC
);

--DROP TABLE public.aurel91;

-- import des données Aurehly (3 périodes)
\copy public.aurel91 FROM '/home/lhaugomat/Documents/MES_SCRIPTS/aurelhy/Aurelhy-1991-2020.csv' WITH CSV DELIMITER ';' QUOTE '"' NULL AS ''

/*
SELECT 61 AS num, max(length((regexp_split_to_array(txmoy::TEXT, '\.'))[1])), max(length((regexp_split_to_array(txmoy::TEXT, '\.'))[2]))
FROM aurel61
UNION
SELECT 71 AS num, max(length((regexp_split_to_array(txmoy::TEXT, '\.'))[1])), max(length((regexp_split_to_array(txmoy::TEXT, '\.'))[2]))
FROM aurel71
UNION
SELECT 81 AS num, max(length((regexp_split_to_array(txmoy::TEXT, '\.'))[1])), max(length((regexp_split_to_array(txmoy::TEXT, '\.'))[2]))
FROM aurel81
ORDER BY num;
*/

-- Création de la table des données mensuelles
CREATE TABLE carto_exo.aurelhy_mois (
    id INT8 PRIMARY KEY,
    annee_deb INT2,
    annee_fin INT2,
    mois INT2,
    rmoy NUMERIC(5, 1),
    nbjrr NUMERIC(4, 1),
    tnmoy NUMERIC(4, 1),
    txmoy NUMERIC(4, 1),
    nbjgel NUMERIC(4, 1),
    geom GEOMETRY('Point')
);

ALTER TABLE carto_exo.aurelhy_mois
    OWNER TO exploitation_admin;

SELECT UpdateGeometrySRID('carto_exo', 'aurelhy_mois', 'geom', 931007);
SELECT Populate_Geometry_Columns('carto_exo.aurelhy_mois'::regclass);

-- Création de la table des données annuelles
CREATE TABLE carto_exo.aurelhy_an (
    id INT8 PRIMARY KEY,
    annee_deb INT2,
    annee_fin INT2,
    rmoy NUMERIC(5, 1),
    nbjrr NUMERIC(4, 1),
    tnmoy NUMERIC(4, 1),
    txmoy NUMERIC(4, 1),
    nbjgel NUMERIC(4, 1),
    geom GEOMETRY('Point')
);

ALTER TABLE carto_exo.aurelhy_an
    OWNER TO exploitation_admin;

SELECT UpdateGeometrySRID('carto_exo', 'aurelhy_an', 'geom', 931007);
SELECT Populate_Geometry_Columns('carto_exo.aurelhy_an'::regclass);

-- Remplissage de la table des données mensuelles
CREATE TABLE aurel_full AS 
SELECT id, annee_deb, annee_fin, mois, rmoy, nbjrr, tnmoy, txmoy, nbjgel, ST_Transform(ST_SetSRID(ST_MakePoint(xl2, yl2), 932006), 931007) AS geom
FROM aurel71
WHERE mois != 13
UNION
SELECT id, annee_deb, annee_fin, mois, rmoy, nbjrr, tnmoy, txmoy, nbjgel, ST_Transform(ST_SetSRID(ST_MakePoint(xl2, yl2), 932006), 931007) AS geom
FROM aurel81
WHERE mois != 13
UNION
SELECT id, annee_deb, annee_fin, mois, rmoy, NULL AS nbjrr, tnmoy, txmoy, NULL AS nbjgel, ST_Transform(ST_SetSRID(ST_MakePoint(xl2, yl2), 932006), 931007) AS geom
FROM aurel61
WHERE mois != 13;

INSERT INTO carto_exo.aurelhy_mois (id, annee_deb, annee_fin, mois, rmoy, nbjrr, tnmoy, txmoy, nbjgel, geom)
SELECT ROW_NUMBER() OVER () AS id, annee_deb, annee_fin, mois, rmoy, nbjrr, tnmoy, txmoy, nbjgel, geom
FROM aurel_full
ORDER BY annee_deb, id;

CREATE INDEX aurelhy_mois_geom_idx ON carto_exo.aurelhy_mois USING gist(geom);

-- Remplissage de la table des données annuelles
TRUNCATE TABLE aurel_full;

INSERT INTO aurel_full  
SELECT id, annee_deb, annee_fin, mois, rmoy, nbjrr, tnmoy, txmoy, nbjgel, ST_Transform(ST_SetSRID(ST_MakePoint(xl2, yl2), 932006), 931007) AS geom
FROM aurel71
WHERE mois = 13
UNION
SELECT id, annee_deb, annee_fin, mois, rmoy, nbjrr, tnmoy, txmoy, nbjgel, ST_Transform(ST_SetSRID(ST_MakePoint(xl2, yl2), 932006), 931007) AS geom
FROM aurel81
WHERE mois = 13
UNION
SELECT id, annee_deb, annee_fin, mois, rmoy, NULL AS nbjrr, tnmoy, txmoy, NULL AS nbjgel, ST_Transform(ST_SetSRID(ST_MakePoint(xl2, yl2), 932006), 931007) AS geom
FROM aurel61
WHERE mois = 13;

INSERT INTO carto_exo.aurelhy_an (id, annee_deb, annee_fin, rmoy, nbjrr, tnmoy, txmoy, nbjgel, geom)
SELECT ROW_NUMBER() OVER () AS id, annee_deb, annee_fin, rmoy, nbjrr, tnmoy, txmoy, nbjgel, geom
FROM aurel_full
ORDER BY annee_deb, id;

CREATE INDEX aurelhy_an_geom_idx ON carto_exo.aurelhy_an USING gist(geom);

DROP TABLE aurel61;
DROP TABLE aurel71;
DROP TABLE aurel81;
DROP TABLE aurel_full;

VACUUM ANALYZE carto_exo.aurelhy_mois;
VACUUM ANALYZE carto_exo.aurelhy_an;

-- ajout des droits
GRANT ALL ON TABLE carto_exo.aurelhy_mois TO exploitation_admin;
GRANT ALL ON TABLE carto_exo.aurelhy_an TO exploitation_admin;
GRANT SELECT ON TABLE carto_exo.aurelhy_mois TO carto_datareader;
GRANT SELECT ON TABLE carto_exo.aurelhy_an TO carto_datareader;
GRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON TABLE carto_exo.aurelhy_mois TO carto_datawriter;
GRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON TABLE carto_exo.aurelhy_an TO carto_datawriter;

-- ajout d'index sur les années de début, pour accélérer les recherches par période
CREATE INDEX aurelhy_mois_annee_deb_idx ON carto_exo.aurelhy_mois (annee_deb);
CREATE INDEX aurelhy_an_annee_deb_idx ON carto_exo.aurelhy_an (annee_deb);

-- création des tables croisant points d'inventaire et mailles Aurelhy
CREATE TABLE inv_exp_nm.point_aurelhy_mois (
    npp CHAR(16) PRIMARY KEY,
    id_61 INT8,
    id_71 INT8,
    id_81 INT8
);

ALTER TABLE inv_exp_nm.point_aurelhy_mois
    OWNER TO exploitation_admin;

CREATE TABLE inv_exp_nm.point_aurelhy_an (
    npp CHAR(16) PRIMARY KEY,
    id_61 INT8,
    id_71 INT8,
    id_81 INT8
);

ALTER TABLE inv_exp_nm.point_aurelhy_an
    OWNER TO exploitation_admin;

-- remplissage des tables croisant points d'inventaire et mailles Aurelhy
DROP VIEW inv_exp_nm.e1coord_coord_l2_l93;

SELECT UpdateGeometrySRID(f_table_schema::VARCHAR, f_table_name::VARCHAR, f_geometry_column::VARCHAR, 931007) 
FROM geometry_columns
WHERE f_table_schema = 'inv_exp_nm' AND f_table_name = 'e1coord';

CREATE OR REPLACE VIEW inv_exp_nm.e1coord_coord_l2_l93
AS SELECT e1coord.npp,
        round(st_x(st_transform(e1coord.geom, 932006))::numeric, 0) AS xl2,
        round(st_y(st_transform(e1coord.geom, 932006))::numeric, 0) AS yl2,
        round(st_x(e1coord.geom)::numeric, 0) AS xl93,
        round(st_y(e1coord.geom)::numeric, 0) AS yl93
   FROM inv_exp_nm.e1coord;

ALTER VIEW inv_exp_nm.e1coord_coord_l2_l93 OWNER TO exploitation_admin;
GRANT ALL ON TABLE inv_exp_nm.e1coord_coord_l2_l93 TO exploitation_admin;
GRANT SELECT ON TABLE inv_exp_nm.e1coord_coord_l2_l93 TO coord_datareader;

INSERT INTO inv_exp_nm.point_aurelhy_mois (npp, id_61)
SELECT c.npp, pam.id AS id_61
FROM inv_exp_nm.e1coord c
JOIN LATERAL (
    SELECT id
    FROM carto_exo.aurelhy_mois am
    WHERE am.annee_deb = 1961
    ORDER BY c.geom <-> am.geom
    LIMIT 1
) pam ON TRUE;

WITH prox71 AS (
    SELECT c.npp, pam.id AS id_71
    FROM inv_exp_nm.e1coord c
    JOIN LATERAL (
        SELECT id
        FROM carto_exo.aurelhy_mois am
        WHERE am.annee_deb = 1971
        ORDER BY c.geom <-> am.geom
        LIMIT 1
    ) pam ON TRUE
)
UPDATE inv_exp_nm.point_aurelhy_mois a
SET id_71 = p.id_71
FROM prox71 p
WHERE a.npp = p.npp;

WITH prox81 AS (
    SELECT c.npp, pam.id AS id_81
    FROM inv_exp_nm.e1coord c
    JOIN LATERAL (
        SELECT id
        FROM carto_exo.aurelhy_mois am
        WHERE am.annee_deb = 1981
        ORDER BY c.geom <-> am.geom
        LIMIT 1
    ) pam ON TRUE
)
UPDATE inv_exp_nm.point_aurelhy_mois a
SET id_81 = p.id_81
FROM prox81 p
WHERE a.npp = p.npp;

INSERT INTO inv_exp_nm.point_aurelhy_an (npp, id_61)
SELECT c.npp, pan.id AS id_61
FROM inv_exp_nm.e1coord c
JOIN LATERAL (
    SELECT id
    FROM carto_exo.aurelhy_an an
    WHERE an.annee_deb = 1961
    ORDER BY c.geom <-> an.geom
    LIMIT 1
) pan ON TRUE;

WITH prox71 AS (
    SELECT c.npp, pan.id AS id_71
    FROM inv_exp_nm.e1coord c
    JOIN LATERAL (
        SELECT id
        FROM carto_exo.aurelhy_mois an
        WHERE an.annee_deb = 1971
        ORDER BY c.geom <-> an.geom
        LIMIT 1
    ) pan ON TRUE
)
UPDATE inv_exp_nm.point_aurelhy_mois a
SET id_71 = p.id_71
FROM prox71 p
WHERE a.npp = p.npp;

WITH prox81 AS (
    SELECT c.npp, pan.id AS id_81
    FROM inv_exp_nm.e1coord c
    JOIN LATERAL (
        SELECT id
        FROM carto_exo.aurelhy_mois an
        WHERE an.annee_deb = 1981
        ORDER BY c.geom <-> an.geom
        LIMIT 1
    ) pan ON TRUE
)
UPDATE inv_exp_nm.point_aurelhy_mois a
SET id_81 = p.id_81
FROM prox81 p
WHERE a.npp = p.npp;

-- droits sur les tables croisant points d'inventaire et mailles Aurelhy
GRANT ALL ON TABLE inv_exp_nm.point_aurelhy_mois TO exploitation_admin;
GRANT ALL ON TABLE inv_exp_nm.point_aurelhy_mois TO exploitation_admin;
GRANT SELECT ON TABLE inv_exp_nm.point_aurelhy_mois TO exploitation_datareader;
GRANT SELECT ON TABLE inv_exp_nm.point_aurelhy_mois TO exploitation_datareader;
GRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON TABLE inv_exp_nm.point_aurelhy_mois TO exploitation_datawriter;
GRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON TABLE inv_exp_nm.point_aurelhy_mois TO exploitation_datawriter;



