START TRANSACTION;

ALTER TABLE inv_exp_nm.g3arbre
    ADD COLUMN mortbg2 CHAR(1);

ALTER TABLE inv_exp_nm.p3arbre
    ADD COLUMN mortbg2 CHAR(1);

-- pour campagne 2006

UPDATE inv_exp_nm.g3arbre a
SET mortbg2 = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '4'
    END
FROM inv_exp_nm.e2point e ON a.npp = e.npp
WHERE a.incref = 1;
--AND NOT e.u_inv_facon;

-- pour campagne 2007 à 2018

UPDATE inv_exp_nm.g3arbre a
SET mortbg2 = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '4'
    END
FROM inv_exp_nm.e2point e ON a.npp = e.npp
WHERE a.incref BETWEEN 2 AND 13;
--AND NOT e.u_inv_facon;


UPDATE inv_exp_nm.p3arbre a
SET mortbg2 = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '4'
    END
FROM inv_exp_nm.e2point e ON a.npp = e.npp
WHERE a.incref BETWEEN 2 AND 13;
--AND NOT e.u_inv_facon;

-- pour campagne 2019 à 2020

UPDATE inv_exp_nm.g3arbre a
SET mortbg2 = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '3'
        WHEN a.mortb = '5' THEN '4'
    END
FROM inv_exp_nm.e2point e ON a.npp = e.npp
WHERE a.incref BETWEEN 14 AND 15;
--AND NOT e.u_inv_facon;


UPDATE inv_exp_nm.p3arbre a
SET mortbg2 = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '3'
        WHEN a.mortb = '5' THEN '4'
    END
FROM inv_exp_nm.e2point e ON a.npp = e.npp
WHERE a.incref BETWEEN 14 AND 15;
--AND NOT e.u_inv_facon;

-- pour campagne 2021 et plus

UPDATE inv_exp_nm.g3arbre a
SET mortbg2 = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '3'
        WHEN a.mortb = '5' THEN '4'
        WHEN a.mortb = 'X' THEN 'X'
    END
FROM inv_exp_nm.e2point e ON a.npp = e.npp
WHERE a.incref >= 16;
--AND NOT e.u_inv_facon;

UPDATE inv_exp_nm.p3arbre a
SET mortbg2 = 
    CASE
        WHEN a.lib IN ('0','1') OR a.cldim3 = '1' OR a.acci IN ('1','2','3','4') THEN 'X'
        WHEN a.mortb = '0' THEN '0'
        WHEN a.mortb = '1' THEN '1'
        WHEN a.mortb = '2' THEN '2'
        WHEN a.mortb = '3' THEN '3'
        WHEN a.mortb = '4' THEN '3'
        WHEN a.mortb = '5' THEN '4'
        WHEN a.mortb = 'X' THEN 'X'
    END
FROM inv_exp_nm.e2point e ON a.npp = e.npp
WHERE a.incref >= 16;
--AND NOT e.u_inv_facon;

-- Création de l'unité mortbg
INSERT INTO metaifn.abunite (unite,proprietaire,utype,libelle,definition,insert_date,insert_by,update_date,update_by) 
VALUES ('MORTBG','IFN','NOMINAL','Mortalité de branche. Unité stable dans le temps','Mortalité de branche dans la moitié supérieure du houppier. Unité compatible avec les évolutions d''unité au fil du temps.','2023-07-20 17:00:00.625','LHaugomat',NULL,NULL);

-- Création des modalités de mortbg
INSERT INTO metaifn.abmode (unite, "mode", "position", classe, valeurint, etendue, hls, rgb, cmyk, libelle, definition, insert_date, insert_by, update_date, update_by, terrain)
VALUES('MORTBG', 'X', 1, 0, NULL, 1, NULL, NULL, NULL, 'non observ.', 'Les conditions d’observation ne permettent pas d’apprécier la mortalité des branches OU la mortalité des branches n''est pas à apprécier pour ces arbres (diamètre < 22,5 cm ou couvert libre inférieur à 2/3, ou accidenté).', '2023-07-11 17:00:00.625', 'superadministrateur', NULL, NULL, 1)
, ('MORTBG', '0', 2, 1, NULL, 1, NULL, NULL, NULL, 'moins de 5 %', 'Absence de branches mortes ou présence de moins de 5 % de branches mortes dans la moitié supérieure du houppier.', '2023-07-20 09:49:40.383', 'LHaugomat', NULL, NULL, 1)
, ('MORTBG', '1', 3, 2, NULL, 1, NULL, NULL, NULL, 'entre 5 et 25 %', 'Présence de 5 à 25 % de branches mortes dans la moitié supérieure du houppier.', '2023-07-20 09:49:40.393', 'LHaugomat', NULL, NULL, 1)
, ('MORTBG', '2', 4, 3, NULL, 1, NULL, NULL, NULL, 'entre 25 à 50 %', 'Présence de 25 à 50 % de branches mortes dans la moitié supérieure du houppier.', '2023-07-20 09:49:40.395', 'LHaugomat', NULL, NULL, 1)
, ('MORTBG', '3', 5, 4, NULL, 1, NULL, NULL, NULL, 'entre 50 à 95 %', 'Présence de 50 à 95 % de branches mortes dans la moitié supérieure du houppier.', '2023-07-20 09:49:40.410', 'LHaugomat', NULL, NULL, 1)
, ('MORTBG', '4', 6, 5, NULL, 1, NULL, NULL, NULL, 'plus de 95 %', 'Présence de plus de 95% des branches mortes dans la moitié supérieure du houppier.', '2023-07-20 09:49:40.411', 'LHaugomat', NULL, NULL, 0);

--DELETE FROM metaifn.abmode WHERE unite = 'mortbg';
--DELETE FROM metaifn.abunite WHERE unite = 'mortbg';

SELECT * FROM metaifn.ajoutdonnee('MORTBG2', NULL, 'MORTBG', 'IFN', NULL, 6, 'char(1)', 'CC', TRUE, TRUE, $$Mortalité de branches homogénéisée$$, $$Indicateur de l''importance de la mortalité des branches dans la moitié supérieure du houppier avec accès à la lumière. Donnée avec unité stable dans le temps$$);
SELECT * FROM metaifn.ajoutchamp('MORTBG2', 'G3ARBRE', 'INV_EXP_NM', FALSE, 1, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('MORTBG2', 'P3ARBRE', 'INV_EXP_NM', FALSE, 2, NULL, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 1, calcout = 17, validin = 1, validout = 17
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'g3arbre'
AND donnee ~~* 'MORTBG2';

UPDATE metaifn.afchamp
SET calcin = 2, calcout = 17, validin = 2, validout = 17
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'p3arbre'
AND donnee ~~* 'MORTBG2';

INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('DRIF', 'MORTBG2');

COMMIT;

VACUUM ANALYZE inv_exp_nm.g3arbre;

