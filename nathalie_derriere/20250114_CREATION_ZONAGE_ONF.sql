-- CHARGEMENT DE LA COUCHE CARTO

-- local
shp2pgsql -s 2154 -D -i -I ~/Documents/ECHANGES/SIG/ONF2024/U_ONF_AGENCE_2023_L93.shp carto_refifn.onf_l93_2023 | psql service=inv-local

-- inv-bdd-dev
shp2pgsql -s 2154 -D -i -I ~/Documents/ECHANGES/SIG/ONF2024/U_ONF_AGENCE_2023_L93.shp carto_refifn.onf_l93_2023 | psql service=inv-bdd

-- test-inv-exp
shp2pgsql -s 931007 -D -i -I ~/Documents/ECHANGES/SIG/ONF2024/U_ONF_AGENCE_2023_L93.shp carto_refifn.onf_l93_2023 | psql service=test-exp

-- inv-exp
shp2pgsql -s 931007 -D -i -I ~/Documents/ECHANGES/SIG/ONF2024/U_ONF_AGENCE_2023_L93.shp carto_refifn.onf_l93_2023 | psql service=exp
-----------------------------------------------------------------------------------------------------------------------------------------

-- Création ZONAGE_ONF
-- Documentation de la donnée

-- partie unite
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('AGENCES_ONF', 'IFN', 'NOMINAL', 'Agences ONF 2023', 'Agences ONF 2023');

INSERT INTO metaifn.abmode(unite, mode, libelle, definition, position) VALUES ('AGENCES_ONF', '8320','Agence territoriale PAYS DE LA LOIRE','Agence territoriale PAYS DE LA LOIRE', 0)
, ('AGENCES_ONF', '8325','Agence territoriale BRETAGNE','Agence territoriale BRETAGNE', 1)
, ('AGENCES_ONF', '8330','Agence territoriale POITOU-CHARENTES','Agence territoriale POITOU-CHARENTES', 2)
, ('AGENCES_ONF', '8335','Agence territoriale VAL DE LOIRE','Agence territoriale VAL DE LOIRE', 3)
, ('AGENCES_ONF', '8345','Agence territoriale LIMOUSIN','Agence territoriale LIMOUSIN', 4)
, ('AGENCES_ONF', '8355','Agence territoriale BERRY - BOURBONNAIS','Agence territoriale BERRY - BOURBONNAIS', 5)
, ('AGENCES_ONF', '8365','Agence territoriale LANDES - NORD AQUITAINE','Agence territoriale LANDES - NORD AQUITAINE', 6)
, ('AGENCES_ONF', '8370','Agence territoriale PYRÉNÉES-ATLANTIQUES','Agence territoriale PYRÉNÉES-ATLANTIQUES', 7)
, ('AGENCES_ONF', '8415','Agence territoriale DU JURA','Agence territoriale DU JURA', 8)
, ('AGENCES_ONF', '8420','Agence territoriale DE VESOUL','Agence territoriale DE VESOUL', 9)
, ('AGENCES_ONF', '8425','Agence territoriale NORD FRANCHE-COMTÉ','Agence territoriale NORD FRANCHE-COMTÉ', 10)
, ('AGENCES_ONF', '8440','Agence territoriale DE BESANCON','Agence territoriale DE BESANCON', 11)
, ('AGENCES_ONF', '8450','Agence territoriale BOURGOGNE-OUEST','Agence territoriale BOURGOGNE-OUEST', 12)
, ('AGENCES_ONF', '8455','Agence territoriale BOURGOGNE-EST','Agence territoriale BOURGOGNE-EST', 13)
, ('AGENCES_ONF', '8505','Agence territoriale NORD ET PAS-DE-CALAIS','Agence territoriale NORD ET PAS-DE-CALAIS', 14)
, ('AGENCES_ONF', '8510','Agence territoriale PICARDIE','Agence territoriale PICARDIE', 15)
, ('AGENCES_ONF', '8515','Agence territoriale ILE-DE-FRANCE EST','Agence territoriale ILE-DE-FRANCE EST', 16)
, ('AGENCES_ONF', '8520','Agence territoriale ILE-DE-FRANCE OUEST','Agence territoriale ILE-DE-FRANCE OUEST', 17)
, ('AGENCES_ONF', '8530','Agence territoriale D ALENÇON','Agence territoriale D ALENÇON', 18)
, ('AGENCES_ONF', '8535','Agence territoriale DE ROUEN','Agence territoriale DE ROUEN', 19)
, ('AGENCES_ONF', '8615','Agence territoriale DE BAR-LE-DUC','Agence territoriale DE BAR-LE-DUC', 20)
, ('AGENCES_ONF', '8620','Agence territoriale DE VERDUN','Agence territoriale DE VERDUN', 21)
, ('AGENCES_ONF', '8625','Agence territoriale DE METZ','Agence territoriale DE METZ', 22)
, ('AGENCES_ONF', '8630','Agence territoriale DE SARREBOURG','Agence territoriale DE SARREBOURG', 23)
, ('AGENCES_ONF', '8660','Agence territoriale VOSGES-OUEST','Agence territoriale VOSGES-OUEST', 24)
, ('AGENCES_ONF', '8665','Agence territoriale MEURTHE-ET-MOSELLE','Agence territoriale MEURTHE-ET-MOSELLE', 25)
, ('AGENCES_ONF', '8670','Agence territoriale VOSGES-MONTAGNE','Agence territoriale VOSGES-MONTAGNE', 26)
, ('AGENCES_ONF', '8681','Agence territoriale DES ARDENNES','Agence territoriale DES ARDENNES', 27)
, ('AGENCES_ONF', '8682','Agence territoriale AUBE - MARNE','Agence territoriale AUBE - MARNE', 28)
, ('AGENCES_ONF', '8683','Agence territoriale DE HAUTE-MARNE','Agence territoriale DE HAUTE-MARNE', 29)
, ('AGENCES_ONF', '8691','Agence territoriale NORD ALSACE','Agence territoriale NORD ALSACE', 30)
, ('AGENCES_ONF', '8692','Agence territoriale DE SCHIRMECK','Agence territoriale DE SCHIRMECK', 31)
, ('AGENCES_ONF', '8693','Agence territoriale DU HAUT-RHIN','Agence territoriale DU HAUT-RHIN', 32)
, ('AGENCES_ONF', '8720','Agence territoriale LOZÈRE','Agence territoriale LOZÈRE', 33)
, ('AGENCES_ONF', '8730','Agence territoriale ALPES-DE-HAUTE-PROVENCE','Agence territoriale ALPES-DE-HAUTE-PROVENCE', 34)
, ('AGENCES_ONF', '8735','Agence territoriale HAUTES-ALPES','Agence territoriale HAUTES-ALPES', 35)
, ('AGENCES_ONF', '8745','Agence territoriale BOUCHES-DU-RHÔNE - VAUCLUSE','Agence territoriale BOUCHES-DU-RHÔNE - VAUCLUSE', 36)
, ('AGENCES_ONF', '8760','Agence territoriale ARIEGE AUDE PYRENEES ORIENTALES','Agence territoriale ARIEGE AUDE PYRENEES ORIENTALES', 37)
, ('AGENCES_ONF', '8765','Agence territoriale HÉRAULT - GARD','Agence territoriale HÉRAULT - GARD', 38)
, ('AGENCES_ONF', '8770','Agence territoriale ALPES-MARITIMES - VAR','Agence territoriale ALPES-MARITIMES - VAR', 39)
, ('AGENCES_ONF', '8775','Agence territoriale AVEYRON - LOT - TARN - TARN-ET-GARONNE','Agence territoriale AVEYRON - LOT - TARN - TARN-ET-GARONNE', 40)
, ('AGENCES_ONF', '8790','Agence territoriale PYRENEES - GASCOGNE','Agence territoriale PYRENEES - GASCOGNE', 41)
, ('AGENCES_ONF', '8805','Agence territoriale AIN - LOIRE - RHÔNE','Agence territoriale AIN - LOIRE - RHÔNE', 42)
, ('AGENCES_ONF', '8810','Agence territoriale DRÔME - ARDÈCHE','Agence territoriale DRÔME - ARDÈCHE', 43)
, ('AGENCES_ONF', '8815','Agence territoriale ISÈRE','Agence territoriale ISÈRE', 44)
, ('AGENCES_ONF', '8835','Agence territoriale MONTAGNES D AUVERGNE','Agence territoriale MONTAGNES D AUVERGNE', 45)
, ('AGENCES_ONF', '8845','Agence territoriale SAVOIE MONT BLANC','Agence territoriale SAVOIE MONT BLANC', 46)
, ('AGENCES_ONF', '9005','Agence territoriale DE CORSE','Agence territoriale DE CORSE', 47);

