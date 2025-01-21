--/*
-- liste des données valides sur la campagne 2023 (incref 18) en base de production, points nouveaux
SELECT f.pformat, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND COALESCE(c.defin, 0) <= 18
AND COALESCE(c.defout, 99) >= 18
AND f.pformat NOT IN ('AGENT', 'C0ATTRIBUT', 'C0FACE', 'E1MAILLE', 'E1SITUATION', 'ECHANTILLON', 'PLACETTE', 'QESPECIALE', 'RECODAGE', 'UNITE_ECH')
ORDER BY f.pformat, c.position;

-- même chose avec correspondance sur la table et la colonne en base d'exploitation (schémas INV_EXP_NM et PROD_EXP)
SELECT f.pformat, c.donnee, ci.donnee AS inv_exp_donnee, cd.donnee AS dt_donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
LEFT JOIN metaifn.afchamp ci ON c.format = ci.format AND c.donnee = ci.donnee AND ci.famille = 'INV_EXP_NM'
LEFT JOIN metaifn.afchamp cd ON c.format = cd.format AND c.donnee = cd.donnee AND cd.famille = 'PROD_EXP'
WHERE f.famille = 'INV_PROD'
AND COALESCE(c.defin, 0) <= 18
AND COALESCE(c.defout, 99) >= 18
AND f.pformat NOT IN ('AGENT', 'C0ATTRIBUT', 'C0FACE', 'E1MAILLE', 'E1SITUATION', 'ECHANTILLON', 'PLACETTE', 'QESPECIALE', 'RECODAGE', 'UNITE_ECH')
ORDER BY f.pformat, c.position;

-- liste des données arrêtées en production à la campagne 2023
SELECT f.pformat, f.format, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND c.defout = 17
AND f.pformat NOT IN ('AGENT', 'C0ATTRIBUT', 'C0FACE', 'E1MAILLE', 'E1SITUATION', 'ECHANTILLON', 'L1INTERSECT', 'L1TRANSECT', 'PLACETTE', 'QESPECIALE', 'RECODAGE', 'UNITE_ECH')
ORDER BY f.pformat, c.donnee;

SELECT f.pformat, f.format, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND c.defout = 12
AND f.pformat NOT IN ('AGENT', 'C0ATTRIBUT', 'C0FACE', 'E1MAILLE', 'E1NOEUD', 'E1POINT', 'E1SITUATION', 'ECHANTILLON', 'L1INTERSECT', 'L1TRANSECT', 'PLACETTE', 'QESPECIALE', 'RECODAGE', 'UNITE_ECH')
AND c.donnee LIKE '%5'
ORDER BY f.pformat, c.position;

-- liste des données nouvelles en production à la campagne 2023
SELECT f.pformat, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND c.defin = 18
AND f.pformat NOT IN ('AGENT', 'C0ATTRIBUT', 'C0FACE', 'E1MAILLE', 'E1NOEUD', 'E1SITUATION', 'ECHANTILLON', 'L1INTERSECT', 'L1TRANSECT', 'PLACETTE', 'QESPECIALE', 'RECODAGE', 'UNITE_ECH')
ORDER BY f.pformat, c.position;

SELECT f.pformat, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f USING (famille, format)
WHERE f.famille = 'INV_PROD'
AND c.defin = 13
AND c.donnee LIKE '%5'
AND f.pformat NOT IN ('AGENT', 'C0ATTRIBUT', 'C0FACE', 'E1MAILLE', 'E1NOEUD', 'E1POINT', 'E1SITUATION', 'ECHANTILLON', 'L1INTERSECT', 'L1TRANSECT', 'PLACETTE', 'QESPECIALE', 'RECODAGE', 'UNITE_ECH')
ORDER BY f.pformat, c.position;

-- liste des données dont l'unité change à la campagne 2022
SELECT f.pformat, c.donnee
FROM metaifn.afchamp c
INNER JOIN metaifn.afformat f ON c.famille = f.famille AND c.format = f.format
INNER JOIN metaifn.addonnee d ON c.donnee = d.donnee
INNER JOIN metaifn.aiunite iold ON d.unite = iold.unite AND iold.incref = 17
INNER JOIN metaifn.aiunite inew ON d.unite = inew.unite AND inew.incref = 18
WHERE f.famille = 'INV_PROD'
AND f.pformat NOT IN ('AGENT', 'C0ATTRIBUT', 'C0FACE', 'E1MAILLE', 'E1NOEUD', 'E1POINT', 'E1SITUATION', 'ECHANTILLON', 'L1INTERSECT', 'L1TRANSECT', 'PLACETTE', 'QESPECIALE', 'RECODAGE', 'UNITE_ECH')
AND COALESCE(c.defin, 0) <= 17
AND COALESCE(c.defout, 99) >= 18
AND iold.dcunite != inew.dcunite
ORDER BY f.pformat, c.position;

-- ajout des colonnes destinées aux nouvelles données
ALTER TABLE inv_exp_nm.g3foret ADD COLUMN atpyr bpchar(1);
--ALTER TABLE inv_exp_nm.g3foret DROP COLUMN atpyr;

ALTER TABLE prod_exp.g3foret ADD COLUMN ncbuis10 bpchar(1);
ALTER TABLE prod_exp.g3foret ADD COLUMN ncbuis_a int2;
ALTER TABLE prod_exp.g3foret ADD COLUMN ncbuis_b int2;
ALTER TABLE prod_exp.g3foret ADD COLUMN ncbuis_c int2;
ALTER TABLE prod_exp.g3foret ADD COLUMN ncbuis_d int2;
ALTER TABLE prod_exp.g3foret ADD COLUMN ncbuis_e int2;










