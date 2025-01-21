
-- MAJ 2023 (incref 18)

-- invite de commande Windows - import shapefile
shp2pgsql -s 2154 -D -i -I ~/Documents/ECHANGES/SIG/uep_FD_ligerienne_encodage.shp public.strn_onf | psql service=inv-local
shp2pgsql -s 2154 -D -i -I ~/Documents/ECHANGES/SIG/uep_FD_ligerienne_encodage.shp public.strn_onf | psql service=inv-bdd
shp2pgsql -s 931007 -D -i -I ~/Documents/ECHANGES/SIG/uep_FD_ligerienne_encodage.shp public.strn_onf | psql service=test-exp
shp2pgsql -s 931007 -D -i -I ~/Documents/ECHANGES/SIG/uep_FD_ligerienne_encodage.shp public.strn_onf | psql service=exp

BEGIN;

SELECT INCREF, COUNT(U_STRN_ONF)
FROM INV_EXP_NM.U_E2POINT
GROUP BY INCREF ORDER BY INCREF;

WITH croise AS (
	SELECT c1.npp
	, CASE
		WHEN i.gid IS NOT NULL THEN CAST(CCOD_STRN as varchar(1))
		ELSE '0'
	END AS mode
	FROM inv_exp_nm.e1coord c1
	LEFT JOIN inv_exp_nm.e1point e1 ON c1.npp = e1.npp
	LEFT JOIN public.strn_onf i ON ST_Intersects (c1.geom, i.geom)
	WHERE incref = 18
)
UPDATE inv_exp_nm.u_e2point p
SET U_STRN_ONF = c.mode
FROM croise c
WHERE p.npp = c.npp AND p.incref = 18;

SELECT U_STRN_ONF, u_inv_facon
FROM inv_exp_nm.u_e2point
where U_STRN_ONF is null and not u_inv_facon;

UPDATE metaifn.afchamp
SET calcout = 18, validout = 18
WHERE famille = 'INV_EXP_NM'
AND donnee = 'U_STRN_ONF';

COMMIT;

SELECT U_STRN_ONF, count(*)
FROM inv_exp_nm.u_e2point
group by U_STRN_ONF;

DROP TABLE public.strn_onf;
