

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('ZICO', NULL, 'IN_ZONE', 'IFN', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, $$Point en Zone importance pour la conservation des oiseaux.$$, $$Point en Zone importance pour la conservation des oiseaux(ZICO 1994).$$);


-- partie champ
SELECT * FROM metaifn.ajoutchamp('ZICO', 'E2POINT', 'INV_EXP_NM', FALSE, 0, 19, 'bpchar', 1);
	-- ou
SELECT * FROM metaifn.ajoutchamp('ZICO'::varchar, 'E2POINT'::varchar, 'INV_EXP_NM'::varchar, FALSE::boolean, 1, 19, 'bpchar'::varchar, 1::int4);


-- creation du champ dans la table
ALTER TABLE inv_exp_nm.e2point ADD COLUMN ZICO CHAR(1);
	-- en base de production
ALTER FOREIGN TABLE inv_exp_nm.e2point ADD COLUMN ZICO CHAR(1);
		
-- partie utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'ZICO');

-- Calcul de la donnée
BEGIN;

UPDATE inv_exp_nm.e2point p
SET zico = c.u_zico
FROM inv_exp_nm.u_e2point c
WHERE p.npp = c.npp;

COMMIT;

-- suppression de la donnée U_ZICO et de ses métadonnées
DELETE FROM metaifn.afcalcul WHERE champ = 6468;
DELETE FROM metaifn.afchamp WHERE donnee = 'U_ZICO';
DELETE FROM metaifn.addonnee WHERE unite = 'U_ZICO';
DELETE FROM metaifn.abmode WHERE unite = 'U_ZICO';
DELETE FROM metaifn.abunite WHERE unite = 'U_ZICO';

ALTER TABLE inv_exp_nm.u_e2point DROP COLUMN U_ZICO;
-- en base de production
ALTER FOREIGN TABLE inv_exp_nm.e2point DROP COLUMN U_ZICO;


-- contrôle du nombre en points en ZICO par incref
SELECT zico, incref, count(zico)
FROM inv_exp_nm.e2point
--WHERE zico = '1'
GROUP BY incref, zico
ORDER BY incref DESC;




