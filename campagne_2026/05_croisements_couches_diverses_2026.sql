-- on commence par importer les nouvelles versions des couches de l'INPN en base de production
-- voir scripts ../Production/SIG/*_ajout_couches_INPN_*.sql

CREATE TEMPORARY TABLE pts2026 AS
SELECT v.id_ech, v.id_point, v.npp, v.nph
, CASE pl.echelon_init
	WHEN '01' THEN 'DIRSO'
	WHEN '02' THEN 'DIRNO'
	WHEN '04' THEN 'DIRCE'
	WHEN '05' THEN 'DIRSE'
	WHEN '06' THEN 'DIRNE'
  END AS dir
, 'nouveau' AS type_point
, p.geom
FROM v_liste_points_lt1 v
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
WHERE v.annee = 2026
UNION ALL
SELECT v.id_ech, v.id_point, v.npp, v.nph
, CASE pl.echelon_init
    WHEN '01' THEN 'DIRSO'
    WHEN '02' THEN 'DIRNO'
    WHEN '04' THEN 'DIRCE'
    WHEN '05' THEN 'DIRSE'
    WHEN '06' THEN 'DIRNE'
  END AS dir
, 'visite2' AS type_point
, p.geom
FROM v_liste_points_lt2 v
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
WHERE v.annee = 2026
UNION ALL
SELECT v.id_ech, v.id_point, v.nppr, v.nph
, CASE pl.echelon_init
    WHEN '01' THEN 'DIRSO'
    WHEN '02' THEN 'DIRNO'
    WHEN '04' THEN 'DIRCE'
    WHEN '05' THEN 'DIRSE'
    WHEN '06' THEN 'DIRNE'
  END AS dir
, 'nouveau' AS type_point
, p.geom
FROM v_liste_points_lt1_pi2 v
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
WHERE v.annee = 2026
ORDER BY type_point, id_point;

SELECT UpdateGeometrySRID(f_table_schema::VARCHAR, f_table_name::VARCHAR, f_geometry_column::VARCHAR, 2154) 
FROM geometry_columns
WHERE f_table_name = 'pts2026';

ALTER TABLE pts2026 ADD CONSTRAINT pts2026_pkey PRIMARY KEY (id_ech, id_point);

CREATE INDEX pts2026_geom_idx ON pts2026 USING GIST (geom);

ANALYZE pts2026;
--TABLE pts2026;

-- réalisation du croisement entre couches et points
-- réserves biologiques intégrales et dirigées
SELECT p.dir, p.type_point, p.npp, p.nph, p.id_ech, p.id_point, r.code_r_enp
, r.nom_site, CASE WHEN r.code_r_enp = 'I' THEN 'integrale' ELSE 'dirigee' END AS type_reserve
FROM pts2026 p
INNER JOIN sig_inpn.rb r ON p.geom && r.geom AND ST_Intersects(p.geom, r.geom)
ORDER BY p.dir, p.type_point, p.nph;  --> 16 points en 2026

UPDATE point_ech  
SET rbi = '1'
WHERE (id_ech, id_point) IN (
	SELECT id_ech, id_point
	FROM pts2026 p
	INNER JOIN sig_inpn.rb r ON p.geom && r.geom AND ST_Intersects(p.geom, r.geom)
	WHERE r.code_r_enp = 'I' --> 6 points en RBI en 2026
);

-- ajout de l'historisation de la couche des RBI

--INSERT INTO inv_prod_new.version_couche (id_couche, num_version, nom_version)
--VALUES (10, 5, 'Version 2021'); -- pas de nouvelle version intégrée, donc pas à jouer

INSERT INTO inv_prod_new.croisement_carto (id_ech, id_couche, num_version, date_croisement)
SELECT id_ech, 10, 5, date_tirage
FROM inv_prod_new.echantillon e
INNER JOIN inv_prod_new.campagne c USING (id_campagne)
WHERE type_ue = 'P'
AND type_ech = 'IFN'
AND nom_ech LIKE 'FR%'
AND phase_stat = 2
AND millesime = 2026
ORDER BY id_ech;


-- réserves intégrales de parcs nationaux
SELECT p.dir, p.type_point, p.npp, p.nph
, r.nom_site AS nom, 'integrale PN' AS type_reserve
FROM pts2026 p
INNER JOIN sig_inpn.ripn r ON p.geom && r.geom AND ST_Intersects(p.geom, r.geom)
ORDER BY p.dir, p.type_point, p.nph; --> 2 points en 2026

-- terrains militaires
SELECT p.dir, p.type_point, p.npp, p.nph
, COALESCE(r.nom, r.nature, '???') AS camp
FROM pts2026 p
INNER JOIN sig_inventaire.terrains_militaires r ON p.geom && r.geom AND ST_Intersects(p.geom, r.geom)
ORDER BY dir, type_point, npp; --> 86 points en 2026

-- arrêtés de protection biotope
SELECT p.dir, p.type_point, p.npp, p.nph
, r.nom_site
FROM pts2026 p
INNER JOIN sig_inpn.apb r ON p.geom && r.geom AND ST_Intersects(p.geom, r.geom)
ORDER BY dir, type_point, npp; --> 75 points en 2026

-- parcs nationaux
SELECT p.dir, p.type_point, p.npp, p.nph, r.nom_site AS nom
FROM pts2026 p
INNER JOIN sig_inpn.pn r ON p.geom && r.geom AND ST_Intersects(p.geom, r.geom)
ORDER BY dir, type_point, npp; --> 333 points en 2026

-- parcs naturels régionaux
SELECT p.dir, p.type_point, p.npp, p.nph, r.nom_site AS nom
FROM pts2026 p
INNER JOIN sig_inpn.pnr r ON p.geom && r.geom AND ST_Intersects(p.geom, r.geom)
ORDER BY dir, type_point, npp; --> 3203 points en 2026

-- autres réserves naturelles
CREATE TEMPORARY TABLE restes_sig AS 
SELECT id_mnhn, nom_site, 'réserve biosphère' AS type_res, geom
FROM sig_inpn.bios
UNION ALL
SELECT id_mnhn, nom_site AS nom, 'réserve naturelle nationale' AS type_res, geom
FROM sig_inpn.rnn
UNION ALL
SELECT id_mnhn, nom_site AS nom, 'réserve naturelle régionale' AS type_res, geom
FROM sig_inpn.rnr
UNION ALL
SELECT id_mnhn, nom_site, 'réserve naturelle de Corse' AS type_res, geom
FROM sig_inpn.rnc
UNION ALL
SELECT id_mnhn, nom_site, 'réserve nationale de chasse et faune sauvage' AS type_res, geom
FROM sig_inpn.rncfs; --> 391 points

SELECT UpdateGeometrySRID(f_table_schema::VARCHAR, f_table_name::VARCHAR, f_geometry_column::VARCHAR, 2154) 
FROM geometry_columns
WHERE f_table_name = 'restes_sig';

CREATE INDEX restes_sig_geom_idx ON restes_sig USING GIST (geom);

ANALYZE restes_sig;

SELECT p.dir, p.type_point, p.npp, p.nph, r.type_res, r.nom_site
FROM pts2026 p
INNER JOIN restes_sig r ON p.geom && r.geom AND ST_Intersects(p.geom, r.geom)
ORDER BY dir, type_point, npp; --> 1340 points en 2026

DROP TABLE restes_sig;

SET enable_nestloop = FALSE;
-- Probabilité de présence du hêtre
CREATE TEMPORARY TABLE pts AS 
SELECT id_ech, id_point, npp, geom --> en base locale geom en 2154
FROM point_ech pe
INNER JOIN echantillon e USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl USING (id_ech, id_point)
INNER JOIN campagne c USING (id_campagne)
WHERE type_ue = 'P'
AND type_ech = 'IFN'
AND phase_stat = 2
AND millesime = 2026;

--SELECT UpdateGeometrySRID(f_table_schema::VARCHAR, f_table_name::VARCHAR, f_geometry_column::VARCHAR, 2154) 
--FROM geometry_columns
--WHERE f_table_name = 'pts'
--AND f_table_schema LIKE 'pg_temp%';

ALTER TABLE pts ADD CONSTRAINT pts_pk PRIMARY KEY (id_ech, id_point);
CREATE INDEX pts_geom_idx ON pts USING gist(geom);
ANALYZE pts;

SELECT ST_SRID(rast) As srid FROM sig_inventaire.prob_hetre WHERE rid = 1;
--SELECT UpdateRasterSRID('sig_inventaire', 'prob_hetre', 'rast', 27572); --> transformation nécessaire en base locale

CREATE TEMPORARY TABLE pts_hetre AS 
SELECT p.id_ech, p.id_point, h.rid, ST_Value(h.rast, st_transform(p.geom,27572)) AS proba_hetre
FROM pts p
INNER JOIN sig_inventaire.prob_hetre h ON ST_Intersects(h.rast, st_transform(p.geom,27572));

WITH moyen AS (
    SELECT id_ech, id_point, avg(proba_hetre) AS proba_hetre
    FROM pts_hetre
    GROUP BY id_ech, id_point
    HAVING count(*) > 1 -- doublons
)
, suppr AS (
    DELETE FROM pts_hetre p
    USING moyen m
    WHERE p.id_ech = m.id_ech
    AND p.id_point = m.id_point
)
INSERT INTO pts_hetre (id_ech, id_point, proba_hetre)
SELECT id_ech, id_point, proba_hetre
FROM moyen;

UPDATE point_ech p
SET proba_hetre = ph.proba_hetre
FROM pts_hetre ph
WHERE p.id_ech = ph.id_ech
AND p.id_point = ph.id_point;

INSERT INTO inv_prod_new.croisement_carto (id_ech, id_couche, num_version, date_croisement)
SELECT id_ech, 11, 1, date_tirage
FROM inv_prod_new.echantillon e
INNER JOIN inv_prod_new.campagne c USING (id_campagne)
WHERE type_ue = 'P'
AND type_ech = 'IFN'
AND nom_ech LIKE 'FR%'
AND phase_stat = 2
AND millesime = 2026
ORDER BY id_ech;

DROP TABLE pts_hetre;


-- Angle de Gams

SELECT ST_SRID(rast) As srid FROM sig_inventaire.angle_gams WHERE rid = 1;
--SELECT UpdateRasterSRID('sig_inventaire', 'angle_gams', 'rast', 27572);--> transformation nécessaire en base locale

CREATE TEMPORARY TABLE pts_gams AS
SELECT p.id_ech, p.id_point, g.rid, ST_Value(g.rast, st_transform(p.geom,27572)) AS angle_gams
FROM pts p
INNER JOIN sig_inventaire.angle_gams g ON ST_Intersects(st_transform(p.geom,27572), ST_ConvexHull(g.rast));

/* export de la table pts_gams vers inv, test et prod pour cause de probleme d'auto intersection dans ces environnements
\COPY (SELECT p.id_ech, p.id_point, g.rid, (ST_Intersection(g.rast, p.geom)).val AS angle_gams
FROM pts p
INNER JOIN sig_inventaire.angle_gams g ON g.rast && p.geom AND ST_Intersects(g.rast, p.geom)) TO '/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2026/donnees/pts_gams.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''

  
    CREATE TABLE public.pts_gams (
    id_ech int4,
    id_point int4,
    rid int4,
   	angle_gams float8);
   
\COPY public.pts_gams FROM '/home/lhaugomat/Documents/GITLAB/production/Campagne_2025/donnees/pts_gams.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER
*/

