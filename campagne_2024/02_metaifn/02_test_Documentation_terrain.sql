BEGIN;

-- PREMIÈRE VISITE
-- modification du libellé et de la définition de QBP
UPDATE metaifn.addonnee
SET libelle = $$qualité de bille principale.$$
WHERE donnee = 'QBP';

UPDATE metaifn.addonné
SET definition = $$Indicateur binaire de la qualité potentielle de la bille principale.$$
WHERE donnee = 'QBP';

-- ajout de la modalité X à VIDEPLANT (unite 1/10PCT)
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('1/10PCT', 'X', 11, 11, 1, $$absence$$, $$0%$$);

-- ajout de la modalité R à l'unité TPLANT(TPLANT4)
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('TPLANT4', 'R', 4, 4, 1, $$Régulière en plein ratée$$, $$Plantation en plein selon un maillage régulier dont le taux de reprise, au moment du passage, est inférieur à 500 plants/ha si la densité de plantation initiale est supérieure à 1000 plants/ha ou si le taux de reprise est inférieur à 50 % dans les autres cas.
.$$);

-- suppression de la modalité T  de l'unité QLEVE3
DELETE FROM metaifn.abmode
WHERE unite = 'QLEVE3'
AND "mode" = 'T';


-- DEUXIEME VISITE
-- ajout de la donnée EVO_TPLANT5
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('EVO_TPLANT5', 'IFN', 'NOMINAL', $$Présence d'attaque de pyrale$$, $$Indicateur caractérisant la présence d'une attaque passée ou en cours de la pyrale sur les buis présents sur la placette de 7 ares.$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('EVO_TPLANT5', '1', 0, 0, 1, $$changement rapide$$, $$Changement réel de type de plantation entre les deux campagnes.$$)
, ('EVO_TPLANT5', 'A', 1, 1, 1, $$évolution des protocoles$$, $$Discordance liée à une modification des instructions dans l'intervalle entre les deux campagnes.$$);
, ('EVO_TPLANT5', 'B', 2, 2, 1, $$erreur en première visite$$, $$Discordance liée à une erreur probable d'application du protocole à la campagne précédente.$$);

SELECT * FROM metaifn.ajoutdonnee('EVO_TPLANT5', 'CR1', 'EVO_TPLANT5', 'IFN', NULL, 0, 'char(1)', 'LT', TRUE, FALSE, $$Modification de plantation$$, $$Indicateur de changement de type de plantation.$$);

-