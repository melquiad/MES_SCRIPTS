


-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('APB', NULL, 'IN_ZONE', 'IFN', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, $$Arrêtés préfectoraux de protection de biotope (INPN 08/2024)$$, $$Point d inventaire dans un arrêté de protection de biotope$$);

-- partie champ
SELECT * FROM metaifn.ajoutchamp('APB', 'E2POINT', 'INV_EXP_NM', FALSE, 0, 18, 'bpchar', 1);
--              ou
SELECT * FROM metaifn.ajoutchamp('APB'::varchar, 'E2POINT'::varchar, 'INV_EXP_NM'::varchar, FALSE::boolean, 1, 18, 'bpchar'::varchar, 1::int4);



-- creation du champ dans la table
	--> en base d'exploitation
ALTER TABLE inv_exp_nm.e2point ADD COLUMN APB CHAR(1);
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.e2point ADD COLUMN APB CHAR(1);
		
-- partie utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'APB');


-- Calcul de la donnée par recopie de la donnée U
BEGIN;

UPDATE inv_exp_nm.e2point p
SET apb = c.u_apb
FROM inv_exp_nm.u_e2point c
WHERE p.npp = c.npp;


COMMIT;



-- Mise à jour campagne 2024 (incref 19)

WITH croise AS (
SELECT c1.npp
,	CASE WHEN i.gid IS NOT NULL THEN '1'
	ELSE '0'
	END AS dedans
FROM inv_exp_nm.e1coord c1
--LEFT JOIN sig_inpn.apb i
LEFT JOIN carto_inpn.apb i
ON ST_Intersects(c1.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p
SET apb = c.dedans
FROM croise c
WHERE p.npp = c.npp AND p.incref = 19;


UPDATE metaifn.afchamp
SET calcin = 0, calcout = 19, validin = 0, validout = 19, defin = 0, defout = NULL
WHERE famille = 'INV_EXP_NM'
AND donnee = 'APB';

UPDATE metaifn.addonnee
SET definition = $$Arrêtés préfectoraux de protection de biotope (INPN 08/2024)$$
WHERE donnee = 'APB';

-- suppression de l'ancienne donnée U et de ses métadonnées
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.u_e2point DROP COLUMN u_apb;
	--> en base d'exploitation
ALTER TABLE inv_exp_nm.u_e2point DROP COLUMN u_apb;

DELETE FROM metaifn.afchamp WHERE donnee = 'U_APB';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_APB';
DELETE FROM metaifn.abmode WHERE unite = 'U_APB';
DELETE FROM metaifn.abunite WHERE unite = 'U_APB';


-- contrôle du nombre de points dans APB par incref
SELECT count(apb), incref
FROM inv_exp_nm.e2point
WHERE apb = '1'
GROUP BY incref, apb
ORDER BY incref DESC;








