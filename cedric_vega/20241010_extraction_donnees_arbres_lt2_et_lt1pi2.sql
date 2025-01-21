
SET enable_nestloop = FALSE;

----------- DONNEES ARBRES DES POINTS LT2 -----------------------------------------------------------------
-- en forêt
SELECT v2.annee, v2.npp, ga.a, ga.w, ga.wac, ga.espar, ga.ess, ga.htot, ga.hdec, ga.v
, ga.veget, ga.veget5, ga.vpr_an_act, ga.c13, peg.c135, ga.c13_5, uga.u_v0, uga.u_v0pr_an_ac
FROM inv_prod_new.v_liste_points_lt2 v2
INNER JOIN inv_exp_nm.g3arbre ga ON v2.npp = ga.npp
INNER JOIN prod_exp.g3arbre peg ON ga.npp = peg.npp AND ga.a = peg.a
INNER JOIN inv_exp_nm.u_g3arbre uga ON ga.npp = uga.npp AND ga.a = uga.a
WHERE v2.annee = 2023
--ORDER BY npp, a;
UNION
SELECT v2.annee, v2.npp, gm.a, gm.w, gm.wac, gm.espar, gm.ess, gm.htot, NULL AS hdec, gm.v
, gm.veget, gm.veget5, NULL AS vpr_an_act, gm.c13, NULL AS c135, NULL AS c13_5, NULL AS u_v0, NULL AS u_v0pr_an_ac
FROM inv_prod_new.v_liste_points_lt2 v2
INNER JOIN inv_exp_nm.g3morts gm ON v2.npp = gm.npp
WHERE v2.annee = 2023
--ORDER BY npp, a;
UNION
-- en peupleraie ( pas de c13_5 en peupleraie)
SELECT v2.annee, v2.npp, pa.a, pa.w, pa.wac, pa.espar, pa.ess, pa.htot, pa.hdec, pa.v
, pa.veget, pa.veget5, pa.vpr_an_act, pa.c13, pep.c135, NULL AS c13_5, upa.u_v0, upa.u_v0pr_an_ac
FROM inv_prod_new.v_liste_points_lt2 v2
INNER JOIN inv_exp_nm.p3arbre pa ON v2.npp = pa.npp
INNER JOIN prod_exp.p3arbre pep ON pa.npp = pep.npp AND pa.a = pep.a
INNER JOIN inv_exp_nm.u_p3arbre upa ON pa.npp = upa.npp AND pa.a = upa.a
WHERE v2.annee = 2023
--ORDER BY npp, a;
UNION
SELECT v2.annee, v2.npp, pm.a, pm.w, pm.wac, pm.espar, pm.ess, pm.htot, NULL AS hdec, pm.v
, pm.veget, pm.veget5, NULL AS vpr_an_act, pm.c13, NULL AS c135, NULL AS c13_5, NULL AS u_v0, NULL AS u_v0pr_an_ac
FROM inv_prod_new.v_liste_points_lt2 v2
INNER JOIN inv_exp_nm.p3morts pm ON v2.npp = pm.npp
WHERE v2.annee = 2023
ORDER BY npp, a;

----------------------------------------------------------------------------------------------------
---------------- DONNEES SUR ARBRES RECRUTES SUR POINTS LT2 ET SUR POINTS PASSES A LA FORÊT --------

	-- 1 - On récupère les nouveaux arbres recensables

-- en base de production

-- méthode EXCEPT
WITH new_arbres AS
(
SELECT v3.npp ,a1.id_point ,a1.a
FROM inv_prod_new.arbre a1
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v3 USING (id_ech, id_point)
INNER JOIN point p ON p.id_point = a1.id_point
WHERE v3.annee = 2023
UNION
SELECT v2.npp ,a2.id_point ,a2.a
FROM inv_prod_new.arbre a2
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 USING (id_ech, id_point)
INNER JOIN point p ON p.id_point = a2.id_point
WHERE v2.annee =2023
EXCEPT
SELECT v1.npp ,a1.id_point ,a1.a
FROM inv_prod_new.arbre a1
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 USING (id_ech, id_point)
INNER JOIN point p ON p.id_point = a1.id_point
WHERE v1.annee =2018
);

--ou bien mméthode NOT EXISTS
SET enable_nestloop = FALSE;

WITH new_arbres AS
(
select v3.npp ,a1.a
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1_pi2 v3 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
WHERE v3.annee = 2023
union
select v2.npp ,a2.a
from inv_prod_new.arbre a2
inner join inv_prod_new.v_liste_points_lt2 v2 using (id_ech, id_point)
inner join point p on p.id_point = a2.id_point
where v2.annee = 2023
and not exists
	(
	select v1.npp ,a1.a
	from inv_prod_new.arbre a1
	inner join inv_prod_new.v_liste_points_lt1 v1 using (id_ech, id_point)
	inner join point p on p.id_point = a1.id_point
	WHERE v1.annee = 2018
	and a1.id_point = a2.id_point
	and a2.a = a1.a
	)
order by npp, a
);

--ou bien mméthode DIFFERENCE
SET enable_nestloop = FALSE;

with arbres_v2 as
(
select v3.npp ,a1.id_point ,a1.a 
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1_pi2 v3 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
WHERE v3.annee = 2023
union
select v2.npp ,a2.id_point ,a2.a 
from inv_prod_new.arbre a2
inner join inv_prod_new.v_liste_points_lt2 v2 using (id_ech, id_point)
inner join point p on p.id_point = a2.id_point
where v2.annee = 2023
),
arbres_v1 as 
(
select v1.npp ,a1.id_point ,a1.a 
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1 v1 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
where v1.annee = 2018
)
select a2.npp ,a2.id_point, a1.a as a_v1, a2.a as a_v2
from arbres_v2 a2
left join arbres_v1 a1 using (id_point ,a)
where a1.a is null
order by npp, a;

	-->  2 -- Récupération des données sur les nouveaux arbres recensables ( avec méthode EXCEPT) en base de production

SET enable_nestloop = FALSE;

WITH new_arbres AS
(
SELECT v3.npp ,a1.id_point ,a1.a
FROM inv_prod_new.arbre a1
INNER JOIN inv_prod_new.v_liste_points_lt1_pi2 v3 USING (id_ech, id_point)
INNER JOIN point p ON p.id_point = a1.id_point
WHERE v3.annee = 2023
UNION
SELECT v2.npp ,a2.id_point ,a2.a
FROM inv_prod_new.arbre a2
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 USING (id_ech, id_point)
INNER JOIN point p ON p.id_point = a2.id_point
WHERE v2.annee =2023
EXCEPT
SELECT v1.npp ,a1.id_point ,a1.a
FROM inv_prod_new.arbre a1
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 USING (id_ech, id_point)
INNER JOIN point p ON p.id_point = a1.id_point
WHERE v1.annee =2018
ORDER BY npp, a
)
SELECT n.npp, n.id_point, n.a, am.espar, a.c13_mm
, am.htot_dm, am.hdec_dm, am.veget
FROM new_arbres n
INNER JOIN inv_prod_new.arbre a USING (id_point,a)
INNER JOIN inv_prod_new.arbre_m1 am USING (id_point,a)
ORDER BY npp, n.a;















