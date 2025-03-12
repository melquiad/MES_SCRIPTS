


-- MISE À JOUR CAMPAGNE 2023
-- import de la couche depuis une fenêtre de commandes linux
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp public.regbiofr | psql -p 5433 -d inventaire -U lhaugomat
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp public.regbiofr | psql service=inv-bdd
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp public.regbiofr | psql service=test-exp
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp public.regbiofr | psql service=exp

BEGIN;
ROLLBACK;

-- réalisation du croisement
WITH biog AS (
    SELECT p2.npp, rb.domaine::bpchar AS biog
    FROM inv_exp_nm.e1coord c1
    INNER JOIN inv_exp_nm.e2point p2 USING (npp)
    INNER JOIN public.regbiofr rb ON ST_Intersects(c1.geom, rb.geom)
    WHERE p2.incref = 18
)
UPDATE inv_exp_nm.u_e2point p2
SET u_biogeo2002 = b.biog
FROM biog b
WHERE p2.npp = b.npp;

UPDATE metaifn.afchamp
SET calcout = 18, validout = 18
WHERE famille = 'INV_EXP_NM'
AND format = 'U_E2POINT'
AND donnee = 'U_BIOGEO2002';

DROP TABLE public.regbiofr;

COMMIT;

-- Correction des points NULL

SELECT NPP, U_BIOGEO2002
FROM INV_EXP_NM.U_E2POINT
WHERE INCREF = 18 AND U_BIOGEO2002 IS NULL

--BEGIN;
--UPDATE INV_EXP_NM.U_E2POINT
--SET U_BIOGEO2002 = 2
--WHERE NPP = '21-57-247-1-028T'

--SELECT NPP, U_BIOGEO2002
--FROM INV_EXP_NM.U_E2POINT
--WHERE NPP = '21-57-247-1-028T'

--COMMIT;