WITH moyen AS (
    SELECT id_ech, id_point, avg(angle_gams) AS angle_gams
    FROM pts_gams
    GROUP BY id_ech, id_point
    HAVING count(*) > 1 -- doublons
)
, suppr AS (
    DELETE FROM pts_gams p
    USING moyen m
    WHERE p.id_ech = m.id_ech
    AND p.id_point = m.id_point
)
INSERT INTO pts_gams (id_ech, id_point, angle_gams)
SELECT id_ech, id_point, angle_gams
FROM moyen;

UPDATE point_ech p
SET angle_gams = pg.angle_gams
FROM pts_gams pg
WHERE p.id_ech = pg.id_ech
AND p.id_point = pg.id_point;

INSERT INTO inv_prod_new.croisement_carto (id_ech, id_couche, num_version, date_croisement)
SELECT id_ech, 12, 1, date_tirage
FROM inv_prod_new.echantillon e
INNER JOIN inv_prod_new.campagne c USING (id_campagne)
WHERE type_ue = 'P'
AND type_ech = 'IFN'
AND nom_ech LIKE 'FR%'
AND phase_stat = 2
AND millesime = 2026
ORDER BY id_ech;

DROP TABLE pts;
DROP TABLE pts_gams;

-- secteurs du contrôle national
WITH croise AS (
    SELECT p.id_ech, p.id_point, s.nom_sect AS nom
    FROM pts2026 p
    INNER JOIN sig_inventaire.secteurs_cn s ON p.geom && s.geom AND ST_Intersects(p.geom, s.geom)
)
UPDATE point_lt pe
SET secteur_cn = c.nom
FROM croise c
WHERE pe.id_ech = c.id_ech
AND pe.id_point = c.id_point;

