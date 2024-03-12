-- Création donnée U_TAILFORET
-- Calcul de la taille des massifs

-- Documentation de la donnée
SELECT *
FROM metaifn.ajoutdonnee('U_TAILFORET', NULL, 'U_TAILMASSIF', 'AUTRE',
NULL, 4, 'char(2)', 'CC', TRUE, TRUE, 'Taille du polyg  for ds leq. se situe point d''inv. V°(01/24)',
'Taille du polygone foret ds lequel se situe le point d''inventaire : basée sur la BD forêt V2, avec dépts actualisés dispo au 20/10/2023. Un polyg : fusion des polyg. adjacents de la BD forêt (V2 : 01/24)  : couche IG îlots ');

--Documentation de la colonne en base
SELECT *
FROM metaifn.ajoutchamp('U_TAILFORET', 'U_E2POINT', 'INV_EXP_NM',
FALSE, 0, 17, 'bpchar', 2);

-- Affectation à un groupe d'utilisateurs
/*
SET ROLE = exploitation_admin;
RESET ROLE;
*/
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe,
donnee)
VALUES ('DIRSO', 'U_TAILFORET');

--Création de la donnée U
ALTER TABLE inv_exp_nm.u_e2point
ADD COLUMN U_TAILFORET CHAR(2);

-- 2. Calcul de la donnée : création des différentes classes
CREATE TABLE public.croise (
	npp TEXT,
	id TEXT,
	id_massif TEXT,
	surf_ilot_bdforet_ha FLOAT8);

\COPY public.croise FROM '/home/lhaugomat/Documents/MES_SCRIPTS/nathalie_derriere/U_TAILMASSIF/U_TAILFORET/ptsilots.csv' WITH CSV HEADER DELIMITER ',' NULL AS '';

BEGIN;

