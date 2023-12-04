BEGIN;

-- PREMIÈRE VISITE
-- modification du libellé et de la définition de QBP
UPDATE metaifn.addonnee
SET libelle = $$qualité de bille principale$$
WHERE donnee = 'QBP';

UPDATE metaifn.addonnee
SET definition = $$Indicateur binaire de la qualité potentielle de la bille principale.$$
WHERE donnee = 'QBP';

-- nouvelle modalité R sur TPLANT(unité actuelle TPLANT4)
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
SELECT 'TPLANT5', 'IFN', 'NOMINAL', libelle, definition || ' (version 2024)'
FROM metaifn.abunite
WHERE unite = 'TPLANT4';

WITH plant AS (
    SELECT 'TPLANT5' AS unite, "mode", libelle, definition
    FROM metaifn.abmode
    WHERE unite = 'TPLANT4'
    UNION 
    SELECT *
    FROM ( VALUES 
        ('TPLANT5', 'R', $$régulière en plein ratée$$, $$Plantation en plein dont le taux de reprise,au moment du passage,est inférieur à 500 plants/ha si la densité de plantation initiale est supérieure à 1000 plants/ha ou si le taux de reprise est inférieur à 50 % dans les autres cas.$$)        
    	 ) AS t (unite, "mode", libelle, definition)
)
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
SELECT unite, "mode", RANK() OVER (ORDER BY "mode") AS "position", RANK() OVER (ORDER BY "mode") AS "classe", 1 AS etendue, libelle, definition
FROM plant
ORDER BY "mode";

INSERT INTO metaifn.aiunite (usite, site, cyc, incref, inv, unite, dcunite)
SELECT 'P', 'F', '5', 18, 'T', 'TPLANT', 'TPLANT4'
UNION 
SELECT 'P', 'F', '5', 19, 'T', 'TPLANT', 'TPLANT5';

/*
UPDATE metaifn.addonnee   -->    pas utile ici le codage de TPLANT est déjà à 0
SET codage = 0::BIT
WHERE donnee = 'TPLANT';
*/


-- suppression de la modalité T  de l'unité QLEVE3
DELETE FROM metaifn.abmode
WHERE unite = 'QLEVE3'
AND "mode" = 'T';

-- Modification des libellés et définitions sur les modalités 0, 1, 2 de la donnée ITI
UPDATE metaifn.abmode
SET (libelle,definition) = ($$route accessible aux grumiers$$,$$Une route accessible aux grumiers existe à moins de 200 m du point.$$)
WHERE unite = 'ITI' AND "mode" = '0';

UPDATE metaifn.abmode
SET (libelle,definition) = ($$piste de débardage$$,$$Une piste de débardage existe à moins de 200 m du point.$$)
WHERE unite = 'ITI' AND "mode" = '1';

UPDATE metaifn.abmode
SET (libelle,definition) = ($$itinéraire à créer$$,$$Absence de route accessible aux grumiers et de piste de débardage à moins de 200 m du point mais possibilité éventuelle d’en créer.$$)
WHERE unite = 'ITI' AND "mode" = '2';

-- Modification de la définition sur les modalités 0 et 1 de LIBNR_SP
UPDATE metaifn.abmode
SET definition = $$Le centre de la sous-placette est surcimé par des arbres recensables.$$
WHERE unite = 'LIBNR_SP' AND "mode" = '0';

UPDATE metaifn.abmode
SET definition = $$Le centre de la sous-placette n'est pas surcimé par des arbres recensables.$$
WHERE unite = 'LIBNR_SP' AND "mode" = '1';

-- Ajout d'une modalité à QBOIS
UPDATE metaifn.abmode
SET ("position",classe) = (8,8)
WHERE unite = 'QBOIS' AND "mode" = '99';

INSERT INTO metaifn.abmode (unite, "mode", "position", classe, etendue, libelle, definition)
VALUES ('QBOIS', '51', 7, 7, 1, $$Réserve intégrale$$, $$Réserve dont la règlementation interdit la plupart des activités humaines à l'exception des activités de recherche et des coupes visant à la sécurisation des abords de la réserve.$$);

-- Ajout d'une modalité à QRECO (donc création d'une nouvelle unité QRECO1)
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
SELECT 'QRECO1', 'IFN', 'NOMINAL', libelle, definition
FROM metaifn.abunite
WHERE unite = 'QRECO';

WITH reco AS (
    SELECT 'QRECO1' AS unite, "mode", libelle, definition
    FROM metaifn.abmode
    WHERE unite = 'QRECO'
    UNION 
    SELECT *
    FROM ( VALUES 
        ('QRECO1', '41', $$LHF bureau$$, $$Point éliminé de l'échantillon terrain depuis le bureau, de couverture non boisée, non lande, et manifestement en-dehors de l'emprise du LHF.$$)        
    	 ) AS t (unite, "mode", libelle, definition)
)
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
SELECT unite, "mode", RANK() OVER (ORDER BY "mode") AS "position", RANK() OVER (ORDER BY "mode") AS "classe", 1 AS etendue, libelle, definition
FROM reco
ORDER BY "mode";