UPDATE metaifn.abmode a
SET classe = a."position", etendue = 1
WHERE a.unite = 'AGENCES_ONF'; 

SELECT *
FROM metaifn.ajoutdonnee('ZONAGE_ONF', NULL, 'AGENCES_ONF', 'IFN', NULL, 4, 'char(4)', 'CC', TRUE, TRUE, 'Zonage ONF 2023.','Zonage ONF 2023.');

-- Documentation de la colonne en base
SELECT *
FROM metaifn.ajoutchamp('ZONAGE_ONF', 'E2POINT', 'INV_EXP_NM', FALSE, 0, 18, 'bpchar', 1);

-- Affectation à un groupe de d'utilisateurs
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee)
VALUES ('ONF_DT', 'ZONAGE_ONF')

-- Création de la colonne en base
ALTER TABLE inv_exp_nm.e2point
ADD COLUMN zonage_onf CHAR(4);

-- Mise à jour métadonnées
UPDATE metaifn.afchamp
SET defin = 0, defout = 19, calcin = 0, calcout = 19, validin = 0, validout = 19
WHERE famille IN  ('INV_EXP_NM','OCRE')
AND donnee = 'ZONAGE_ONF';



-- Calcul de la donnée
BEGIN;

SET enable_nestloop = FALSE;

WITH croise AS (
		SELECT c1.npp, CASE WHEN i.gid IS NOT NULL THEN u_onf_a ELSE NULL END AS dedans
		FROM inv_exp_nm.e1coord c1
		INNER JOIN inv_exp_nm.e2point e ON c1.npp = e.npp
		LEFT JOIN carto_refifn.onf_l93_2023 i ON ST_Intersects(c1.geom, i.geom)
		WHERE e.incref = 19
		)
UPDATE inv_exp_nm.e2point p
SET zonage_onf = c.dedans
FROM croise c
WHERE p.npp = c.npp;


-- contrôle
SELECT e.incref, count(zonage_onf)
FROM inv_exp_nm.e2point e
WHERE e.zonage_onf IS NOT NULL
GROUP BY e.incref
ORDER BY e.incref DESC;

COMMIT;