DROP TABLE pts2026;



/*
SELECT count(*), count(secteur_cn)
FROM inv_prod_new.v_liste_points_lt1 v
INNER JOIN inv_prod_new.point_lt pe USING (id_ech, id_point)
WHERE v.annee = 2026;
*/

-- Affectation aux différentes DIR à partir des secteurs du contrôle national
CREATE UNLOGGED TABLE public.secteurs (
    secteur_cn TEXT PRIMARY KEY,
    echelon_init CHAR(2)
);

/* Import via une commande Linux, dans les différents environnements

awk 'FNR>1' /home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/production/Incref18/donnees/S-EX*.csv | psql service=inventaire-local -c "\copy public.secteurs from STDIN with delimiter as ',' csv"
awk 'FNR>1' /home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/production/Incref18/donnees/S-EX*.csv | psql service=inv-dev -c "\copy public.secteurs from STDIN with delimiter as ',' csv"
awk 'FNR>1' /home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/production/Incref18/donnees/S-EX*.csv | psql service=test-inv-prod -c "\copy public.secteurs from STDIN with delimiter as ',' csv"
awk 'FNR>1' /home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/production/Incref18/donnees/S-EX*.csv | psql service=inv-prod -c "\copy public.secteurs from STDIN with delimiter as ',' csv"

*/

