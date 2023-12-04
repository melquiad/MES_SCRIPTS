BEGIN;

-- PREMIÈRE VISITE
-- ajout des données AUTEURLT2 et AUTEURLT3
SELECT * FROM metaifn.ajoutdonnee('AUTEURLT_2', '_AUTEURLT', 'CODE', 'IFN', NULL, 0, 'int', 'LT', TRUE, FALSE, $$Deuxième auteur du levé$$, $$Code identifiant de l'opérateur de mesure accompagnant le responsable du levé du point d'inventaire.$$);
SELECT * FROM metaifn.ajoutdonnee('AUTEURLT_3', '_AUTEURLT', 'CODE', 'IFN', NULL, 0, 'int', 'LT', TRUE, FALSE, $$Troisième auteur du levé$$, $$Code identifiant de l'opérateur de mesure accompagnant le responsable du levé du point d'inventaire dans les cas ou l'équipe est composée de trois agents.$$);

-- modification des définitions de TAUF
UPDATE metaifn.abmode
SET definition = $$Couverture non boisée avec une utilisation essentiellement forestière.$$
WHERE unite = 'TAUF'
AND "mode" = '1';

UPDATE metaifn.abmode
SET definition = $$Couverture non boisée sans utilisation forestière ou à utilisation mixte.$$
WHERE unite = 'TAUF'
AND "mode" = '0';

-- suppression de ABROU
UPDATE metaifn.afchamp
SET defout = 17
WHERE donnee = 'ABROU';

-- Ajout des données de renouvellement des peuplements et pression du gibier
SELECT * FROM metaifn.ajoutdonnee('TCNR', 'CR1', '1/10', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Taux de couvert non recensable$$, $$Taux de couvert absolu en dixièmes sur la placette de 7 ares formé par les seuls arbres vivants non recensables.$$);

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('ORNR', 'IFN', 'NOMINAL', $$Origine du non recensable$$, $$Indicateur caractérisant l’origine majoritaire des arbres non recensables sur la placette de 7 ares.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('ORNR', '1', 1, 1, 1, $$Origine naturelle$$, $$Toutes les tiges non recensables observées sur la placette de 7 ares sont d’origine naturelle (tiges issues de semis naturels ou de rejets de souche).$$)
, ('ORNR', '2', 2, 2, 1, $$Origine artificielle$$, $$Une majorité des tiges non recensables observées sur la placette de 7 ares sont d’origine artificielle (tiges issues de plantation ou de semis en ligne).$$)
, ('ORNR', '3', 3, 3, 1, $$Origine mélangée$$, $$Une partie des tiges non recensables observées sur la placette de 7 ares est d’origine artificielle, mais parmi de nombreuses tiges d’origine naturelle.$$);

SELECT * FROM metaifn.ajoutdonnee('ORNR', 'CR1', 'ORNR', 'IFN', NULL, 3, 'char(1)', 'LT', TRUE, FALSE, $$Origine du non recensable$$, $$Indicateur caractérisant l’origine majoritaire des arbres non recensables sur la placette de 7 ares.$$);

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('PRNR', 'IFN', 'NOMINAL', $$Protection du non recensable$$, $$Indicateur caractérisant la présence d’éventuelles protections des arbres non recensables sur la placette de 7 ares.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('PRNR', '0', 0, 0, 1, $$Absence de protections$$, $$Absence totale de protections, individuelles ou collectives, pour toutes les tiges non recensables observées sur la placette de 7 ares.$$)
, ('PRNR', '1', 1, 1, 1, $$Protections individuelles$$, $$Présence de protections individuelles sur au moins une tige non recensable sur la placette de 7 ares.$$)
, ('PRNR', '2', 2, 2, 1, $$Protection collective$$, $$Présence d’une protection collective (de type enclos) empêchant l’accès du gibier sur tout ou partie de la placette de 7 ares.$$)
, ('PRNR', '3', 3, 3, 1, $$Protections individuelles et collective$$, $$Présence d’une protection collective empêchant l’accès du gibier sur tout ou partie de la placette de 7 ares, mais également de protections individuelles sur au moins une tige non recensable sur la placette de 7 ares.$$);

SELECT * FROM metaifn.ajoutdonnee('PRNR', 'CR1', 'PRNR', 'IFN', NULL, 4, 'char(1)', 'LT', TRUE, FALSE, $$Protection du non recensable$$, $$Indicateur caractérisant la présence d’éventuelles protections des arbres non recensables sur la placette de 7 ares.$$);

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('DISPNR', 'IFN', 'NOMINAL', $$Dispositif de comptage du non recensable$$, $$Type de dispositif à mettre en place en fonction de l’impact des limites sur les sous-placettes de comptage du non recensable.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('DISPNR', '0', 0, 0, 1, $$Pas de sous-placette entière$$, $$Une limite traverse les sous-placettes 1 et 2.$$)
, ('DISPNR', '1', 1, 1, 1, $$Sous-placette 1 entière$$, $$La sous-placette 1 est entière et une limite traverse la 2.$$)
, ('DISPNR', '2', 2, 2, 1, $$Sous-placette 2 entière$$, $$La sous-placette 2 est entière et une limite traverse la 1.$$)
, ('DISPNR', '3', 3, 3, 1, $$Sous-placettes 1 et 2 entières$$, $$Les sous-placettes 1 et 2 sont entières. Aucune des deux n’est traversée par une limite.$$);

SELECT * FROM metaifn.ajoutdonnee('DISPNR', 'CR1', 'DISPNR', 'IFN', NULL, 4, 'char(1)', 'LT', TRUE, FALSE, $$Dispositif de comptage du non recensable$$, $$Type de dispositif à mettre en place en fonction de l’impact des limites sur les sous-placettes de comptage du non recensable.$$);

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('PREDOM', 'IFN', 'NOMINAL', $$Présence de traces d’animaux domestiques$$, $$Indicateur de présence de traces au sol causées par des animaux domestiques (déjection, piétinement…) sur la placette de 7ares.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('PREDOM', '0', 0, 0, 1, $$Absence de traces$$, $$Absence de traces d’animaux domestiques sur la placette de 7 ares.$$)
, ('PREDOM', '1', 1, 1, 1, $$Présence de traces$$, $$Présence de traces d’animaux domestiques sur la placette de 7 ares.$$);

SELECT * FROM metaifn.ajoutdonnee('PREDOM', 'CR1', 'PREDOM', 'IFN', NULL, 2, 'char(1)', 'LT', TRUE, FALSE, $$Présence de traces d’animaux domestiques$$, $$Indicateur de présence de traces au sol causées par des animaux domestiques (déjection, piétinement…) sur la placette de 7ares.$$);

SELECT * FROM metaifn.ajoutdonnee('NSNR', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Numéro de sous-placette$$, $$Numéro de la sous-placette d'évaluation du renouvellement de peuplement et de la pression de gibier.$$);

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('FOUIL', 'IFN', 'NOMINAL', $$Présence de fouilles du sanglier$$, $$Indicateur de présence de fouilles ou de boutis causés par les sangliers sur la placette de décompte des individus non recensables.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('FOUIL', '0', 0, 0, 1, $$Absence de fouilles$$, $$Absence de fouilles ou de boutis sur la placette.$$)
, ('FOUIL', '1', 1, 1, 1, $$Présence de fouilles$$, $$Présence de fouilles ou de boutis sur la placette.$$);

SELECT * FROM metaifn.ajoutdonnee('FOUIL', 'CR1', 'FOUIL', 'IFN', NULL, 2, 'char(1)', 'LT', TRUE, FALSE, $$Présence de fouilles du sanglier$$, $$Indicateur de présence de fouilles ou de boutis causés par les sangliers sur la placette de 7 ares.$$);

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('LIBNR_SP', 'IFN', 'NOMINAL', $$Accès à la lumière de la sous-placette$$, $$Indicateur d’accès à la lumière de la sous-placette de décompte des individus non recensables.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('LIBNR_SP', '0', 0, 0, 1, $$Pas d’accès à la lumière$$, $$La sous-placette est totalement surcimée par des arbres recensables.$$)
, ('LIBNR_SP', '1', 1, 1, 1, $$Accès à la lumière$$, $$La sous-placette n’est pas surcimée par des arbres recensables.$$);

SELECT * FROM metaifn.ajoutdonnee('LIBNR_SP', 'CR1', 'LIBNR_SP', 'IFN', NULL, 2, 'char(1)', 'LT', TRUE, FALSE, $$Accès à la lumière de la sous-placette$$, $$Indicateur d’accès à la lumière de la sous-placette de décompte des individus non recensables.$$);

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('CHNR', 'IFN', 'NOMINAL', $$Classe de hauteur$$, $$Classe de hauteur utilisée pour les arbres non recensables.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('CHNR', '1', 1, 1, 1, $$0,5 à 1,3 mètre$$, $$Arbre non recensable avec une hauteur comprise entre 0,5 et 1,3 mètre.$$)
, ('CHNR', '2', 2, 2, 1, $$1,3 à 2 mètres$$, $$Arbre non recensable avec une hauteur comprise entre 1,3 et 2 mètres.$$)
, ('CHNR', '3', 3, 3, 1, $$2 mètres et plus$$, $$Arbre non recensable avec une hauteur supérieure ou égale à 2 mètres.$$);

SELECT * FROM metaifn.ajoutdonnee('CHNR', 'CR1', 'CHNR', 'IFN', NULL, 3, 'char(1)', 'LT', TRUE, FALSE, $$Classe de hauteur$$, $$Classe de hauteur utilisée pour les arbres non recensables.$$);

SELECT * FROM metaifn.ajoutdonnee('NINT', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Nombre d’individus intacts$$, $$Nombre d’individus non recensables, non abroutis dans le tiers supérieur de la tige, non frottés ou écorcés pour une même espèce et classe de hauteur sur la sous-placette de décompte considérée.$$);
SELECT * FROM metaifn.ajoutdonnee('NBROU', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Nombre d’individus abroutis$$, $$Nombre d’individus non recensables, abroutis dans le tiers supérieur de la tige, mais non frottés ou écorcés pour une même espèce et classe de hauteur sur la sous-placette de décompte considérée.$$);
SELECT * FROM metaifn.ajoutdonnee('NFROT', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Nombre d’individus frottés ou écorcés$$, $$Nombre d’individus non recensables, non abroutis dans le tiers supérieur de la tige, mais frottés ou écorcés pour une même espèce et classe de hauteur sur la sous-placette de décompte considérée.$$);
SELECT * FROM metaifn.ajoutdonnee('NMIXT', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Nombre d’individus abroutis et frottés-écorcés$$, $$Nombre d’individus non recensables, abroutis dans le tiers supérieur de la tige et frottés ou écorcés pour une même espèce et classe de hauteur sur la sous-placette de décompte considérée.$$);

-- Ajout des données C13_INF et C13_SUP (prévu de les mettre dans donnée SUPPL de la table ARBRE)
SELECT * FROM metaifn.ajoutdonnee('C13_INF_MM', 'CR1', 'mm', 'IFN', NULL, 0, 'smallint', 'LT', TRUE, FALSE, $$Circonférence inférieure$$, $$En cas de moyenne de circonférence, C13_INF_MM est la circonférence en mm sur le niveau inférieur$$);
SELECT * FROM metaifn.ajoutdonnee('C13_SUP_MM', 'CR1', 'mm', 'IFN', NULL, 0, 'smallint', 'LT', TRUE, FALSE, $$Circonférence supérieure$$, $$En cas de moyenne de circonférence, C13_SUP_MM est la circonférence en mm sur le niveau supérieur$$);

-- Modification de la définition sur la modalité correspondant à ORI = 0
UPDATE metaifn.abmode
SET definition = $$Arbre provenant d'un rejet de souche.$$
WHERE unite = 'DOM1M0'
AND "mode" = '0';

-- Modification de la définition de AUTEURLT
UPDATE metaifn.addonnee
SET definition = $$Code identifiant le responsable du levé du point d’inventaire, responsable de la qualité de toutes les données collectées sur le point, y compris des données obtenues avec l'aide d'un opérateur de mesures.$$
WHERE donnee = 'AUTEURLT';

-- Arrêt des anciennes données sur le buis
UPDATE metaifn.afchamp
SET defout = 17
WHERE donnee IN ('DPYR', 'ANPYR');

-- Ajout des nouvelles données sur le buis
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('ATPYR', 'IFN', 'NOMINAL', $$Présence d'attaque de pyrale$$, $$Indicateur caractérisant la présence d'une attaque passée ou en cours de la pyrale sur les buis présents sur la placette de 7 ares.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('ATPYR', '0', 0, 0, 1, $$Absence d'attaque$$, $$La pyrale n'a jamais attaqué les buis présents sur la placette de 7 ares.$$)
, ('ATPYR', '1', 1, 1, 1, $$Présence d'attaque$$, $$Une attaque de la pyrale est en cours, ou a déjà eu lieu, sur les buis présents sur la placette de 7 ares.$$);

SELECT * FROM metaifn.ajoutdonnee('ATPYR', 'CR1', 'ATPYR', 'IFN', NULL, 2, 'char(1)', 'LT', TRUE, FALSE, $$Présence d'attaque de pyrale$$, $$Indicateur caractérisant la présence d’une attaque passée ou en cours de la pyrale sur les buis présents sur la placette de 7 ares.$$);

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('NCBUIS10', 'IFN', 'NOMINAL', $$Nombre de cépées de buis supérieur à 10$$, $$Indicateur permettant de déterminer si la placette des 6 m contient plus de 10 tiges ou cépées de buis.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('NCBUIS10', '0', 0, 0, 1, $$Nombre de tiges ou cépées inférieur ou égal à 10$$, $$Le nombre de tiges ou cépées de buis est inférieur ou égal à 10 sur la placette de 6 m de rayon.$$)
, ('NCBUIS10', '1', 1, 1, 1, $$Nombre de tiges ou cépées supérieur à 10$$, $$Le nombre de tiges ou cépées de buis est supérieur à 10 sur la placette de 6 m de rayon.$$);

SELECT * FROM metaifn.ajoutdonnee('NCBUIS10', 'CR1', 'NCBUIS10', 'IFN', NULL, 2, 'char(1)', 'LT', TRUE, FALSE, $$Nombre de cépées de buis supérieur à 10$$, $$Indicateur permettant de déterminer si la placette des 6 m contient plus de 10 tiges ou cépées de buis.$$);
SELECT * FROM metaifn.ajoutdonnee('NCBUIS_A', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Nombre de cépée de buis saine$$, $$Nombre de cépée de buis saines sur la placette de 6 m de rayon.$$);
SELECT * FROM metaifn.ajoutdonnee('NCBUIS_B', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Nombre de cépée de buis partiellement défoliée$$, $$Nombre de cépée de buis partiellement défoliées sur la placette de 6 m de rayon.$$);
SELECT * FROM metaifn.ajoutdonnee('NCBUIS_C', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Nombre de cépée de buis défoliés avec réaction forte$$, $$Nombre de cépée de buis défoliés avec réaction forte sur la placette de 6 m de rayon.$$);
SELECT * FROM metaifn.ajoutdonnee('NCBUIS_D', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Nombre de cépée de buis défoliés avec réaction faible$$, $$Nombre de cépée de buis défoliés avec réaction faible sur la placette de 6 m de rayon.$$);
SELECT * FROM metaifn.ajoutdonnee('NCBUIS_E', 'CR1', '1', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Nombre de cépée de buis morte$$, $$Nombre de cépée de buis mortes sur la placette de 6 m de rayon.$$);
SELECT * FROM metaifn.ajoutdonnee('AZDBUIS', 'CR1', 'grade', 'IFN', NULL, 11, 'smallint', 'LT', TRUE, FALSE, $$Azimut de la dixième cépée de buis$$, $$Azimut en grade de la dixième tige ou cépée de buis.$$);

COMMIT;


-- Quelques modifications supplémentaires
BEGIN;

UPDATE metaifn.abmode SET definition = $$Les buis présents sur la placette de 7 ares ne portent aucune trace d’attaque de pyrale (absence d’attaque ou attaque passée mais invisible aujourd’hui).$$
WHERE unite = 'ATPYR' AND "mode" = '0';

UPDATE metaifn.abmode SET definition = $$Les buis présents sur la placette de 7 ares portent les traces d’une attaque de pyrale en cours ou passée mais toujours visible.$$
WHERE unite = 'ATPYR' AND "mode" = '1';

UPDATE metaifn.addonnee SET definition = $$Autre utilisation compatible avec la production de bois.$$
WHERE donnee = 'AUTUT';

UPDATE metaifn.addonnee SET definition = $$Épaisseur du cerne en cours de création de l’année de la campagne d’inventaire.$$
WHERE donnee = 'IR0_1_10MM';

UPDATE metaifn.addonnee SET definition = $$Accroissement radial moyen de l'arbre lors de la dernière année.$$
WHERE donnee = 'IR1_1_10MM';

UPDATE metaifn.addonnee SET definition = $$Accroissement radial moyen de l'arbre lors des 2 dernières années.$$
WHERE donnee = 'IR2_1_10MM';

UPDATE metaifn.addonnee SET definition = $$Accroissement radial moyen de l'arbre lors des 3 dernières années.$$
WHERE donnee = 'IR3_1_10MM';

UPDATE metaifn.addonnee SET definition = $$Accroissement radial moyen de l'arbre lors des 4 dernières années.$$
WHERE donnee = 'IR4_1_10MM';

UPDATE metaifn.abmode 
SET libelle = $$0,5 à 1,3 mètre exclu$$, definition = $$Arbre non recensable avec une hauteur comprise entre 0,5 et 1,3 mètre exclu.$$
WHERE unite = 'CHNR'
AND "mode" = '1';

UPDATE metaifn.abmode 
SET libelle = $$1,3 à 2 mètres exclu$$, definition = $$Arbre non recensable avec une hauteur comprise entre 1,3 et 2 mètres exclu.$$
WHERE unite = 'CHNR'
AND "mode" = '2';

UPDATE metaifn.abmode SET definition = $$Coupe enlevant plus de 90 % du couvert vivant recensable relatif libre total avant la coupe.$$
WHERE unite = 'DCG9' AND "mode" = '1';

UPDATE metaifn.abmode SET definition = $$Coupe enlevant de 50 à 90 % du couvert vivant recensable relatif libre total avant la coupe.$$
WHERE unite = 'DCG9' AND "mode" = '2';

UPDATE metaifn.abmode SET definition = $$Coupe enlevant de 15 à 50 % du couvert vivant recensable relatif libre total avant la coupe.$$
WHERE unite = 'DCG9' AND "mode" = '3';

UPDATE metaifn.abmode SET definition = $$Coupe enlevant moins de 15 % du couvert vivant recensable relatif libre total avant la coupe, et autres coupes de sous-étages sans effet sur le couvert recensable libre.$$
WHERE unite = 'DCG9' AND "mode" = '4';

UPDATE metaifn.abmode SET definition = $$Absence de fouilles ou de boutis sur la placette de 7 ares.$$
WHERE unite = 'FOUIL' AND "mode" = '0';

UPDATE metaifn.abmode SET definition = $$Présence de fouilles ou de boutis  sur la placette de 7 ares.$$
WHERE unite = 'FOUIL' AND "mode" = '1';

UPDATE metaifn.abmode SET definition = $$Le nombre de tiges ou cépées de buis est égal à 10 sur la placette de 6 m de rayon.$$
WHERE unite = 'NCBUIS10' AND "mode" = '0';

UPDATE metaifn.abmode SET definition = $$Deux limites rectilignes interceptent la placette théorique de 15 mètres de rayon, et se coupent en coin sur cette placette théorique.$$
WHERE unite = 'PLAS15' AND "mode" = '2';

UPDATE metaifn.abmode SET definition = $$Deux limites rectilignes interceptent la placette théorique de 25 mètres de rayon, et se coupent en coin sur cette placette théorique.$$
WHERE unite = 'PLAS25' AND "mode" = '2';

UPDATE metaifn.abmode
SET "position" = "position" + 1, classe = classe + 1
WHERE unite = 'QRECO'
AND "position" > 5;

INSERT INTO metaifn.abmode (unite, "mode", "position", classe, etendue, libelle, definition)
VALUES ('QRECO', '23', 6, 6, 1, 'Danger temporaire', $$Présence d’un danger temporaire (abeilles, frelons, taureau, inondation,...) ne permettant pas de réaliser le levé du point au moment du passage de l’équipe.$$);

COMMIT;

