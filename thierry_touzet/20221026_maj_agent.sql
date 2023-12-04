-- départs d'agents
UPDATE agent SET datesortie = '2022-11-01' WHERE matricule IN (230, 233, 234);

-- nouveaux agents
INSERT INTO agent (matricule, echelon, nom, prenom, pi, lt)
VALUES (271, '01', 'MOREL', 'Angélique', FALSE, TRUE)
, (272, '05', 'FLECHET', 'Aline', FALSE, TRUE);

-- retour agents
UPDATE agent SET datesortie = NULL WHERE matricule = 250;