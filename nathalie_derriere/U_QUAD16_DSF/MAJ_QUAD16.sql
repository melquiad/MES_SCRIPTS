
DROP TABLE public.quadrat;
DROP TABLE croise;

-- importation de la couche géographique dans la base
shp2pgsql -s 931007 -D -i -I -W utf-8 '/home/lhaugomat/Documents/MES_SCRIPTS/nathalie_derriere/U_QUAD16_DSF/quadrats_l93.shp' public.quadrat_l93 | psql -d inventaire -p 5433 

-- création de la colonne dans la table u_e2point
BEGIN;

ALTER TABLE INV_EXP_NM.U_E2POINT ADD COLUMN U_QUAD16_DSF CHAR(9);

COMMENT ON COLUMN INV_EXP_NM.U_E2POINT.U_QUAD16_DSF IS 'Quadrats 16x16 km du DSF';

-- calcul de la donnée u_quad16_dsf
BEGIN; 

--CREATE TEMPORARY TABLE croise AS (
WITH croise AS (
	SELECT c1.npp
	, CASE
		WHEN i.gid IS NOT NULL THEN RTRIM(code)
		ELSE '0'
	END AS mode_quadrat
	FROM inv_exp_nm.e1coord c1
	LEFT JOIN public.quadrat_l93 i ON ST_Intersects (c1.geom,i.geom)
)
UPDATE inv_exp_nm.u_e2point p
SET u_quad_dsf = c.mode_quadrat
FROM croise c
WHERE p.npp = c.npp
	AND incref BETWEEN 0 AND 18;

-- contrôles
--SELECT * FROM croise WHERE mode_quadrat = '0';

SELECT INCREF, U_QUAD16_DSF
FROM INV_EXP_NM.U_E2POINT
WHERE U_QUAD16_DSF IS NULL
	AND INCREF BETWEEN 0 AND 18;

SELECT u_quad16_dsf , count(*)
FROM inv_exp_nm.u_e2point
WHERE incref BETWEEN 0 AND 18
GROUP BY u_quad16_dsf;

COMMIT;

-- suppression de la couche géographique
DROP TABLE public.quadrat_l93; 

-- mise à jour des métadonnées
UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18
WHERE famille = 'INV_EXP_NM' and donnee = 'U_QUAD16_DSF';


