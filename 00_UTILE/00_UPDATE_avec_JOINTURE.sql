
-- Update evec jointures multiples
UPDATE t_facture AS tau
SET boutique_adresse_ligne_1 = taj2.ligne_1, boutique_adresse_ligne_2 = taj2.ligne_2
FROM tl_adresse_boutique AS taj1
JOIN t_adresse AS taj2 ON taj2.id = taj1.id_adresse
WHERE taj1.id_boutique = tau.id_boutique;


--AUTRE VERSION
-- correction AZDCOI_GD pour le point 22-21-233-1-119T
WITH t AS
(SELECT npp, id_ech, id_point
FROM v_liste_points_lt1 v
WHERE v.npp = '22-21-233-1-119T' AND v.annee = 2022)
UPDATE limites l
SET azdcoi_gd = 110
FROM t
WHERE t.id_ech = l.id_ech AND t.id_point = l.id_point;

--ou

UPDATE limites l
SET azdcoi_gd = 110
FROM v_liste_points_lt1 v
WHERE l.id_ech  = v.id_ech 
AND l.id_point = v.id_point 
AND v.npp = '22-21-233-1-119T' AND v.annee = 2022;



SELECT  azdcoi_gd
FROM limites l
INNER JOIN v_liste_points_lt1 v USING (id_ech, id_point)
WHERE v.npp = '22-21-233-1-119T' AND v.annee = 2022;

------------------------------------------------------------------------------------------------------

-- CORRECTIONS DEMANDEES PREALABLES AU CALCUL DU POIDS DES ARBRES LE 03/04/2023
-- correction AZDCOI_GD pour le point 22-21-233-1-119T
UPDATE limites
SET azdcoi_gd = 110
WHERE id_ech = 98
AND id_point = 1092149;

-- correction AZLIM1_GD pour les points 22-23-187-1-179T et 22-42-237-1-179T
UPDATE limites
SET azlim1_gd = 57
WHERE id_ech = 98
AND id_point = 1093562;

UPDATE limites
SET azlim1_gd = 353
WHERE id_ech = 98
AND id_point = 1107227;

-- correction AZDEP_GD pour le point 22-42-237-1-179T
UPDATE descript_m1
SET azdep_gd = 251
WHERE id_ech = 98
AND id_point = 1107227;
------------------------------------------------------------------------------------------------
