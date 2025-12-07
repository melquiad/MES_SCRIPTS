SELECT count( matricule || ' ' || prenom || ' ' || nom) FROM inv_prod_new.agent;

SELECT COUNT(*) AS nbr_doublon, nom, prenom
FROM inv_prod_new.agent
GROUP BY nom, prenom
HAVING COUNT(*) > 1;

SELECT * FROM agent WHERE nom = 'BRIEU';

SHOW ROLE;

-----------------------------------------------------------------
SELECT COUNT(*) AS nbr_doublon, xl_centre, yl_centre
FROM ifn_prod.transect
GROUP BY xl_centre, yl_centre
HAVING COUNT(*) > 1;

SELECT t1.id_transect
FROM ifn_prod.transect t1
JOIN ifn_prod.transect t2 ON t1.xl_centre = t2.xl_centre AND t1.yl_centre = t2.yl_centre AND t1.id_transect < t2.id_transect;

UPDATE point SET id_transect = NULL WHERE left(npp,3) = '27-';
DELETE FROM transect_ech WHERE id_ech = 149;

DELETE FROM ifn_prod.transect t1
USING ifn_prod.transect t2
WHERE t1.xl_centre = t2.xl_centre
AND t1.yl_centre = t2.yl_centre
AND t1.id_transect > t2.id_transect;



