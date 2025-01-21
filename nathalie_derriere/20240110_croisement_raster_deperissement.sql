/*
EXEMPLE 1

# -s use srid 4326
# -I create spatial index
# -C use standard raster constraints
# -M vacuum analyze after load
# *.tif load all these files
# -F include a filename column in the raster table
# -t tile the output 100x100
# public.demelevation load into this table
raster2pgsql -s 4326 -I -C -M -F -t 100x100 *.tif public.demelevation > elev.sql
#suivi de
psql -d gisdb -f elev.SQL
# -d connect to this database
# -f read this file after connecting

# en une seule fois
raster2pgsql -s 4326 -I -C -M -F -t 100x100 *.tif public.demelevation | psql -d gisdb
---------------------------------------------------------------------------------------
EXEMPLE 2 : création BDA ALTI 20211

raster2pgsql -s 910001 -I -C -M *.asc -F -t 50x50 bdalti2011.mnt > bdalti.sql
psql -h inv-exp.ign.fr -d exploitation -f bdalti.sql -U duprez

ou

raster2pgsql -s 910001 -I -C -M *.asc -F -t 50x50 bdalti2011.mn | psql -h inv-exp.ign.fr -d exploitation -U duprez
*/

CREATE TABLE public.pts_new_10 AS (SELECT * FROM pts_new LIMIT 10);

CREATE TEMPORARY TABLE alti AS
SELECT npp, xl, yl, rid, (gv).val AS zp
FROM (
    SELECT p.npp, p.xl, p.yl, m.rid, ST_Intersection(st_transform(m.rast,2154), p.geom93) AS gv
    FROM pts_new_10 p
    INNER JOIN bdalti2011.mnt m ON ST_Intersects(st_transform(m.rast,2154), p.geom93)
) foo
ORDER BY 1;

--------------------------------------------------------------------------------------------------------
--> pour les rasters hors DB
SET postgis.enable_outdb_rasters TO TRUE; 
SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';
ALTER DATABASE inventaire SET postgis.enable_outdb_rasters = TRUE;
ALTER DATABASE inventaire SET postgis.gdal_enabled_drivers TO 'ENABLE_ALL';


raster2pgsql -s 2154 -I -C -M -t 256x256 ~/Documents/DATA_SIG/RECONFORT/2022_2classes_2y_CR.tif -F public.2022_rec | psql -d inventaire -p 5433
-- ou
raster2pgsql -s 2154 -I -C -R -M -t 256x256 ~/Documents/DATA_SIG/RECONFORT/2019_2classes_2y_CR.tif -F public.2019_rec_out_db | psql -d inventaire -p 5433
--> option -R pour stockage externe mais perte des valeurs pixel d'origine et pas d'affichage dans QGIS
--> chmod -R 777 pour rendre les rasters out-db utilisables dans les croisements

-- en base d'exploitation
SELECT campagne, npp, deper50, tfv, (gv).val AS val_tif 
FROM (
	SELECT g.incref+2005 AS campagne, g.npp, g.deper50, ug.u_tfv_in AS tfv, ST_Intersection(r.rast,st_transform(e.geom,2154)) AS gv
	FROM inv_exp_nm.g3foret g
	INNER JOIN inv_exp_nm.e1coord e USING (npp)
	INNER JOIN inv_exp_nm.e2point ep USING (npp)
	INNER JOIN inv_exp_nm.u_g3foret ug USING (npp)
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(e.geom,2154))
	WHERE g.incref = 12 AND ep.dep IN ('45','18','41','37','28','36')
	UNION
	SELECT p.incref+2005 AS campagne, p.npp, p.deper50, up.u_tfv_in, ST_Intersection(r.rast,st_transform(e.geom,2154)) AS gv
	FROM inv_exp_nm.p3point p
	INNER JOIN inv_exp_nm.e1coord e USING (npp)
	INNER JOIN inv_exp_nm.e2point ep USING (npp)
	INNER JOIN inv_exp_nm.u_p3point up USING (npp)
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(e.geom,2154))
	WHERE p.incref = 12 AND ep.dep IN ('45','18','41','37','28','36')
	) foo --> alias obligatoire pour sous-requête
ORDER BY 1;

/*
SELECT rid, st_valuecount(rast)
FROM public."2019_rec"
GROUP BY rid;

SELECT st_valuecount(st_union(rast)) FROM public."2019_rec";
*/