UPDATE inv_exp_nm.u_e2point p
SET U_TAILFORET = CASE 
		WHEN c.id_massif IS NULL AND c.surf_ilot_bdforet_ha = 0 THEN 'X'
		WHEN c.surf_ilot_bdforet_ha < 2.25 THEN '00'
		WHEN c.surf_ilot_bdforet_ha >= 2.25 AND c.surf_ilot_bdforet_ha < 4 THEN '01'
		WHEN c.surf_ilot_bdforet_ha >= 4 AND c.surf_ilot_bdforet_ha < 25 THEN '02'
		WHEN c.surf_ilot_bdforet_ha >= 25 AND c.surf_ilot_bdforet_ha < 50 THEN '03'
		WHEN c.surf_ilot_bdforet_ha >= 50 AND c.surf_ilot_bdforet_ha < 100 THEN '04'
		WHEN c.surf_ilot_bdforet_ha >= 100 AND c.surf_ilot_bdforet_ha < 200 THEN '05'
		WHEN c.surf_ilot_bdforet_ha >= 200 AND c.surf_ilot_bdforet_ha < 300 THEN '06'
		WHEN c.surf_ilot_bdforet_ha >= 300 AND c.surf_ilot_bdforet_ha < 400 THEN '07'
		WHEN c.surf_ilot_bdforet_ha >= 400 AND c.surf_ilot_bdforet_ha < 450 THEN '08'
		WHEN c.surf_ilot_bdforet_ha >= 450 AND c.surf_ilot_bdforet_ha < 500 THEN '09'
		WHEN c.surf_ilot_bdforet_ha >= 500 AND c.surf_ilot_bdforet_ha < 550 THEN '10'
		WHEN c.surf_ilot_bdforet_ha >= 550 AND c.surf_ilot_bdforet_ha < 600 THEN '11'
		WHEN c.surf_ilot_bdforet_ha >= 600 AND c.surf_ilot_bdforet_ha < 700 THEN '12'
		WHEN c.surf_ilot_bdforet_ha >= 700 AND c.surf_ilot_bdforet_ha < 800 THEN '13'
		WHEN c.surf_ilot_bdforet_ha >= 800 AND c.surf_ilot_bdforet_ha < 900 THEN '14'
		WHEN c.surf_ilot_bdforet_ha >= 900 AND c.surf_ilot_bdforet_ha < 1000 THEN '15'
		WHEN c.surf_ilot_bdforet_ha >= 1000 AND c.surf_ilot_bdforet_ha < 2000 THEN '16'
		WHEN c.surf_ilot_bdforet_ha >= 2000 AND c.surf_ilot_bdforet_ha < 3000 THEN '17'
		WHEN c.surf_ilot_bdforet_ha >= 3000 AND c.surf_ilot_bdforet_ha < 4000 THEN '18'
		WHEN c.surf_ilot_bdforet_ha >= 4000 AND c.surf_ilot_bdforet_ha < 4500 THEN '19'
		WHEN c.surf_ilot_bdforet_ha >= 4500 AND c.surf_ilot_bdforet_ha < 5000 THEN '20'
		WHEN c.surf_ilot_bdforet_ha >= 5000 AND c.surf_ilot_bdforet_ha < 5500 THEN '21'
		WHEN c.surf_ilot_bdforet_ha >= 5500 AND c.surf_ilot_bdforet_ha < 6000 THEN '22'
		WHEN c.surf_ilot_bdforet_ha >= 6000 AND c.surf_ilot_bdforet_ha < 7000 THEN '23'
		WHEN c.surf_ilot_bdforet_ha >= 7000 AND c.surf_ilot_bdforet_ha < 8000 THEN '24'
		WHEN c.surf_ilot_bdforet_ha >= 8000 AND c.surf_ilot_bdforet_ha < 9000 THEN '25'
		WHEN c.surf_ilot_bdforet_ha >= 9000 AND c.surf_ilot_bdforet_ha < 10000 THEN '26'
		WHEN c.surf_ilot_bdforet_ha >= 10000 AND c.surf_ilot_bdforet_ha < 20000 THEN '27'
		WHEN c.surf_ilot_bdforet_ha >= 20000 AND c.surf_ilot_bdforet_ha < 30000 THEN '28'
		WHEN c.surf_ilot_bdforet_ha >= 30000 AND c.surf_ilot_bdforet_ha < 40000 THEN '29'
		WHEN c.surf_ilot_bdforet_ha >= 40000 AND c.surf_ilot_bdforet_ha < 45000 THEN '30'
		WHEN c.surf_ilot_bdforet_ha >= 45000 AND c.surf_ilot_bdforet_ha < 50000 THEN '31'
		WHEN c.surf_ilot_bdforet_ha >= 50000 AND c.surf_ilot_bdforet_ha < 55000 THEN '32'
		WHEN c.surf_ilot_bdforet_ha >= 55000 AND c.surf_ilot_bdforet_ha < 60000 THEN '33'
		WHEN c.surf_ilot_bdforet_ha >= 60000 AND c.surf_ilot_bdforet_ha < 70000 THEN '34'
		WHEN c.surf_ilot_bdforet_ha >= 70000 AND c.surf_ilot_bdforet_ha < 80000 THEN '35'
		WHEN c.surf_ilot_bdforet_ha >= 80000 AND c.surf_ilot_bdforet_ha < 90000 THEN '36'
		WHEN c.surf_ilot_bdforet_ha >= 90000 AND c.surf_ilot_bdforet_ha < 100000 THEN '37'
		WHEN c.surf_ilot_bdforet_ha >= 100000 AND c.surf_ilot_bdforet_ha < 200000 THEN '38'
		WHEN c.surf_ilot_bdforet_ha >= 200000 AND c.surf_ilot_bdforet_ha < 300000 THEN '39'
		WHEN c.surf_ilot_bdforet_ha >= 300000 AND c.surf_ilot_bdforet_ha < 400000 THEN '40'
		WHEN c.surf_ilot_bdforet_ha >= 400000 AND c.surf_ilot_bdforet_ha < 450000 THEN '41'
		WHEN c.surf_ilot_bdforet_ha >= 450000 AND c.surf_ilot_bdforet_ha < 500000 THEN '42'
		WHEN c.surf_ilot_bdforet_ha >= 500000 AND c.surf_ilot_bdforet_ha < 550000 THEN '43'
		WHEN c.surf_ilot_bdforet_ha >= 550000 AND c.surf_ilot_bdforet_ha < 600000 THEN '44'
		WHEN c.surf_ilot_bdforet_ha >= 600000 AND c.surf_ilot_bdforet_ha < 700000 THEN '45'
		WHEN c.surf_ilot_bdforet_ha >= 700000 AND c.surf_ilot_bdforet_ha < 800000 THEN '46'
		WHEN c.surf_ilot_bdforet_ha >= 800000 AND c.surf_ilot_bdforet_ha < 900000 THEN '47'
		WHEN c.surf_ilot_bdforet_ha >= 900000 AND c.surf_ilot_bdforet_ha < 1000000 THEN '48'
		WHEN c.surf_ilot_bdforet_ha >= 1000000 THEN '49'
		ELSE 'X'
	END
FROM croise c
WHERE p.npp = c.npp;

SELECT incref, COUNT(U_TAILFORET)
FROM INV_EXP_NM.U_E2POINT
GROUP BY incref ORDER BY incref;

SELECT incref, U_TAILFORET, COUNT(U_TAILFORET)
FROM INV_EXP_NM.U_E2POINT
GROUP BY incref, U_TAILFORET ORDER BY incref, U_TAILFORET;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 17, validin = 0, validout = 17, defin = 0, defout = 17
WHERE famille = 'INV_EXP_NM'
AND format IN ('U_E2POINT')
AND donnee = 'U_TAILFORET';

