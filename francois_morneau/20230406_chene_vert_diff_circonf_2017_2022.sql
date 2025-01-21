SELECT a.id_ech, a.id_point, p.npp, a.a, camp.millesime AS an--, a1.htot_dm / 10 AS htot
       , a.c13_mm, a2.c13_mm as c135_mm
FROM inv_prod_new.arbre a
INNER JOIN (
	       SELECT id_point, a, c13_mm
	       FROM inv_prod_new.arbre
	       WHERE id_ech = 99) as a2 USING(id_point, a)
INNER JOIN inv_prod_new.arbre_m1 a1 ON a.id_ech = a1.id_ech AND a.id_point = a1.id_point AND a.a = a1.a
INNER JOIN inv_prod_new.point p ON a.id_point = p.id_point
INNER JOIN inv_prod_new.echantillon ech ON a.id_ech = ech.id_ech
INNER JOIN inv_prod_new.campagne camp ON ech.id_campagne = camp.id_campagne
WHERE ech.id_ech = 36 AND ech.phase_stat = 2 AND ech.type_ech = 'P'::bpchar AND a1.espar = '06' AND a.c13_mm IS NOT NULL;