-- en base de production (plus de points) ------------------------------------------------------------------
SELECT idp, npp, nincid, incid, deper50, (gv).val AS val_tif
FROM (
	SELECT p.idp, p.npp, d.nincid, d.incid, gf.deper50, ug.u_tfv_in, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	FROM v_liste_points_lt1 lt1
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN point p USING (id_point)
	INNER JOIN description d USING (id_ech,id_point)
	INNER JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
	INNER JOIN inv_exp_nm.u_g3foret ug ON p.npp = gf.npp
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE c.millesime  = 2017 AND pe.dep IN ('45','18','41','37','28','36')
	UNION
	SELECT p.idp, p.npp, d.nincid, d.incid, pp.deper50, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	FROM description d
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN point p USING (id_point)
	INNER JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
	INNER JOIN public."2017_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE c.millesime  = 2017 AND pe.dep IN ('45','18','41','37','28','36')
	) foo
ORDER BY 1;

-- version avec seulement les points lt1 et lt2 premier levé
SELECT annee, idp, nincid, incid, deper50, deperis50, tfv, (gv).val AS val_tif, xl, yl
FROM (
	SELECT lt.annee, p.idp, d.nincid, d.incid,
	COALESCE(gf.deper50,pp.deper50) AS deper50, COALESCE(ug.u_deperis50,up.u_deperis50) AS deperis50, COALESCE(ug.u_tfv_in,up.u_tfv_in) AS tfv, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	, round(st_x(n.geom)) AS xl, round(st_y(n.geom)) AS yl
	FROM v_liste_points_lt1 lt
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)
	INNER JOIN noeud n USING (id_noeud)
	INNER JOIN point p USING (id_point)	
	INNER JOIN ecologie e2 USING (id_ech,id_point)
	LEFT JOIN description d USING (id_ech,id_point)
	LEFT JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
	LEFT JOIN inv_exp_nm.u_g3foret ug ON p.npp = ug.npp
	LEFT JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
	LEFT JOIN inv_exp_nm.u_p3point up ON p.npp = up.npp
	INNER JOIN public."2021_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE date_part('year',e2.dateeco) IN ('2021','2020') AND lt.annee = 2021 AND pe.dep IN ('45','18','41','37','28','36')
	UNION -- pas de données en LT1_PI2
	SELECT lp.annee, p.idp, d.nincid, d.incid,
	COALESCE(gf.deper50,pp.deper50) AS deper50, COALESCE(ug.u_deperis50,up.u_deperis50) AS deperis50, COALESCE(ug.u_tfv_in,up.u_tfv_in) AS tfv, ST_Intersection(r.rast,st_transform(p.geom,2154)) AS gv
	, round(st_x(n.geom)) AS xl, round(st_y(n.geom)) AS yl
	FROM v_liste_points_lt2 lp
	INNER JOIN echantillon e USING (id_ech)
	INNER JOIN campagne c ON e.id_campagne = c.id_campagne
	INNER JOIN point_ech pe USING (id_ech,id_point)	
	INNER JOIN point p USING (id_point)
	INNER JOIN noeud n USING (id_noeud)
	INNER JOIN ecologie e2 USING (id_ech,id_point)
	LEFT JOIN description d USING (id_ech,id_point)
	LEFT JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
	LEFT JOIN inv_exp_nm.u_g3foret ug ON p.npp = ug.npp
	LEFT JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
	LEFT JOIN inv_exp_nm.u_p3point up ON p.npp = up.npp
	INNER JOIN public."2021_rec" r ON ST_Intersects(r.rast,st_transform(p.geom,2154))
	WHERE date_part('year',e2.dateeco) IN ('2021','2020') AND lp.annee = 2021 AND pe.dep IN ('45','18','41','37','28','36')	
	) foo
	ORDER BY 2;

--------------------------- Contrôles -----------------------------------
SELECT p.idp, d.nincid, d.incid
FROM point p
INNER JOIN description d USING (id_point)
WHERE p.idp = '840937';

--SELECT v.npp, ug.npp, ug.u_tfv_in, ug.u_tfv
SELECT v.npp, up.npp, up.u_tfv_in, up.u_tfv
FROM v_liste_points_lt1 v
--INNER JOIN inv_exp_nm.u_g3foret ug ON v.npp = ug.npp
INNER JOIN inv_exp_nm.u_p3point up ON v.npp = up.npp
WHERE annee = 2021
ORDER BY 1;

 --test sur 2 points de 2017 qui apparaissent en 2022 pour Nathalie
SELECT p.idp, v.id_point, v.npp, v.annee, pm.pointok5, d.nincid, d.incid,
COALESCE(gf.deper50,pp.deper50) AS deper50, COALESCE(ug.u_tfv_in,up.u_tfv_in) AS tfv
FROM v_liste_points_lt2 v
INNER JOIN point p USING (id_point, npp)
LEFT JOIN description d USING (id_point)
INNER JOIN point_m2 pm USING (id_point)
LEFT JOIN inv_exp_nm.g3foret gf ON p.npp = gf.npp
LEFT JOIN inv_exp_nm.u_g3foret ug ON p.npp = ug.npp
LEFT JOIN inv_exp_nm.p3point pp ON p.npp = pp.npp
LEFT JOIN inv_exp_nm.u_p3point up ON p.npp = up.npp
WHERE p.idp IN ('1202145', '1210672');