INSERT INTO metaifn.aiunite (usite, site, cyc, incref, inv, unite, dcunite)
SELECT 'P', 'F', '5', i, 'T', 'QRECO', CASE WHEN i <= 18 THEN 'QRECO' ELSE 'QRECO1' END 
FROM generate_series(15, 19) i
ORDER BY i;

UPDATE metaifn.addonnee SET codage = '0' WHERE donnee = 'QRECO';

-- Modification de la définition sur les modalités 5 et 6 de QUALHAB (unité QUALHAB2)
UPDATE metaifn.abmode
SET definition = $$Situation en limite d’étage de végétation (collinéen, montagnard, montagnard supérieur thermo-méditerranéen, meso-méditerranéen, supra-méditerrranéen, ...) sans indices caractéristiques.$$
WHERE unite = 'QUALHAB2' AND "mode" = '5';

UPDATE metaifn.abmode
SET definition = $$Situation en limite de zone climatique (atlantique, subatlantique, médio-européen, secteur ligérien,...) sans indices caractéristiques.$$
WHERE unite = 'QUALHAB2' AND "mode" = '6';



-- DEUXIEME VISITE
-- ajout de la donnée TPLANT5 (unite TPLANT5)
SELECT * FROM metaifn.ajoutdonnee('TPLANT5', 'CR1', 'TPLANT5', 'IFN', NULL, 0, 'char(1)', 'LT', TRUE, FALSE, $$type de plantation$$, $$Absence ou type de plantation.$$);

