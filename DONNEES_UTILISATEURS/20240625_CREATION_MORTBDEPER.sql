
-- Création de la donnée MORTBDEPER

BEGIN;
-- Documentation de l'unité
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition) 
VALUES ('MORTBDEPER', 'IFN', 'NOMINAL', 'Mortalité de branche. Unité stable dans le temps',
'Mortalité de branche dans la moitié supérieure du houppier. Unité compatible avec les évolutions d''unité au fil du temps et adaptée au calcul de la donnée DEPERIS.');

-- Documentation des modalités
INSERT INTO metaifn.abmode (unite, "mode", "position", classe, valeurint, etendue, hls, rgb, cmyk, libelle, definition)
VALUES('MORTBDEPER', 'X', 1, 0, NULL, 1, NULL, NULL, NULL, 'non observ.', 'Les conditions d’observation ne permettent pas d’apprécier la mortalité des branches OU la mortalité des branches n''est pas à apprécier pour ces arbres (diamètre < 22,5 cm ou couvert libre inférieur à 2/3, ou accidenté).')
, ('MORTBDEPER', '0', 2, 1, NULL, 1, NULL, NULL, NULL, 'moins de 5 %', 'Absence de branches mortes ou présence de moins de 5 % de branches mortes dans la moitié supérieure du houppier.')
, ('MORTBDEPER', '1', 3, 2, NULL, 1, NULL, NULL, NULL, 'entre 5 et 25 %', 'Présence de 5 à 25 % de branches mortes dans la moitié supérieure du houppier.')
, ('MORTBDEPER', '2', 4, 3, NULL, 1, NULL, NULL, NULL, 'entre 25 à 50 %', 'Présence de 25 à 50 % de branches mortes dans la moitié supérieure du houppier.')
, ('MORTBDEPER', '3', 5, 4, NULL, 1, NULL, NULL, NULL, 'entre 50 à 75 %', 'Présence de 50 à 75 % de branches mortes dans la moitié supérieure du houppier.')
, ('MORTBDEPER', '4', 6, 5, NULL, 1, NULL, NULL, NULL, 'entre 75 à 95 %', 'Présence de 75 à 95 % de branches mortes dans la moitié supérieure du houppier.')
, ('MORTBDEPER', '5', 7, 6, NULL, 1, NULL, NULL, NULL, 'plus de 95 %', 'Présence de plus de 95% des branches mortes dans la moitié supérieure du houppier.');

-- Documentation de la donnée
SELECT * FROM metaifn.ajoutdonnee('MORTBDEPER', NULL, 'MORTBDEPER', 'IFN', NULL, 7, 'char(1)', 'CC', TRUE, TRUE, 'Mortalité de branches homogénéisée', 
'Indicateur de l''importance de la mortalité des branches dans la moitié supérieure du houppier avec accès à la lumière. Donnée avec unité stable dans le temps et adaptée au calcul de la donnée DEPERIS');

-- Doccumentation de la colonne en base
SELECT * FROM metaifn.ajoutchamp('MORTBDEPER', 'G3ARBRE', 'INV_EXP_NM', FALSE, 1, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('MORTBDEPER', 'P3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'bpchar', 1);

COMMIT;

BEGIN;
-- Création de la donnée utilisateur
ALTER TABLE inv_exp_nm.g3arbre
    ADD COLUMN mortbdeper CHAR(1);

ALTER TABLE inv_exp_nm.p3arbre
    ADD COLUMN mortbdeper CHAR(1);
	
-- Mise à jour de la donnée utilisateur
-- pour campagne 2021 et plus

UPDATE inv_exp_nm.g3arbre ua
SET mortbdeper = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '4'
        WHEN a.mortb = '5' THEN '5'
        WHEN a.mortb = 'X' THEN 'X'
    END
FROM inv_exp_nm.g3arbre a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;


UPDATE inv_exp_nm.p3arbre ua
SET mortbdeper = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '4'
        WHEN a.mortb = '5' THEN '5'
        WHEN a.mortb = 'X' THEN 'X'
    END
FROM inv_exp_nm.p3arbre a
WHERE a.npp = ua.npp AND a.a = ua.a AND a.incref >= 16;


-- Mise à jour des métadonnées
UPDATE metaifn.afchamp
SET calcin = 16, calcout = 18, validin = 16, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'g3arbre'
AND donnee ~~* 'MORTBDEPER';

UPDATE metaifn.afchamp
SET calcin = 16, calcout = 18, validin = 16, validout = 18
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'p3arbre'
AND donnee ~~* 'MORTBDEPER';

-- Affectation à un groupe d'utilisateurs
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('IFN', 'MORTBDEPER');

COMMIT;

 





