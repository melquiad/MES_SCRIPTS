SELECT count( matricule || ' ' || prenom || ' ' || nom) FROM inv_prod_new.agent;

SELECT COUNT(*) AS nbr_doublon, nom, prenom
FROM inv_prod_new.agent
GROUP BY nom, prenom
HAVING COUNT(*) > 1;

SELECT * FROM agent WHERE nom = 'BRIEU';