-------------------------------------------- RAJOUT DE LA DONNEE U_DEPERIS50 --------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------- Création de la donnée U_MORTBDEPER -----------------------------------------------------------------------------
BEGIN;
-- Documentation de l'unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition) 
VALUES ('U_MORTBDEPER', 'AUTRE', 'NOMINAL', 'Mortalité de branche. Unité stable dans le temps',
'Mortalité de branche dans la moitié supérieure du houppier. Unité compatible avec les évolutions d''unité au fil du temps et adaptée au calcul de la donnée DEPERIS.');

-- Documentation des modalités
INSERT INTO metaifn.abmode (unite, "mode", "position", classe, valeurint, etendue, hls, rgb, cmyk, libelle, definition)
VALUES('U_MORTBDEPER', 'X', 1, 0, NULL, 1, NULL, NULL, NULL, 'non observ.', 'Les conditions d’observation ne permettent pas d’apprécier la mortalité des branches OU la mortalité des branches n''est pas à apprécier pour ces arbres (diamètre < 22,5 cm ou couvert libre inférieur à 2/3, ou accidenté).')
, ('U_MORTBDEPER', '0', 2, 1, NULL, 1, NULL, NULL, NULL, 'moins de 5 %', 'Absence de branches mortes ou présence de moins de 5 % de branches mortes dans la moitié supérieure du houppier.')
, ('U_MORTBDEPER', '1', 3, 2, NULL, 1, NULL, NULL, NULL, 'entre 5 et 25 %', 'Présence de 5 à 25 % de branches mortes dans la moitié supérieure du houppier.')
, ('U_MORTBDEPER', '2', 4, 3, NULL, 1, NULL, NULL, NULL, 'entre 25 à 50 %', 'Présence de 25 à 50 % de branches mortes dans la moitié supérieure du houppier.')
, ('U_MORTBDEPER', '3', 5, 4, NULL, 1, NULL, NULL, NULL, 'entre 50 à 75 %', 'Présence de 50 à 75 % de branches mortes dans la moitié supérieure du houppier.')
, ('U_MORTBDEPER', '4', 6, 5, NULL, 1, NULL, NULL, NULL, 'entre 75 à 95 %', 'Présence de 75 à 95 % de branches mortes dans la moitié supérieure du houppier.')
, ('U_MORTBDEPER', '5', 7, 6, NULL, 1, NULL, NULL, NULL, 'plus de 95 %', 'Présence de plus de 95% des branches mortes dans la moitié supérieure du houppier.');

-- Documentation de la donnée
SELECT * FROM metaifn.ajoutdonnee('U_MORTBDEPER', NULL, 'U_MORTBDEPER', 'AUTRE', NULL, 7, 'char(1)', 'CC', TRUE, TRUE, 'Mortalité de branches homogénéisée', 
'Indicateur de l''importance de la mortalité des branches dans la moitié supérieure du houppier avec accès à la lumière. Donnée avec unité stable dans le temps et adaptée au calcul de la donnée DEPERIS');

