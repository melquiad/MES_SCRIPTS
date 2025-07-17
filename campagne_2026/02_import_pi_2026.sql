BEGIN;

DROP TABLE IF EXISTS public.resultats;
DROP TABLE IF EXISTS public.inters;

/*
-- contrôle du format des fichiers via DuckDB
DESCRIBE FROM read_csv('/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2026/donnees/points2026.csv', delim = '|', header = TRUE);
DESCRIBE FROM read_csv('/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2026/donnees/lhf2026.csv', delim = '|', header = TRUE);
*/

CREATE UNLOGGED TABLE public.resultats (
	npp CHAR(16),
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
	csob VARCHAR(2),
	pdsla CHAR(1),
	CONSTRAINT resultats_pkey PRIMARY KEY (npp)
)
WITHOUT OIDS;

\COPY public.resultats FROM '/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2026/donnees/points2026.csv' WITH CSV HEADER DELIMITER '|' NULL AS ''

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

\COPY public.inters FROM '/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2026/donnees/lhf2026.csv' WITH CSV HEADER DELIMITER '|' NULL AS ''

/*
SELECT count(*), count(r.npp)
FROM v_liste_points_pi1 vp
LEFT JOIN public.resultats r USING (npp)
WHERE annee = 2026;  --> 54981 pts

SELECT count(*), count(r.npp)
FROM v_liste_points_pi2 vp
LEFT JOIN public.resultats r USING (npp)
WHERE annee = 2026
AND annee_pi1 = 2026 - 5;  --> 33072 pts
*/

-- chargement des points 1re PI
UPDATE point_pi pp
SET auteurpi = coalesce(r.auteurpi, 240), datepi = coalesce(r.datepi, now()::date)
, occ = COALESCE(r.occ, '0'), cso = r.cso, dbpi = r.dbpi, pbpi = r.pbpi, uspi = r.uspi, ufpi = r.ufpi, tfpi = r.tfpi, phpi = r.phpi
, blpi = r.blpi, dupi = r.dupi, evof = r.evof, csob = r.csob, pdsla = r.pdsla
, suppl = jsonb_strip_nulls(jsonb_build_object('efpi', r.efpi))
, qual_data = jsonb_strip_nulls(jsonb_build_object('note', r.note))
FROM v_liste_points_pi1 v
LEFT JOIN public.resultats r USING (npp)
WHERE pp.id_ech = v.id_ech
AND pp.id_point = v.id_point
AND annee = 2026;

SET enable_nestloop = FALSE;

-- chargement des points 2ème PI
UPDATE point_pi pp
SET auteurpi = coalesce(r.auteurpi, 240), datepi = coalesce(r.datepi, now()::date)
, occ = COALESCE(r.occ, '0'), cso = r.cso, dbpi = r.dbpi, pbpi = r.pbpi, uspi = r.uspi, ufpi = r.ufpi, tfpi = r.tfpi, phpi = r.phpi
, blpi = r.blpi, dupi = r.dupi, evof = r.evof, csob = r.csob, pdsla = r.pdsla
, suppl = jsonb_strip_nulls(jsonb_build_object('efpi', r.efpi))
, qual_data = jsonb_strip_nulls(jsonb_build_object('note', r.note))
FROM v_liste_points_pi2 v
INNER JOIN public.resultats r USING (npp)
WHERE pp.id_ech = v.id_ech
AND pp.id_point = v.id_point
AND annee = 2026;

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
AND c.millesime = 2026;

DROP TABLE public.resultats;
DROP TABLE public.inters;

COMMIT;

VACUUM ANALYZE point_pi;
ANALYZE fla_pi;




--------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Mise à jour de la date des photos
CREATE TABLE public.date_photo_point (
    npp CHAR(16),
    datephoto date);

\COPY date_photo_point FROM '/home/lhaugomat/Documents/ECHANGES/GIT/base-de-production/Campagne_2026/donnees/pi2026_datepva.csv' WITH CSV DELIMITER ',' NULL AS '' HEADER

UPDATE inv_prod_new.point_pi pp
SET datephoto = a.datephoto
FROM inv_prod_new.point_ech pe
INNER JOIN inv_prod_new.point p ON pe.id_point = p.id_point
INNER JOIN inv_prod_new.echantillon e ON pe.id_ech = e.id_ech AND e.phase_stat = 1
INNER JOIN inv_prod_new.campagne c ON e.id_campagne = c.id_campagne AND c.millesime = 2026
INNER JOIN public.date_photo_point_ a ON LEFT(a.npp, -1) = LEFT(p.npp, -1)
WHERE pp.id_ech = pe.id_ech AND pp.id_point = pe.id_point;

TABLE point_pi;

DROP TABLE public.date_photo_point;

VACUUM ANALYZE inv_prod_new.point_pi;



