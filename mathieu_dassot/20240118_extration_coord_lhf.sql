
-- en base de production
SELECT DISTINCT p.npp, p.id_point, af.id_ech, te.id_transect, t.xl_centre, t.yl_centre
FROM arbre_fla af
INNER JOIN point p USING (id_transect)
INNER JOIN fla_lt fl USING (id_ech, id_transect)
INNER JOIN transect_ech te USING (id_ech, id_transect)
INNER JOIN transect t USING (id_transect)
ORDER BY 1;

-- en base de production version Cédric
SELECT p.npp, fl.id_transect, round(ST_X(p.geom)::NUMERIC) AS xl93, round(ST_Y(p.geom)::NUMERIC) AS yl93, c.millesime AS campagne
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN fla_lt fl USING (id_ech)
INNER JOIN point p USING (id_transect)
INNER JOIN echantillon ep ON e.id_campagne = ep.id_campagne AND ep.phase_stat = 2 AND ep.ech_parent IS NULL AND ep.type_ech = 'IFN'
INNER JOIN point_ech pe ON ep.id_ech = pe.id_ech AND p.id_point = pe.id_point
WHERE c.millesime > 2005
ORDER BY npp;

-- en base d'exploitation
SELECT DISTINCT la.incref + 2005 AS campagne, lt.npp, round(st_x(ec.geom)) AS X_l93, round(st_y(ec.geom)) AS y_l93
FROM inv_exp_nm.l3arbre la
INNER JOIN inv_exp_nm.l1transect lt USING (npp)
INNER JOIN inv_exp_nm.l1intersect li USING (npp)
INNER JOIN inv_exp_nm.e1coord ec USING (npp)
ORDER BY 1;

--------------------------------------------------------------------------
------------- comparaison dans QGIS avec l1intersect ---------------------
CREATE TABLE public.transect_md AS
	(SELECT DISTINCT la.incref + 2005 AS campagne, lt.npp, ec.geom AS geom
	FROM inv_exp_nm.l3arbre la
	INNER JOIN inv_exp_nm.l1transect lt USING (npp)
	INNER JOIN inv_exp_nm.l1intersect li USING (npp)
	INNER JOIN inv_exp_nm.e1coord ec USING (npp)
	ORDER BY 1
	);

CREATE TABLE public.transect_cd AS
	(SELECT DISTINCT c.millesime AS campagne, p.npp, p.geom AS geom, round(ST_X(p.geom)::NUMERIC) AS xl93, round(ST_Y(p.geom)::NUMERIC) AS yl93
	FROM campagne c
	INNER JOIN echantillon e USING (id_campagne)
	INNER JOIN fla_lt fl USING (id_ech)
	INNER JOIN point p USING (id_transect)
	INNER JOIN echantillon ep ON e.id_campagne = ep.id_campagne AND ep.phase_stat = 2 AND ep.ech_parent IS NULL --AND ep.type_ech = ‘IFN’ 
	INNER JOIN point_ech pe ON ep.id_ech = pe.id_ech AND p.id_point = pe.id_point
	WHERE c.millesime > 2005
	ORDER BY campagne, npp
	);
	
CREATE TABLE public.intersect_md AS
	(SELECT li.npp, st_transform(st_point(li.xi,li.yi,27572),2154) AS geom
	FROM inv_exp_nm.l1intersect li
	INNER JOIN public.transect_md tm USING (npp)
	);

DROP TABLE public.transect_md;
DROP TABLE public.transect_cd;
DROP TABLE public.intersect_md;

-- passage en lambert 2 étendu des coordonnées de la campagne 2022 dans l1intersect
UPDATE inv_exp_nm.l1intersect --> en local
SET xi = st_x(st_transform(st_setsrid(st_point(xi,yi),2154),27572)), yi = st_y(st_transform(st_setsrid(st_point(xi,yi),2154),27572))
WHERE incref = 17;

UPDATE inv_exp_nm.l1intersect --> sur inv_exp_nm et test_inv_exp_nm
SET xi = st_x(st_transform(st_setsrid(st_point(xi,yi),931007),932006)), yi = st_y(st_transform(st_setsrid(st_point(xi,yi),931007),932006))
WHERE incref = 17;


/*CREATE TABLE public.temp1 AS
	(
	SELECT xi, yi ,st_x(st_transform(st_setsrid(st_point(xi,yi),931007),932006)), st_y(st_transform(st_setsrid(st_point(xi,yi),931007),932006))
	FROM inv_exp_nm.l1intersect
	WHERE incref = 17
	);

DROP TABLE public.temp1;
*/

-- Examen des 705 points de 20240130_extraction_transect_version_cedric.csv sans correspondance dans l1intersect
CREATE TABLE public.points_md (
	campagne INT2,
	npp TEXT, 
    xl93 INT4,
    yl93 INT4,
    CONSTRAINT points_md_pkey PRIMARY KEY (npp)
    );

\COPY public.points_md FROM '/home/lhaugomat/Documents/MES_SCRIPTS/mathieu_dassot/lhf_verif_npp.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

SELECT campagne, npp, li.npp
FROM public.points_md
LEFT JOIN inv_exp_nm.l1intersect li USING (npp);

SELECT campagne, npp, lt.npp
FROM public.points_md
LEFT JOIN inv_exp_nm.l1transect lt USING (npp);

SELECT pm.campagne, pm.npp, fl.optersl, fl.tlhf2
FROM public.points_md pm
INNER JOIN point p USING (npp)
INNER JOIN fla_lt fl USING (id_transect);

SELECT pm.campagne, pm.npp, fp.id_transect, fp.flpi
FROM public.points_md pm
INNER JOIN point p USING (npp)
INNER JOIN fla_pi fp USING (id_transect);



SELECT DISTINCT pm.campagne, pm.npp, fl.id_transect, af.id_transect, af.a
FROM public.points_md pm
INNER JOIN point p USING (npp)
INNER JOIN fla_lt fl USING (id_transect)
INNER JOIN arbre_fla af USING (id_ech,id_transect)
ORDER BY 1,2,5;