/* Quelques vérifications préalables
SELECT DISTINCT nom_sect
FROM sig_inventaire.secteurs_cn
EXCEPT 
SELECT secteur_cn
FROM public.secteurs;

SELECT secteur_cn
FROM public.secteurs
EXCEPT 
SELECT DISTINCT nom_sect
FROM sig_inventaire.secteurs_cn;
*/

-- Affectation de la DIR
UPDATE inv_prod_new.point_lt pl
SET echelon_init = s.echelon_init
FROM public.secteurs s
INNER JOIN inv_prod_new.point_ech pe ON s.secteur_cn = pe.secteur_cn
INNER JOIN inv_prod_new.echantillon e ON pe.id_ech = e.id_ech
INNER JOIN inv_prod_new.campagne c ON e.id_campagne = c.id_campagne
WHERE pl.id_ech = pe.id_ech
AND pl.id_point = pe.id_point
AND c.millesime = 2026;

/*
SELECT echelon_init, count(*)
FROM inv_prod_new.point_lt pl
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 USING (id_ech, id_point) --> idem avec lt1 et lt2
WHERE annee = 2026
GROUP BY 1
ORDER BY 1;
*/

DROP TABLE public.secteurs;

-- Historisation du croisement (à modifier si nouvelle version de la couche...)
--INSERT INTO inv_prod_new.version_couche (id_couche, num_version, nom_version)
--VALUES (16, 10, 'Version 2025');

INSERT INTO inv_prod_new.croisement_carto (id_ech, id_couche, num_version, date_croisement)
SELECT id_ech, 16, 10, date_tirage          -- Attention aux valeurs ici si nouvelle version de couche
FROM inv_prod_new.echantillon e
INNER JOIN inv_prod_new.campagne c USING (id_campagne)
WHERE type_ue = 'P'
AND type_ech = 'IFN'
AND nom_ech LIKE 'FR%'
AND phase_stat = 2
AND millesime = 2026
ORDER BY id_ech;
