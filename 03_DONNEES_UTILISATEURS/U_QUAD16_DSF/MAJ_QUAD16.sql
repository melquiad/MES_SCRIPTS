-- importation de la couche géographique dans la base
shp2pgsql.exe -s 931007 -D -i -I -W latin1 "//fs-nogent/Partage_Ressources/2_Donnees_Utilisateurs/U_QUAD16_DSF/quadrats_l93.shp" public.quadrat | psql.exe -h inv-exp.ign.fr -U LGay -d exploitation

-- création de la colonne dans la table u_e2point
BEGIN;

ALTER TABLE INV_EXP_NM.U_E2POINT ADD COLUMN U_QUAD16_DSF CHAR(9);

COMMENT ON COLUMN INV_EXP_NM.U_E2POINT.U_QUAD16_DSF IS 'Quadrats 16x16 km du DSF';

-- calcul de la donnée u_quad16_dsf
BEGIN; 

WITH croise AS (
	SELECT c1.npp
	, CASE
		WHEN i.gid IS NOT NULL THEN RTRIM(code)
		ELSE '0'
	END AS mode_quadrat
	FROM inv_exp_nm.e1coord c1
	LEFT JOIN public.quadrat i ON ST_Intersects (c1.geom, i.geom)
)

-- SELECT *
-- FROM CROISE
-- WHERE MODE_QUADRAT != '0'

UPDATE INV_EXP_NM.U_E2POINT P
SET U_QUAD16_DSF = C.MODE_QUADRAT
FROM CROISE C
WHERE P.NPP = C.NPP
	AND INCREF BETWEEN 0 AND 16;


-- contrôle
SELECT INCREF, U_QUAD16_DSF
FROM INV_EXP_NM.U_E2POINT
WHERE U_QUAD16_DSF IS NULL
	AND INCREF BETWEEN 0 AND 16

SELECT U_QUAD16_DSF, count(*)
FROM inv_exp_nm.u_e2point
GROUP BY U_QUAD16_DSF;

COMMIT;

-- suppression de la couche géographique
DROP TABLE public.quadrat; 

-- mise à jour des métadonnées
UPDATE metaifn.afchamp
SET calcin = 0, calcout = 16, validin = 0, validout = 16
WHERE famille = 'INV_EXP_NM' and donnee = 'U_QUAD16_DSF';




-- Mise à jour incref 17
-- importation de la couche géographique dans la base
shp2pgsql.exe -s 931007 -D -i -I -W latin1 "//fs-nogent/Partage_Ressources/2_Donnees_Utilisateurs/U_QUAD16_DSF/quadrats_l93.shp" public.quadrat | psql.exe -h inv-exp.ign.fr -U LGay -d exploitation

-- calcul de la donnée u_quad16_dsf
BEGIN; 

WITH croise AS (
	SELECT c1.npp
	, CASE
		WHEN i.gid IS NOT NULL THEN RTRIM(code)
		ELSE '0'
	END AS mode_quadrat
	FROM inv_exp_nm.e1coord c1
	LEFT JOIN public.quadrat i ON ST_Intersects (c1.geom, i.geom)
	WHERE incref = 17
)

-- SELECT *
-- FROM CROISE
-- WHERE MODE_QUADRAT != '0'

UPDATE INV_EXP_NM.U_E2POINT P
SET U_QUAD16_DSF = C.MODE_QUADRAT
FROM CROISE C
WHERE P.NPP = C.NPP
	AND INCREF = 17;


-- contrôle
SELECT INCREF, U_QUAD16_DSF
FROM INV_EXP_NM.U_E2POINT
WHERE U_QUAD16_DSF IS NULL
	AND INCREF = 17
	
SELECT incref, count(U_QUAD16_DSF)
FROM INV_EXP_NM.U_E2POINT
GROUP BY INCREF;

SELECT U_QUAD16_DSF, count(*)
FROM inv_exp_nm.u_e2point
GROUP BY U_QUAD16_DSF;

COMMIT;

-- suppression de la couche géographique
DROP TABLE public.quadrat; 

-- mise à jour des métadonnées
UPDATE metaifn.afchamp
SET calcin = 0, calcout = 17, validin = 0, validout = 17
WHERE famille = 'INV_EXP_NM' and donnee = 'U_QUAD16_DSF';


-- Mise à jour incref 18
-- importation de la couche géographique dans la base
shp2pgsql -s 931007 -D -i -I -W latin1 '/home/lhaugomat/Documents/ECHANGES/DONNEES_UTILISATEURS/U_QUAD16_DSF/quadrats_l93.shp' public.quadrats_l93 | psql service=inv-local 
shp2pgsql -s 931007 -D -i -I -W latin1 '/home/lhaugomat/Documents/ECHANGES/DONNEES_UTILISATEURS/U_QUAD16_DSF/quadrats_l93.shp' public.quadrats_l93 | psql service=inv-dev
shp2pgsql -s 931007 -D -i -I -W latin1 '/home/lhaugomat/Documents/ECHANGES/DONNEES_UTILISATEURS/U_QUAD16_DSF/quadrats_l93.shp' public.quadrats_l93 | psql service=test-exp
shp2pgsql -s 931007 -D -i -I -W latin1 '/home/lhaugomat/Documents/ECHANGES/DONNEES_UTILISATEURS/U_QUAD16_DSF/quadrats_l93.shp' public.quadrats_l93 | psql service=exp

-- calcul de la donnée u_quad16_dsf
BEGIN; 
-- ROLLBACK;

WITH croise AS
	(
	SELECT c1.npp
	, CASE
		WHEN i.gid IS NOT NULL THEN RTRIM(code)
		ELSE '0'
	END AS mode_quadrat
	FROM inv_exp_nm.e1coord c1
	LEFT JOIN public.quadrats_l93 i ON ST_Intersects (c1.geom, i.geom)
	)
-- SELECT *
-- FROM CROISE
-- WHERE MODE_QUADRAT != '0'
UPDATE INV_EXP_NM.U_E2POINT P
SET U_QUAD16_DSF = C.MODE_QUADRAT
FROM CROISE C
WHERE P.NPP = C.NPP
	AND INCREF = 18;


-- contrôle
SELECT INCREF, U_QUAD16_DSF
FROM INV_EXP_NM.U_E2POINT
WHERE U_QUAD16_DSF IS NULL
	AND INCREF = 18;
	
SELECT incref, count(U_QUAD16_DSF)
FROM INV_EXP_NM.U_E2POINT
GROUP BY INCREF;

SELECT U_QUAD16_DSF, count(*)
FROM inv_exp_nm.u_e2point
GROUP BY U_QUAD16_DSF;

COMMIT;

-- suppression de la couche géographique
DROP TABLE public.quadrats_l93; 

-- mise à jour des métadonnées
UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18
WHERE famille = 'INV_EXP_NM' and donnee = 'U_QUAD16_DSF';



