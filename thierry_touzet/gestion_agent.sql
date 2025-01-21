update inv_prod_new.agent
set pi = true , lt = true
where matricule = 106;
----------------------------------------------------------------------------------------------------
insert into inv_prod_new.agent(matricule, echelon, nom, prenom, pi, lt, datesortie, matrica, matricc)
values (259,null, 'VOISIN', 'Patrice',true,false,null,null,null);
-----------------------------------------------------------------------------------------------------
update inv_prod_new.agent
set prenom = 'Patrice'
where matricule = 259;
------------------------------------------------------------------------------------------------------
-- départs d'agents
UPDATE agent SET datesortie = '2022-01-01' WHERE matricule IN (45, 139, 213);
UPDATE agent SET datesortie = '2022-06-01' WHERE matricule IN (106, 251);

-- changement de DT
UPDATE agent SET echelon = '03' WHERE matricule = 58;
UPDATE agent SET echelon = '02' WHERE matricule = 227;

-- nouveaux agents
INSERT INTO agent (matricule, echelon, nom, prenom, pi, lt)
VALUES (266, '04', 'DANIEL', 'Jean-Patrick', FALSE, TRUE)
, (267, '04', 'DUSSAUZE', 'Rémy', FALSE, TRUE)
, (268, '06', 'CORDONNIER', 'Louis', FALSE, TRUE);


/*
update agent a
set echelon = b.echelon, datesortie = b.datesortie 
from agents b
where a.matricule = b.matricule;
*/
			
------------------------------------------RE-CREATION TABLE AGENT--------------------------------------------------------------------------------
DROP TABLE inv_prod_new.agents;
		
CREATE TABLE inv_prod_new.agents
(
  matricule int4,
  echelon varchar(2),
  nom varchar(50),
  prenom varchar(50),
  pi bool,
  lt bool,
  datesortie date,
  matrica int2,
  matricc int2
);

\COPY inv_prod_new.agent FROM '/home/lhaugomat/Documents/EXPORTS_DIVERS/agent.csv' WITH CSV DELIMITER ';' NULL AS 'NULL'