-- Doccumentation de la colonne en base
SELECT * FROM metaifn.ajoutchamp('U_MORTBDEPER', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 1, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('U_MORTBDEPER', 'U_P3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'bpchar', 1);

COMMIT;

BEGIN;
-- Création de la donnée utilisateur
ALTER TABLE inv_exp_nm.u_g3arbre
    ADD COLUMN u_mortbdeper CHAR(1);

ALTER TABLE inv_exp_nm.u_p3arbre
    ADD COLUMN u_mortbdeper CHAR(1);
	
-- Mise à jour de la donnée utilisateur
-- pour campagne 2021 et plus

UPDATE inv_exp_nm.u_g3arbre ua
SET u_mortbdeper = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '4'
        WHEN a.mortb = '5' THEN '5'
        WHEN a.mortb = 'X' THEN 'X'
    END
FROM inv_exp_nm.g3arbre a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;


UPDATE inv_exp_nm.u_p3arbre ua
SET u_mortbdeper = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '4'
        WHEN a.mortb = '5' THEN '5'
        WHEN a.mortb = 'X' THEN 'X'
    END
FROM inv_exp_nm.p3arbre a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;


-- Mise à jour des métadonnées
UPDATE metaifn.afchamp
SET calcin = 16, calcout = 17, validin = 16, validout = 17
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'u_g3arbre'
AND donnee ~~* 'U_MORTBDEPER';

UPDATE metaifn.afchamp
SET calcin = 16, calcout = 17, validin = 16, validout = 17
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'u_p3arbre'
AND donnee ~~* 'U_MORTBDEPER';

-- Affectation à un groupe d'utilisateurs
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('DRIF', 'U_MORTBDEPER');

COMMIT;

---------------------------------------------------- CREATION DE U_DEPERIS EN BASE LOCALE   ----------------------------------------------------------------------------------
-- Création de la donnée U_DEPERIS
BEGIN;

-- Documentation de l'unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition) 
VALUES ('U_DEPERIS', 'AUTRE', 'NOMINAL', 'Dépérissement des arbres',
'Dépérissement des arbres évalué à partir de la mortalité de branches, du manque d''aiguilles et du manque de ramifications.');

-- Documentation des modalités
INSERT INTO metaifn.abmode (unite, "mode", "position", classe, valeurint, etendue, hls, rgb, cmyk, libelle, definition)
VALUES('U_DEPERIS', 'X', 1, 0, NULL, 1, NULL, NULL, NULL, 'non observ.', 'Les conditions d’observation ne permettent pas d’apprécier le dépérissement.')
, ('U_DEPERIS', 'A', 2, 1, NULL, 1, NULL, NULL, NULL, 'Dégradation absente', 'Arbre très sain, sans trace ou à très rares traces (< 5 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('U_DEPERIS', 'B', 3, 2, NULL, 1, NULL, NULL, NULL, 'Dégradation légère', 'Arbre sain, avec des signes légers (< 25 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('U_DEPERIS', 'C', 4, 3, NULL, 1, NULL, NULL, NULL, 'Dégradation modérée', 'Arbre plutôt sain, avec des signes modérés (< 50 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('U_DEPERIS', 'D', 5, 4, NULL, 1, NULL, NULL, NULL, 'Dégradation importante', 'Arbre dégradé, avec des signes importants (généralement entre 50 et 75 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('U_DEPERIS', 'E', 6, 5, NULL, 1, NULL, NULL, NULL, 'Dégradation très importante', 'Arbre très dégradé, avec des signes très importants (généralement entre 75 et 95 %) de mortalité de branches et de manque de ramifications ou aiguilles.')
, ('U_DEPERIS', 'F', 7, 6, NULL, 1, NULL, NULL, NULL, 'Dégradation totale', 'Arbre quasiment mort ou mort, à très forte mortalité de branches et/ou manque de ramifications ou aiguilles.');

-- Documentation de la donnée
SELECT * 
FROM metaifn.ajoutdonnee('U_DEPERIS', NULL, 'U_DEPERIS', 'AUTRE', NULL, 7, 'varchar(1)', 'CC', TRUE, TRUE, 
'Dépérissement des arbres', 'Dépérissement des arbres évalué à partir de la mortalité de branches, du manque d''aiguilles et du manque de ramifications');

-- Documentation de la colonne en base
SELECT * FROM metaifn.ajoutchamp('U_DEPERIS', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 16, 17, 'varchar', 1);
SELECT * FROM metaifn.ajoutchamp('U_DEPERIS', 'U_P3ARBRE', 'INV_EXP_NM', FALSE, 16, 17, 'varchar', 1);

COMMIT;


BEGIN;
-- Création de la donnée utilisateur
ALTER TABLE inv_exp_nm.u_g3arbre 
	ADD COLUMN u_deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.u_g3arbre.u_deperis IS 'Dépérissement des arbres' ;

ALTER TABLE inv_exp_nm.u_p3arbre 
	ADD COLUMN u_deperis character(1); 
COMMENT ON COLUMN inv_exp_nm.u_p3arbre.u_deperis IS 'Dépérissement des arbres' ;

-- Mise à jour de la donnée utilisateur
-- pour campagne 2021 et plus

UPDATE inv_exp_nm.u_g3arbre ua
SET u_deperis = 
	CASE
		WHEN ua.u_mortbdeper = 'X' THEN 'X'		
		WHEN ua.u_mortbdeper = '0' AND (a.mr = '0' OR a.ma = '0') THEN 'A'
		WHEN (ua.u_mortbdeper = '1' AND (a.mr IN ('0', '1') 
			 OR a.ma IN ('0', '1'))) OR (ua.u_mortbdeper = '0' AND (a.mr = '1' OR a.ma = '1')) THEN 'B'			 
		WHEN (ua.u_mortbdeper = '2' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.u_mortbdeper IN ('0', '1') AND (a.mr = '2' OR a.ma = '2')) THEN 'C'			 
		WHEN (ua.u_mortbdeper = '3' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.u_mortbdeper IN ('2', '3') AND (a.mr = '2' OR a.ma = '2')) 
			 OR (ua.u_mortbdeper IN ('0', '1', '2') AND (a.mr = '3' OR a.ma = '3')) THEN 'D'			 
		WHEN (ua.u_mortbdeper = '3' AND (a.mr = '3' OR a.ma = '3'))
			 OR (ua.u_mortbdeper IN ('0', '1', '2') AND (a.mr = '4' OR a.ma = '4')) THEN 'E'	
		WHEN ua.u_mortbdeper IN ('4', '5') OR (a.mr = '5' OR a.ma = '5')
			 OR (ua.u_mortbdeper = '3' AND (a.mr = '4' OR a.ma = '4')) THEN 'F'		
		ELSE 'X' END
FROM inv_exp_nm.g3arbre a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;

SELECT incref, u_deperis, count(*)
FROM inv_exp_nm.u_g3arbre
WHERE incref >= 16
GROUP BY incref, u_deperis
ORDER BY incref, u_deperis;

SELECT ua.incref, mr, ma, u_mortbdeper, u_deperis
FROM inv_exp_nm.u_g3arbre ua
LEFT JOIN inv_exp_nm.g3arbre a ON ua.npp = a.npp
WHERE ua.a = a.a AND ua.incref >= 16 AND u_deperis = 'E';


UPDATE inv_exp_nm.u_p3arbre ua
SET u_deperis = 
	CASE
		WHEN ua.u_mortbdeper = 'X' THEN 'X'		
		WHEN ua.u_mortbdeper = '0' AND (a.mr = '0' OR a.ma = '0') THEN 'A'	
		WHEN (ua.u_mortbdeper = '1' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.u_mortbdeper = '0' AND (a.mr = '1' OR a.ma = '1')) THEN 'B'		 
		WHEN (ua.u_mortbdeper = '2' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.u_mortbdeper IN ('0', '1') AND (a.mr = '2' OR a.ma = '2')) THEN 'C'		 
		WHEN (ua.u_mortbdeper = '3' AND (a.mr IN ('0', '1') OR a.ma IN ('0', '1'))) 
			 OR (ua.u_mortbdeper IN ('2', '3') AND (a.mr = '2' OR a.ma = '2')) 
			 OR (ua.u_mortbdeper IN ('0', '1', '2') AND (a.mr = '3' OR a.ma = '3')) THEN 'D'		 
		WHEN (ua.u_mortbdeper = '3' AND (a.mr = '3' OR a.ma = '3'))
			 OR (ua.u_mortbdeper IN ('0', '1', '2') AND (a.mr = '4' OR a.ma = '4')) THEN 'E'	
		WHEN ua.u_mortbdeper IN ('4', '5') OR (a.mr = '5' OR a.ma = '5')
			 OR (ua.u_mortbdeper = '3' AND (a.mr = '4' OR a.ma = '4')) THEN 'F'	
		ELSE 'X' END
FROM inv_exp_nm.p3arbre a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;

SELECT incref, u_deperis, count(*)
FROM inv_exp_nm.u_p3arbre
WHERE incref >= 16
GROUP BY incref, u_deperis
ORDER BY incref, u_deperis;

SELECT ua.incref, mr, ma, u_mortbdeper, u_deperis
FROM inv_exp_nm.u_p3arbre ua
LEFT JOIN inv_exp_nm.p3arbre a ON ua.npp = a.npp
WHERE ua.a = a.a AND ua.incref >= 16 AND u_deperis = 'F';


-- Mise à jour des métadonnées
UPDATE metaifn.afchamp
SET calcin = 16, calcout = 17, validin = 16, validout = 17
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'u_g3arbre'
AND donnee ~~* 'U_DEPERIS';

UPDATE metaifn.afchamp
SET calcin = 16, calcout = 17, validin = 16, validout = 17
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'u_p3arbre'
AND donnee ~~* 'U_DEPERIS';

-- Affectation à un groupe d'utilisateurs
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('DRIF', 'U_DEPERIS');
		
		
COMMIT;
---------------------------------------------------- CREATION DE U_DEPERIS50 ----------------------------------------------------------------------------------

-- METADONNEES
BEGIN;

-- 1.Documentation de l’unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_DEPERISPPT', 'AUTRE', 'NOMINAL', 'Intensité du dépérissement (avec DEPERIS)', 'Caractérise l''intensité du dépérissement de chaque placette en 6 classes (de 0 à 50% et plus)');

-- 2.Documentation des modalités
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('U_DEPERISPPT', '0', 1, 1, 1, '0%', 'Aucun arbre mort ou arbre avec un DEPERIS dégradé (D, E, F)')
, ('U_DEPERISPPT', '1', 2, 2, 1, 'moins de 20%', 'Moins de 20 % (exclu) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)')
, ('U_DEPERISPPT', '2', 3, 3, 1, 'entre 20 et 30%', 'Entre 20 % (inclus) et 30 % (exclu) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)')
, ('U_DEPERISPPT', '3', 4, 4, 1, 'entre 30 et 40%', 'Entre 30 % (inclus) et 40 % (exclu) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)')
, ('U_DEPERISPPT', '4', 5, 5, 1, 'entre 40 et 50%', 'Entre 40 % (inclus) et 50 % (exclu) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)')
, ('U_DEPERISPPT', '5', 6, 6, 1, '50% et plus', 'Au moins 50 % (inclus) d''arbres morts ou arbres avec un DEPERIS dégradé (D, E, F)');

-- 3.Documentation de la donnée
SELECT * FROM metaifn.ajoutdonnee('U_DEPERIS50', NULL, 'U_DEPERISPPT', 'AUTRE', NULL, 6, 'varchar(1)', 'CC', TRUE, TRUE, 
'Intensité du dépérissement (avec DEPERIS)', 
'Caractérise l''intensité du dépérissement d''une placette selon son taux d''arbres dépérissants (classés D, E ou F en DEPERIS)');

-- 4.Documentation de la colonne en base
SELECT * 
FROM metaifn.ajoutchamp('U_DEPERIS50', 'U_G3FORET', 'INV_EXP_NM', FALSE, 0, 17, 'varchar', 1);

SELECT * 
FROM metaifn.ajoutchamp('U_DEPERIS50', 'U_P3POINT', 'INV_EXP_NM', FALSE, 0, 17, 'varchar', 1);

UPDATE metaifn.afchamp 
SET calcin = 16, calcout = 17, validin = 16, validout = 17, defin = 16, defout = NULL  
WHERE famille = 'INV_EXP_NM' AND donnee = 'U_DEPERIS50';

SELECT *
FROM metaifn.afchamp 
WHERE famille = 'INV_EXP_NM' AND donnee = 'U_DEPERIS50';

-- 5. Affectation à un groupe d'utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe,
donnee)
VALUES ('DRIF', 'U_DEPERIS50');

COMMIT;


-- CALCUL DE LA DONNEE EN FORET DE PRODUCTION
-- CREATION DE LA DONNEE UTILISATEUR
BEGIN;

ALTER TABLE inv_exp_nm.u_g3foret 
ADD COLUMN U_DEPERIS50 character(1); 
COMMENT ON COLUMN inv_exp_nm.u_g3foret.U_DEPERIS50 IS 'Intensité du dépérissement' ;

COMMIT;

-- arbres morts de moins de 5 ans
BEGIN;

WITH MORTS AS
	(SELECT G3M.NPP, G3M.INCREF, SUM(G3M.WAC) AS W_MORTS, COUNT(*) AS NB_MORTS
		FROM INV_EXP_NM.G3MORTS G3M
		WHERE G3M.VEGET in ('5','C')
			AND DATEMORT = '1'
			AND LIB = '2'
			AND CAST(G3M.CLAD AS INTEGER) BETWEEN 23 AND 130
			AND G3M.INCREF BETWEEN 16 AND 17
		GROUP BY G3M.NPP, G3M.INCREF),
-- Arbres vivants avec déperissement (attention jointure à l'arbre et pas seulement npp, le comptage d'arbres était faux)
VIVANTS AS
	(SELECT G3A.NPP, G3A.INCREF, SUM(G3A.WAC) AS W_VIVANTS, COUNT(*) AS NB_VIVANTS
		FROM INV_EXP_NM.G3ARBRE G3A
		LEFT JOIN INV_EXP_NM.U_G3ARBRE UG3A ON (G3A.NPP = UG3A.NPP and G3A.A = UG3A.A)
		WHERE VEGET = '0'
			AND U_DEPERIS in ('A','B','C','D','E', 'F') 
			AND G3A.INCREF BETWEEN 16 AND 17
		GROUP BY G3A.NPP, G3A.INCREF),
-- Arbres vivants avec au moins 50% de déperissement
DEPERIS50 AS
	(SELECT G3A.NPP, G3A.INCREF, SUM(G3A.WAC) AS W_DEPERIS50, COUNT(*) as NB_DEPERIS50
		FROM INV_EXP_NM.G3ARBRE G3A
		LEFT JOIN INV_EXP_NM.U_G3ARBRE UG3A ON (G3A.NPP = UG3A.NPP and G3A.A = UG3A.A )
		WHERE VEGET = '0'
			AND U_DEPERIS in ('D','E', 'F') 
			AND G3A.INCREF BETWEEN 16 AND 17
		GROUP BY G3A.NPP, G3A.INCREF),		
---elements intermédiaires pour calculer le ratio : 		
--calcul dénominateur
DENOM AS (
	SELECT 
		CASE 
			WHEN VIVANTS.NPP IS NOT NULL THEN VIVANTS.NPP ELSE MORTS.NPP END NPP,
		CASE
			WHEN VIVANTS.INCREF IS NOT NULL THEN VIVANTS.INCREF ELSE MORTS.INCREF END INCREF,
	COALESCE(VIVANTS.W_VIVANTS,0) AS VIVANTS, COALESCE(MORTS.W_MORTS, 0) AS MORTS, 
	COALESCE(VIVANTS.W_VIVANTS,0) + COALESCE(MORTS.W_MORTS, 0) AS DENOM 
	FROM VIVANTS
	FULL JOIN MORTS ON VIVANTS.NPP = MORTS.NPP),	  
--calcul numérateur	  
NUMERATEUR AS (
	SELECT 
	CASE
		WHEN MORTS.NPP IS NULL THEN DEPERIS50.NPP ELSE MORTS.NPP END NPP,
	CASE
		WHEN MORTS.INCREF IS NULL THEN DEPERIS50.INCREF ELSE MORTS.INCREF END INCREF,
	COALESCE(MORTS.W_MORTS,0) MORTS, COALESCE(DEPERIS50.W_DEPERIS50, 0) DEPERIS50, 
	COALESCE(DEPERIS50.W_DEPERIS50, 0) + COALESCE(MORTS.W_MORTS, 0) AS NUMER
	FROM DEPERIS50
	FULL JOIN MORTS ON DEPERIS50.NPP = MORTS.NPP),		
-- TEST : SELECT npp1, denom.incref1 , npp, denom.incref, case when denom = 0  then 0 else coalesce(numer,0) / denom  * 100 end as ratio from denom left join numerateur  using (npp1, npp)
-- Calcul du ratio de déperissement  (attention aux jointures  pour avoir  aussi les placettes 100% morts  FULL JOIN et pas LEFT JOIN)
RESULTAT AS (
	SELECT DENOM.NPP, DENOM.INCREF, DENOM, COALESCE(NUMER,0) AS NUMERATEUR,
	COALESCE(NUMER,0)/DENOM * 100 AS RATIO
	FROM DENOM
	FULL JOIN NUMERATEUR ON DENOM.NPP = NUMERATEUR.NPP)
UPDATE inv_exp_nm.u_g3foret AS ug3f
SET U_DEPERIS50 =
	CASE
					WHEN RATIO = 0 THEN '0'
					WHEN RATIO > 0 AND RATIO < 20 THEN '1'
					WHEN RATIO >= 20 AND RATIO < 30 THEN '2'
					WHEN RATIO >= 30 AND RATIO < 40 THEN '3'
					WHEN RATIO >= 40 AND RATIO < 50 THEN '4'
					WHEN RATIO >= 50 THEN '5'
					ELSE NULL
	END 
FROM RESULTAT
WHERE ug3f.incref BETWEEN 16 AND 17 
	AND RESULTAT.NPP = UG3F.NPP 
	AND RESULTAT.INCREF = UG3F.INCREF;

-- Contrôle
SELECT NPP, INCREF, U_DEPERIS50
FROM inv_exp_nm.u_g3foret
WHERE INCREF BETWEEN 16 AND 17
		--AND DEPERIS50 IS NOT NULL
ORDER BY INCREF, NPP;


-- CALCUL DE LA DONNEE EN PEUPLERAIES
-- CREATION DE LA DONNEE UTILISATEUR
BEGIN;

ALTER TABLE inv_exp_nm.u_p3point 
ADD COLUMN U_DEPERIS50 character(1); 
COMMENT ON COLUMN inv_exp_nm.u_p3point.U_DEPERIS50 IS 'Intensité du dépérissement' ;

COMMIT;

-- arbres morts de moins de 5 ans
BEGIN;

WITH MORTS AS
	(SELECT P3M.NPP, P3M.INCREF, SUM(P3M.WAC) AS W_MORTS, COUNT(*) AS NB_MORTS
		FROM INV_EXP_NM.P3MORTS P3M
		WHERE P3M.VEGET in ('5','C')
			AND DATEMORT = '1'
			AND LIB = '2'
			AND CAST(P3M.CLAD AS INTEGER) BETWEEN 23 AND 130
			AND P3M.INCREF BETWEEN 16 AND 17
		GROUP BY P3M.NPP, P3M.INCREF),
-- Arbres vivants avec déperissement
VIVANTS AS
	(SELECT P3A.NPP, P3A.INCREF, SUM(P3A.WAC) AS W_VIVANTS, COUNT(*) NB_VIVANTS
		FROM INV_EXP_NM.P3ARBRE P3A
		LEFT JOIN INV_EXP_NM.U_P3ARBRE UP3A ON (P3A.NPP = UP3A.NPP AND P3A.A = UP3A.A)
		WHERE VEGET = '0'
			AND U_DEPERIS in ('A','B','C','D','E', 'F')
			AND P3A.INCREF BETWEEN 16 AND 17
		GROUP BY P3A.NPP, P3A.INCREF),
-- Arbres vivants avec au moins 50% de déperissement
DEPERIS50 AS
	(SELECT P3A.NPP, P3A.INCREF, SUM(P3A.WAC) AS W_DEPERIS50, COUNT(*) NB_DEPERIS50
		FROM INV_EXP_NM.P3ARBRE P3A
		LEFT JOIN INV_EXP_NM.U_P3ARBRE UP3A ON (P3A.NPP = UP3A.NPP AND P3A.A = UP3A.A)
		WHERE VEGET = '0'
			AND U_DEPERIS in ('D','E', 'F')
			AND P3A.INCREF BETWEEN 16 AND 17
		GROUP BY P3A.NPP, P3A.INCREF),
---elements intermédiaires pour calculer le ratio : 		
--calcul dénominateur
DENOM AS (
	SELECT 
		CASE 
			WHEN VIVANTS.NPP IS NOT NULL THEN VIVANTS.NPP ELSE MORTS.NPP END NPP,
		CASE
			WHEN VIVANTS.INCREF IS NOT NULL THEN VIVANTS.INCREF ELSE MORTS.INCREF END INCREF,
	COALESCE(VIVANTS.W_VIVANTS,0) AS VIVANTS, COALESCE(MORTS.W_MORTS, 0) AS MORTS, 
	COALESCE(VIVANTS.W_VIVANTS,0) + COALESCE(MORTS.W_MORTS, 0) AS DENOM 
	FROM VIVANTS
	FULL JOIN MORTS ON VIVANTS.NPP = MORTS.NPP),	  
--calcul numérateur	  
NUMERATEUR AS (
	SELECT 
	CASE
		WHEN MORTS.NPP IS NULL THEN DEPERIS50.NPP ELSE MORTS.NPP END NPP,
	CASE
		WHEN MORTS.INCREF IS NULL THEN DEPERIS50.INCREF ELSE MORTS.INCREF END INCREF,
	COALESCE(MORTS.W_MORTS,0) MORTS, COALESCE(DEPERIS50.W_DEPERIS50, 0) DEPERIS50, 
	COALESCE(DEPERIS50.W_DEPERIS50, 0) + COALESCE(MORTS.W_MORTS, 0) AS NUMER
	FROM DEPERIS50
	FULL JOIN MORTS ON DEPERIS50.NPP = MORTS.NPP),		
-- Calcul du ratio de déperissement
RESULTAT AS (
	SELECT DENOM.NPP, DENOM.INCREF, DENOM, COALESCE(NUMER,0) AS NUMERATEUR,
	CASE
		WHEN COALESCE(NUMER,0) > 0 THEN COALESCE(NUMER,0)/DENOM * 100 ELSE 0 END RATIO
	FROM DENOM
	FULL JOIN NUMERATEUR ON DENOM.NPP = NUMERATEUR.NPP)	
UPDATE inv_exp_nm.u_p3point AS up3p
SET U_DEPERIS50 =
	CASE
					WHEN RATIO = 0 THEN '0'
					WHEN RATIO > 0 AND RATIO < 20 THEN '1'
					WHEN RATIO >= 20 AND RATIO < 30 THEN '2'
					WHEN RATIO >= 30 AND RATIO < 40 THEN '3'
					WHEN RATIO >= 40 AND RATIO < 50 THEN '4'
					WHEN RATIO >= 50 THEN '5'
					ELSE NULL
	END 
FROM RESULTAT
WHERE up3p.incref BETWEEN 16 AND 17 
	AND RESULTAT.NPP = UP3P.NPP 
	AND RESULTAT.INCREF = UP3P.INCREF;


SELECT NPP, INCREF, U_DEPERIS50
FROM inv_exp_nm.u_p3point
WHERE INCREF BETWEEN 16 AND 17
		--AND DEPERIS50 IS NOT NULL
ORDER BY INCREF, NPP;
	

