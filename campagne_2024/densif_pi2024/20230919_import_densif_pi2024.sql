/*
PRÉTRAITEMENT DES FICHIERS POUR ENLEVER LES GUILLEMETS

cd /home/lhaugomat/Documents/GITLAB/production/Incref19/donnees
cd /home/lhaugomat/Documents/MES_SCRIPTS/campagne_2024/densif_PI2024

sed -i "s/'//g" densif_pi2024.csv

*/

BEGIN;

DROP TABLE IF EXISTS public.resultats;
DROP TABLE IF EXISTS public.inters;


CREATE UNLOGGED TABLE public.resultats (
	npp CHAR(16),
	nppg CHAR(16),
	occ CHAR(1),
	auteurpi INTEGER,
	datepi DATE,
	note TEXT,
	cso VARCHAR(2),
	dbpi CHAR(1),
	pbpi CHAR(1),
	uspi CHAR(1),
	ufpi CHAR(1),
	tfpi CHAR(1),
	phpi CHAR(1),
	blpi CHAR(1),
	efpi CHAR(1),
	dupi CHAR(1),
	evof CHAR(1),
	CONSTRAINT resultats_pkey PRIMARY KEY (npp)
)
WITHOUT OIDS;

\COPY public.resultats FROM '/home/lhaugomat/Documents/MES_SCRIPTS/campagne_2024/densif_pi2024/densif_pi2024.csv' WITH CSV HEADER DELIMITER '|' NULL AS ''
--\COPY public.resultats FROM '/home/lhaugomat/Documents/GITLAB/production/Incref19/donnees/densif_pi2024.csv' WITH CSV HEADER DELIMITER '|' NULL AS ''

/*
CREATE UNLOGGED TABLE public.inters (
  sl SMALLINT NOT NULL,
  npp CHARACTER(16) NOT NULL,
  disti SMALLINT,
  xi INTEGER,
  yi INTEGER,
  repi SMALLINT,
  flpi CHARACTER(1),
  CONSTRAINT intersects_pkey PRIMARY KEY (npp, sl)
)
WITHOUT OIDS;

\COPY public.inters FROM '/home/lhaugomat/Documents/GITLAB/production/Incref19/donnees/lhf_pi2024.csv' WITH CSV HEADER DELIMITER '|' NULL AS ''


SELECT count(*), count(r.npp)
FROM v_liste_points_pi1 vp
LEFT JOIN public.resultats r USING (npp)
WHERE annee = 2024;

SELECT count(*), count(r.npp)
FROM v_liste_points_pi2 vp
LEFT JOIN public.resultats r USING (npp)
WHERE annee = 2024
AND annee_pi1 = 2024 - 5;
*/

-- chargement des points 1re PI
UPDATE point_pi pp
SET auteurpi = coalesce(r.auteurpi, 240), datepi = coalesce(r.datepi, now()::date)
, occ = COALESCE(r.occ, '0'), cso = r.cso, dbpi = r.dbpi, pbpi = r.pbpi, uspi = r.uspi, ufpi = r.ufpi, tfpi = r.tfpi, phpi = r.phpi
, blpi = r.blpi, dupi = r.dupi, evof = r.evof
, suppl = jsonb_strip_nulls(jsonb_build_object('efpi', r.efpi))
, qual_data = jsonb_strip_nulls(jsonb_build_object('note', r.note))
FROM v_liste_points_pi1 v
LEFT JOIN public.resultats r USING (npp)
WHERE pp.id_ech = v.id_ech
AND pp.id_point = v.id_point
AND annee = 2024;

-- chargement des points 2ème PI
UPDATE point_pi pp
SET auteurpi = coalesce(r.auteurpi, 240), datepi = coalesce(r.datepi, now()::date)
, occ = COALESCE(r.occ, '0'), cso = r.cso, dbpi = r.dbpi, pbpi = r.pbpi, uspi = r.uspi, ufpi = r.ufpi, tfpi = r.tfpi, phpi = r.phpi
, blpi = r.blpi, dupi = r.dupi, evof = r.evof
, suppl = jsonb_strip_nulls(jsonb_build_object('efpi', r.efpi))
, qual_data = jsonb_strip_nulls(jsonb_build_object('note', r.note))
FROM v_liste_points_pi2 v
INNER JOIN public.resultats r USING (npp)
WHERE pp.id_ech = v.id_ech
AND pp.id_point = v.id_point
AND annee = 2024;

UPDATE inv_prod_new.point_pi
SET suppl = NULL
WHERE suppl = '{}';

UPDATE inv_prod_new.point_pi
SET qual_data = NULL
WHERE qual_data = '{}';

-- chargement des intersections LHF
INSERT INTO fla_pi (id_ech, id_transect, sl_pi, disti, xi, yi, repi, flpi)
SELECT e.id_ech, te.id_transect, i.sl, i.disti, i.xi, i.yi, i.repi, i.flpi
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
INNER JOIN transect_ech te USING (id_ech)
INNER JOIN point USING (id_transect)
INNER JOIN public.inters i USING (npp)
WHERE e.type_ue = 'T'
AND e.type_ech = 'IFN'
AND e.phase_stat = 1
AND c.millesime = 2024;

DROP TABLE public.resultats;
DROP TABLE public.inters;

