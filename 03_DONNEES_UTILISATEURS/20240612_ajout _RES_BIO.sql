-- documentation dans MetaIFN

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('RES_BIO', 'AUTRE', 'NOMINAL', 'Point en réserve de biosphère (o/n)', 'Point en réserve de biosphère (o/n)');

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

/*
UPDATE metaifn.afchamp
SET calcin = 0, calcout = 13, validin = 0, validout = 13
WHERE famille = 'INV_EXP_NM'
AND donnee = 'RES_BIO';

--controle
select *
FROM metaifn.afchamp
where famille='INV_EXP_NM'
AND format='TE2POINT'
ORDER BY position desc;
*/

-- creation du champ dans la table
ALTER TABLE inv_exp_nm.e2point ADD COLUMN RES_BIO CHAR(1); --> en exp
ALTER FOREIGN TABLE inv_exp_nm.e2point ADD COLUMN RES_BIO CHAR(1); --> en prod
		
-- partie utilisateur
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'RES_BIO');

-- Calcul de la donnée

-- mise à jour pour les campagnes précédentes
UPDATE inv_exp_nm.e2point p
SET res_bio = c.u_res_bio
FROM inv_exp_nm.u_e2point c
WHERE p.npp = c.npp;

-- Mise à jour campagne 2023 (incref 18)
WITH croise AS (
    SELECT c.npp, SUBSTRING(r.nom_site FROM '\((zone.+)\)') AS zrbios
    FROM inv_exp_nm.e1coord c
    INNER JOIN carto_inpn.bios_2022 r ON r.geom && c.geom AND _ST_INTERSECTS(r.geom, c.geom)
)
UPDATE inv_exp_nm.e2point e2
SET res_bio = 
    CASE
        WHEN zrbios = 'zone centrale' THEN '1'
        WHEN zrbios = 'zone tampon' THEN '2'
        WHEN zrbios = 'zone de transition' THEN '3'
        ELSE '0'
    END
FROM croise c
WHERE e2.npp = c.npp AND e2.incref = 18;

UPDATE metaifn.afchamp
SET defin = 0, defout = NULL, calcin = 0, calcout = 18, validin = 0, validout = 18
WHERE donnee = 'RES_BIO';

UPDATE metaifn.addonnee
SET definition = $$Point en réserve de biosphère (o/n) (INPN 07/2022)$$
WHERE donnee = 'RES_BIO';




-- nombre de points dans zone centrale de RES_BIO par incref
SELECT res_bio, count(res_bio), incref
FROM inv_exp_nm.e2point
WHERE res_bio = '1'
GROUP BY incref, res_bio
ORDER BY incref DESC;



UPDATE inv_exp_nm.u_e2point e2
SET u_res_bio = '0'
WHERE incref = 18 AND u_res_bio IS NULL;







