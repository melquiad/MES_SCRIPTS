

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('BIOGEO2002', NULL, 'BIOGEO', 'IFN', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, 'Domaines biogéographiques (sens UE)', 'Domaines biogéographiques atlantique, continental, méditérannéen, alpin définis par l UE pour la directive habitat, faune, flore. Couche IG INPN 2017, datée 2002');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('BIOGEO2002', 'E2POINT', 'INV_EXP_NM', FALSE, 0, 19, 'bpchar', 1);


--création de BIOGEO2002 dans E2POINT
	--> en base d'exploitation
ALTER TABLE inv_exp_nm.e2point ADD COLUMN biogeo2002 CHAR(1);
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.e2point ADD COLUMN biogeo2002 CHAR(1);

-- remplissage de la donnée par copie de U_BIOGEO2002
UPDATE inv_exp_nm.e2point p
SET biogeo2002 = c.u_biogeo2002
FROM inv_exp_nm.u_e2point c
WHERE p.npp = c.npp

/*--controles
SELECT *
FROM metaifn.afchamp
WHERE famille='INV_EXP_NM'
AND format='TE2POINT'
ORDER BY position DESC;
*/


-- MISE À JOUR CAMPAGNE 2024
-- import de la couche depuis une fenêtre de commandes linux
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp public.regbiofr | psql service=inv-local
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp public.regbiofr | psql service=inv-bdd
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp public.regbiofr | psql service=test-exp
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/regbiofr/regbiofr.shp public.regbiofr | psql service=exp


-- réalisation du croisement
WITH biog AS (
    SELECT p2.npp, rb.domaine::bpchar AS biog
    FROM inv_exp_nm.e1coord c1
    INNER JOIN inv_exp_nm.e2point p2 USING (npp)
    INNER JOIN public.regbiofr rb ON ST_Intersects(c1.geom, rb.geom)
    WHERE p2.incref = 19
			)
UPDATE inv_exp_nm.e2point p2
SET biogeo2002 = b.biog
FROM biog b
WHERE p2.npp = b.npp;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 19, validin = 0, validout = 19, defin = 0, defout = NULL
WHERE famille = 'INV_EXP_NM'
AND format = 'TE2POINT'
AND donnee = 'BIOGEO2002';

DROP TABLE public.regbiofr;


-- Correction des points NULL
SELECT npp, biogeo2002
FROM inv_exp_nm.e2point
WHERE incref = 19
AND biogeo2002 IS NULL;


-- suppression de l'ancienne donnée U
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.u_e2point DROP COLUMN u_biogeo2002;
	--> en base d'exploitation
ALTER TABLE inv_exp_nm.u_e2point DROP COLUMN u_biogeo2002;



--controles
SELECT count(biogeo2002), biogeo2002, incref
FROM inv_exp_nm.e2point
GROUP BY incref, biogeo2002
ORDER BY incref DESC;








