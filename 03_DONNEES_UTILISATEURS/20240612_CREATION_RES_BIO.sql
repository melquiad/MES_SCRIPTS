-- documentation dans MetaIFN

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('RES_BIO', 'IFN', 'NOMINAL', 'Point en réserve de biosphère (o/n)', 'Point en réserve de biosphère (o/n)');

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('RES_BIO', '0', 0, 0, 1, 'Point HORS réserve de biosphére', 'Point HORS réserve de biosphère (Zonage INPN 01/2022)')
, ('RES_BIO', '1', 1, 1, 1, 'Point EN zone centrale de réserve de biosphère', 'Point EN zone centrale de réserve de biosphère (Zonage INPN 01/2022)')
, ('RES_BIO', '2', 2, 2, 1, 'Point EN zone tampon de réserve de biosphère', 'Point EN zone tampon de réserve de biosphère (Zonage INPN 01/2022)')
, ('RES_BIO', '3', 3, 3, 1, 'Point EN zone de transition de réserve de biosphère', 'Point EN zone de transition de réserve de biosphère (Zonage INPN 01/2022)');


SELECT * FROM metaifn.ajoutdonnee('RES_BIO', NULL, 'RES_BIO', 'IFN', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, $$Point en réserve de biosphére$$, $$Point en réserve de biosphère (o/n) (INPN 12/2020)$$
,$$Le zonage correspond à la couche BIOS. Shape correspondant disponible en base de donnée (cf. procédure de visualisation http://intradoc.ign.fr/ged/DPR/SIFE/Documents-tout-IGN/Intranet/Collecte_traitement/Cas_particulier/PR_QGIS_BDD_INPN.PDF)$$
,$$Mise à jour annuelle (lors de la libération d'une nouvelle campagne d'inventaire, vers septembre) selon zonage INPN : https://inpn.mnhn.fr/telechargement/cartes-et-information-geographique$$);


SELECT * FROM metaifn.ajoutchamp('RES_BIO', 'E2POINT', 'INV_EXP_NM', FALSE, 0, 18, 'bpchar', 1);
--              ou
SELECT * FROM metaifn.ajoutchamp('RES_BIO'::varchar, 'E2POINT'::varchar, 'INV_EXP_NM'::varchar, FALSE::boolean, 1, 18, 'bpchar'::varchar, 1::int4);


UPDATE metaifn.afchamp
SET defin = 0, defout = 19, calcin = 0, calcout = 19, validin = 0, validout = 19
WHERE famille = 'INV_EXP_NM'
AND donnee = 'U_RES_BIO';


-- creation du champ dans la table
ALTER TABLE inv_exp_nm.e2point ADD COLUMN RES_BIO CHAR(1);
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.e2point ADD COLUMN RES_BIO CHAR(1);
		
-- partie utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'RES_BIO');

-- Calcul de la donnée par recopie de la donnée U
UPDATE inv_exp_nm.e2point p
SET res_bio = c.u_res_bio
FROM inv_exp_nm.u_e2point c
WHERE p.npp = c.npp;

-- suppression de la donnée U_RES_BIO et de sa métadonnées
DELETE FROM metaifn.afcalcul WHERE champ = 6458;
DELETE FROM metaifn.afchamp WHERE donnee = 'U_RES_BIO';
DELETE FROM metaifn.addonnee WHERE unite = 'U_RES_BIO';
DELETE FROM metaifn.abgroupe WHERE unite = 'U_RES_BIO';
DELETE FROM metaifn.abmode WHERE unite = 'U_RES_BIO';
DELETE FROM metaifn.abunite WHERE unite = 'U_RES_BIO';

ALTER TABLE inv_exp_nm.u_e2point DROP COLUMN U_RES_BIO;
-- en base de production
ALTER FOREIGN TABLE inv_exp_nm.e2point DROP COLUMN U_RES_BIO;



-- contrôle : nombre de points dans zone centrale de RES_BIO par incref
SELECT incref, res_bio, count(res_bio)
FROM inv_exp_nm.e2point
--WHERE res_bio = '1'
GROUP BY incref, res_bio
ORDER BY incref DESC;

SELECT incref, u_res_bio, count(u_res_bio)
FROM inv_exp_nm.u_e2point
--WHERE res_bio = '1'
GROUP BY incref, u_res_bio
ORDER BY incref DESC;

/*
--controle
select *
FROM metaifn.afchamp
where famille='INV_EXP_NM'
AND format='TE2POINT'
ORDER BY position desc;
*/