COMMIT;

VACUUM ANALYZE point_pi;
ANALYZE fla_pi;

-- correction a posteriori de EVOF sur un point deuxième PI

WITH pts_potentiels_foret_new AS (                  -- on récupère les points d'il y a 5 ans en PI qui sont "autre végétation" (et eux seulement), donc susceptibles de passer à la forêt
    SELECT pen.id_ech, pen.id_point
    FROM point_ech pen
    INNER JOIN echantillon en ON pen.id_ech = en.id_ech
    INNER JOIN campagne c ON en.id_campagne = c.id_campagne
    INNER JOIN echantillon ep ON en.ech_parent = ep.id_ech
    INNER JOIN campagne cp ON ep.id_campagne = cp.id_campagne
    INNER JOIN point_ech peo ON en.ech_parent = peo.id_ech AND pen.id_point = peo.id_point
    INNER JOIN point_pi ppo ON peo.id_ech = ppo.id_ech AND peo.id_point = ppo.id_point
    INNER JOIN point po ON ppo.id_point = po.id_point
    WHERE c.millesime = 2024
    AND cp.millesime = 2024 - 5 
    AND en.type_ue = 'P'
    AND en.type_ech = 'IFN'
    AND en.phase_stat = 1
    AND ppo.cso = '7'
    AND ppo.ufpi = '1'
    AND NOT EXISTS (
        SELECT 1
        FROM fla_pi fp
        WHERE fp.id_transect = po.id_transect
        AND fp.flpi NOT IN ('0', '6')
        AND ABS(fp.disti) <= 25
    )
)
, pts_a_corriger AS (
    SELECT pp.id_ech, pp.id_point, pp.cso, pp.evof, pp.uspi 
    FROM echantillon et
    INNER JOIN campagne c USING (id_campagne)
    INNER JOIN point_pi pp ON pp.id_ech = et.ech_parent
    INNER JOIN point p USING (id_point)
    INNER JOIN pts_potentiels_foret_new ppfn ON et.ech_parent = ppfn.id_ech AND pp.id_point = ppfn.id_point
    WHERE et.type_ue = 'P'
    AND et.type_ech = 'IFN'
    AND et.phase_stat = 2
    AND et.ech_parent IS NOT NULL
    AND pp.evof IN ('1', '2')
    AND pp.uspi = 'X'
    AND c.millesime = 2024
)
UPDATE point_pi x
SET evof = 'B'
FROM pts_a_corriger pac
WHERE x.id_ech = pac.id_ech
AND x.id_point = pac.id_point;






/****************************************************************************************************************
 * Insertion des intersections faites a posteriori au-delà de 60 m                                              *
 ****************************************************************************************************************/
BEGIN;

CREATE UNLOGGED TABLE public.inters (
  sl SMALLINT NOT NULL,
  npp CHARACTER(16) NOT NULL,
  disti SMALLINT,
  xi INTEGER,
  yi INTEGER,
  disti2 SMALLINT,
  repi SMALLINT,
  flpi CHARACTER(1),
  CONSTRAINT intersects_pkey PRIMARY KEY (npp, sl)
)
WITHOUT OIDS;

\COPY public.inters FROM '/home/lhaugomat/Documents/GITLAB/production/Incref19/donnees/points_lhf_pi2024_part2.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''

/*
SELECT *
FROM public.inters i
WHERE disti IS DISTINCT FROM disti2;
*/


INSERT INTO fla_pi (id_ech, id_transect, sl_pi, disti, xi, yi, repi, flpi)
SELECT e.id_ech, te.id_transect, i.sl, i.disti, i.xi, i.yi, i.repi, i.flpi
FROM echantillon e
INNER JOIN campagne c USING (id_campagne)
INNER JOIN transect_ech te USING (id_ech)
INNER JOIN point USING (id_transect)
INNER JOIN public.inters i USING (npp)
WHERE e.type_ue = 'T'
AND e.type_ech = 'IFN'
AND e.phase_stat = 1
AND c.millesime = 2024;

DROP TABLE public.inters;

COMMIT;

ANALYZE fla_pi;







--------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mise à jour de la date des photos
CREATE TEMPORARY TABLE date_photo_point (
    npp CHAR(16),
    dep char(2),
    datephoto date);

\COPY date_photo_point FROM '/home/lhaugomat/Documents/GITLAB/production/Incref19/donnees/pi2024_datepva.csv' WITH CSV DELIMITER ',' NULL AS '' HEADER

UPDATE inv_prod_new.point_pi pp
SET datephoto = a.datephoto
FROM inv_prod_new.point_ech pe
INNER JOIN inv_prod_new.point p ON pe.id_point = p.id_point
INNER JOIN inv_prod_new.echantillon e ON pe.id_ech = e.id_ech AND e.phase_stat = 1
INNER JOIN inv_prod_new.campagne c ON e.id_campagne = c.id_campagne AND c.millesime = 2024
INNER JOIN date_photo_point a ON LEFT(a.npp, -1) = LEFT(p.npp, -1)
WHERE pp.id_ech = pe.id_ech AND pp.id_point = pe.id_point;
TABLE point_pi;
DROP TABLE date_photo_point;

VACUUM ANALYZE inv_prod_new.point_pi;



