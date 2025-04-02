
-- partie unite
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('ZICO', 'AUTRE', 'NOMINAL', 'Point Zone importance pr la conservation des oiseaux (o/n)', 'Point Zone importance pr la conservation des oiseaux (o/n)');

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('ZICO', '0', 1, 1, 1, 'Point HORS Zone importance pour la conservation des oiseaux', 'Point HORS Zone importance pour la conservation des oiseaux')
, ('ZICO', '1', 2, 2, 1, 'Point EN Zone importance pour la conservation des oiseaux', 'Point EN Zone d importance pour la conservation des oiseaux')

DELETE FROM metaifn.afcalcul WHERE champ = 6468;
DELETE FROM metaifn.afchamp WHERE donnee = 'U_ZICO';
DELETE FROM metaifn.addonnee WHERE unite = 'U_ZICO';
DELETE FROM metaifn.abmode WHERE unite = 'U_ZICO';
DELETE FROM metaifn.abunite WHERE unite = 'U_ZICO';

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('ZICO', NULL, 'ZICO', 'IFN', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, $$Point en Zone importance pr la conservation des oiseaux$$, $$Point en Zone importance pr la conservation des oiseaux$$);

-- partie champ
SELECT * FROM metaifn.ajoutchamp('ZICO', 'E2POINT', 'INV_EXP_NM', FALSE, 0, 18, 'bpchar', 1);
-- ou
SELECT * FROM metaifn.ajoutchamp('ZICO'::varchar, 'E2POINT'::varchar, 'INV_EXP_NM'::varchar, FALSE::boolean, 1, 18, 'bpchar'::varchar, 1::int4);

/*
UPDATE metaifn.afchamp
SET calcin = 0, calcout = 13, validin = 0, validout = 13
WHERE famille = 'INV_EXP_NM'
AND donnee = 'ZICO';

--controle
select *
FROM metaifn.afchamp
where famille='INV_EXP_NM'
AND format='TE2POINT'
ORDER BY position desc;
*/

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


-- Mise à jour campagne 2023 (incref 18)
WITH croise AS (
SELECT c1.npp
,	CASE WHEN i.gid IS NOT NULL THEN '1'
	ELSE '0'
	END AS dedans
FROM inv_exp_nm.e1coord c1
LEFT JOIN carto_inpn.zico_1994 i
ON ST_Intersects(c1.geom, i.geom)
)
UPDATE inv_exp_nm.e2point p
SET zico = c.dedans
FROM croise c
WHERE p.npp = c.npp AND p.incref = 18;


UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18, defin = 0, defout = 18
WHERE famille = 'INV_EXP_NM'
AND donnee = 'ZICO';

-- nombre de points dans ZICO par incref
SELECT count(zico), incref
FROM inv_exp_nm.e2point
WHERE zico = '1'
GROUP BY incref, zico
ORDER BY incref DESC;