-- ajout de la donnée EVO_TPLANT5
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('EVO_TPLANT5', 'IFN', 'NOMINAL', $$modification de plantation$$, $$Indicateur de changement de type de plantation.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('EVO_TPLANT5', '1', 0, 0, 1, $$changement rapide$$, $$Changement réel de type de plantation entre les deux campagnes.$$)
, ('EVO_TPLANT5', 'A', 1, 1, 1, $$évolution des protocoles$$, $$Discordance liée à une modification des instructions dans l'intervalle entre les deux campagnes.$$)
, ('EVO_TPLANT5', 'B', 2, 2, 1, $$erreur en première visite$$, $$Discordance liée à une erreur probable d'application du protocole à la campagne précédente.$$);

SELECT * FROM metaifn.ajoutdonnee('EVO_TPLANT5', 'CR1', 'EVO_TPLANT5', 'IFN', NULL, 0, 'char(1)', 'LT', TRUE, FALSE, $$Modification de plantation$$, $$Indicateur de changement de type de plantation.$$);

-- INSTP5 : suppression des modalités P et S, ajout de la modalité 1 à la place
DELETE FROM metaifn.abmode WHERE unite = 'INSTP5' AND "mode" IN ('P','S');

INSERT INTO metaifn.abmode (unite, "mode", "position", classe, etendue, libelle, definition)
VALUES ('INSTP5', '1', 2, 2, 1, $$plantation ou semis$$, $$Travaux de plantation ou semis survenus depuis le premier passage sur le point d’inventaire.$$);

-- LEVE5 : créer la donnée, mais en utilisant l'unité de LEVE
SELECT * FROM metaifn.ajoutdonnee('LEVE5', 'CR1', 'LEVE', 'IFN', NULL, 0, 'char(1)', 'LT', TRUE, FALSE, $$indicateur de levé du point$$, $$Indicateur précisant si le levé du point de couverture boisée est réalisable.$$);

-- MES_C135 : modification de la définition sur la modalité 5
UPDATE metaifn.abmode
SET definition = $$Toutes les autres situations dans lesquelles la ou les nouvelles mesures ont présenté des difficultés ; arbres chablis au sol, écorce tombée ou abimée, arbre jumelle partiellement coupé, arbre ayant perdu une partie de sa circonférence,…$$
WHERE unite = 'MES_C135' AND "mode" = '5';

-- POINTOK5 : modification de la définition sur les modalités 0 et 2, modification du libellé et de la définition sur la modalité 3
UPDATE metaifn.abmode
SET definition = $$Le point n’a pas été retrouvé : aucun arbre, aucun indice et son repositionnement a une influence sur la fiabilité des données de deuxième visite (arbre mesuré en V1 et pas de coupe totale entre les deux passages).$$
WHERE unite = 'POINTOK5' AND "mode" = '0';

UPDATE metaifn.abmode
SET definition = $$Le centre de la placette a été repositionné et tous les arbres retrouvés avec certitude ou son repositionnement n’a pas d’influence sur la fiabilité des données de deuxième visite (coupe totale entre les deux passages ou pas d’arbre mesuré en V1).$$
WHERE unite = 'POINTOK5' AND "mode" = '2';

UPDATE metaifn.abmode
SET (libelle, definition) = ($$retrouvé$$, $$Le piquet repère est retrouvé planté manifestement dans sa position d’origine.$$)
WHERE unite = 'POINTOK5' AND "mode" = '3';

-- QLEVE5 : ajout de la donnée, avec l'unité QLEVE3
SELECT * FROM metaifn.ajoutdonnee('QLEVE5', 'CR1', 'QLEVE3', 'IFN', NULL, 0, 'char(1)', 'LT', TRUE, FALSE, $$motif empêchant le levé$$, $$Motif empêchant au niveau pratique le levé d'un point de couverture boisée.$$);

-- VIDEPLANT5 : créer la donnée avec l'unité 1/10PCT (sans le X)
SELECT * FROM metaifn.ajoutdonnee('VIDEPLANT5', 'CR2', '1/10PCT', 'IFN', NULL, 0, 'tinyint', 'LT', TRUE, FALSE, $$vides de plantation$$, $$Estimation en dixièmes des vides dans une plantation dans laquelle les lignes de plantation sont encore visibles.$$);


-- MODIFICATION V2

-- Correction de l'unité 2023 de QRECO
UPDATE metaifn.aiunite
SET dcunite = 'QRECO'
WHERE unite = 'QRECO'
AND incref = 18;

-- Ajout de la réserve intégrale dans QRECO
INSERT INTO metaifn.abmode (unite, "mode", "position", classe, etendue, libelle, definition)
VALUES ('QRECO1', '51', 11, 11, 1, 'Réserve intégrale', $$Réserve dont la réglementation interdit la plupart des activités humaines à l'exception des activités de recherche et des coupes visant à la sécurisation des abords de la réserve.$$);

UPDATE metaifn.abmode
SET "position" = 12, classe = 12
WHERE unite = 'QRECO1'
AND "mode" = '99';

-- Modification du libellé et de la définition d'une modalité de DISPNR
UPDATE metaifn.abmode
SET libelle = 'dispositif spécial', definition = $$Une limite traverse les sous-placettes théoriques 1 et 2. Le décompte est réalisé sur une sous-placette centrée sur le PR.$$
WHERE unite = 'DISPNR'
AND "mode" = '0';

-- Modification de la donnée de qualité sur NCERN
UPDATE metaifn.addonnee 
SET qdonnee = 'CR3'
WHERE donnee = 'NCERN';

-- Ajout de la donnée PINT_SP
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('PINT_SP', 'IFN', 'NOMINAL', $$Pression intensive des grands ongulés sur la sous-placette$$, $$Indicateur permettant de caractériser la présence de trace de pression intensive des grands ongulés sur la sous-placette.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('PINT_SP', '0', 1, 1, 1, $$Absence de trace de pression intensive$$, $$Aucun individu ne présente les caractéristiques d’une pression intensive des grands ongulés.$$)
, ('PINT_SP', '1', 2, 2, 1, $$Présence de trace de pression intensive$$, $$Au moins un individu présente les caractéristiques d’une pression intensive des grands ongulés.$$);

SELECT * FROM metaifn.ajoutdonnee('PINT_SP', 'CR2', 'PINT_SP', 'IFN', NULL, 2, 'char(1)', 'LT', TRUE, FALSE, $$Pression intensive des grands ongulés sur la sous-placette$$, $$Indicateur permettant de caractériser la présence de trace de pression intensive des grands ongulés sur la sous-placette.$$);


-- MODIFICATION V3

-- modification du libellé de QLEVE
UPDATE metaifn.addonnee
SET libelle = $$piquet sur un obstacle$$
WHERE donnee = 'QLEVE';

-- modification du libellé de QLEVE5
UPDATE metaifn.addonnee
SET libelle = $$piquet sur un obstacle$$
WHERE donnee = 'QLEVE5';

-- Ajout de la donnée AGRAFC
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('AGRAFC', 'IFN', 'NOMINAL', $$Présence d'agrafes en croix$$, $$Indicateur de présence d'agrafes en croix sur un arbre non sélectionné au premier passage.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('AGRAFC', '0', 1, 1, 1, $$Absence$$, $$Arbre sans agrafe en croix.$$)
, ('AGRAFC', '1', 2, 2, 1, $$Présence$$, $$Arbre avec agrafe en croix.$$);

SELECT * FROM metaifn.ajoutdonnee('AGRAFC', 'CR1', 'AGRAFC', 'IFN', NULL, 2, 'char(1)', 'LT', TRUE, FALSE, $$Présence d'agrafes en croix$$, $$Indicateur de présence d'agrafes en croix sur un arbre non sélectionné au premier passage.$$);



