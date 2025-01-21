----------------------------------- AJOUT DE PSG EN BASE D'EXPLOITATION ---------------------------------------------------
----------------------------------------------------------------------------------------------------

-- création de la colonne PSG dans la table e2point dans les 3 environnements (dev, test-exp, exp)
ALTER TABLE inv_exp_nm.e2point ADD COLUMN psg bpchar(1) DEFAULT '0';

-- croisement des points de phase 2 avec la couche PSG2022 pour la campagne 2021, avec PSG2018 pout les campagnes antérieures
CREATE TEMPORARY TABLE tempcross AS
(SELECT p1.npp, '1'::bpchar AS psg
FROM inv_exp_nm.e1coord p1
INNER JOIN carto_refifn.psg_2022 c ON ST_Intersects(p1.geom, c.geom)
INNER JOIN inv_exp_nm.e2point ep  ON ep.npp = p1.npp 
WHERE ep.incref = 16
ORDER BY p1.npp)
UNION
(SELECT p1.npp, '1'::bpchar AS psg
FROM inv_exp_nm.e1coord p1
INNER JOIN carto_refifn.psg_2018 c ON ST_Intersects(p1.geom, c.geom)
INNER JOIN inv_exp_nm.e2point ep  ON ep.npp = p1.npp 
WHERE ep.incref < 16
ORDER BY p1.npp); -- 21906 points tombent dans un PSG

-- mise à jour de la table e2point
UPDATE inv_exp_nm.e2point p2
SET t.psg = p2.psg
FROM tempcross t
WHERE p2.npp = t.npp;


-- documentation dans MetaIFN
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('PSG', 'IFN', 'NOMINAL', 'Plan simple de gestion', 'Existence d''un plan simple de gestion, mise à jour par croisement avec la couche CNPF, version 2022 pour la campagne 2021, avec la version 2018 pout les campagnes antérieures');

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('PSG', '0', 0, 0, 1, 'Hors PSG', 'Absence de plan simple de gestion')
, ('PSG', '1', 1, 1, 1, 'En PSG', 'Existence d''un plan simple de gestion');

SELECT * FROM metaifn.ajoutdonnee('PSG', NULL, 'PSG', 'IFN', NULL, 2, 'char(1)', 'CT', true, false, 'Plan simple de gestion', 'Existence d''un plan simple de gestion, mise à jour par croisement avec la couche CNPF, pour la campagne 2021, avec la version 2018 pout les campagnes antérieuresf');

SELECT * FROM metaifn.ajoutchamp('PSG', 'E2POINT', 'INV_EXP_NM', false, 0, 16, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 16, validin = 0, validout = 16
WHERE famille = 'INV_EXP_NM'
AND format = 'E2POINT'
AND donnee = 'PSG';

INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) VALUES ('IFN', 'PSG');













