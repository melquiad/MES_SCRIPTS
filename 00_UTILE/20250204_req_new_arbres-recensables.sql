
SET enable_nestloop = FALSE;

----------------------------------------------------------------------------
-- version 1 (except)
with new_arbres as
(
select v3.npp ,a1.id_point ,a1.a
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1_pi2 v3 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
where v3.annee between 2020 and 2023
union
select v2.npp ,a2.id_point ,a2.a
from inv_prod_new.arbre a2
inner join inv_prod_new.v_liste_points_lt2 v2 using (id_ech, id_point)
inner join point p on p.id_point = a2.id_point
where v2.annee between 2020 and 2023
except 
select v1.npp ,a1.id_point ,a1.a
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1 v1 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
where v1.annee between 2015 and 2018
)
select na.npp ,na.id_point ,na.a ,am.dpr_cm ,am.azpr_gd 
from new_arbres na
inner join arbre_m1 am using (id_point ,a)
order by npp, a;

--------------------------------------------------
-- version 2 (not exists)
select v3.npp ,a1.id_point ,a1.a ,am.dpr_cm ,am.azpr_gd
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1_pi2 v3 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
inner join arbre_m1 am on a1.id_ech = am.id_ech and a1.id_point = am.id_point and a1.a = am.a
where v3.annee between 2020 and 2023
union
select v2.npp ,a2.id_point ,a2.a ,am.dpr_cm ,am.azpr_gd
from inv_prod_new.arbre a2
inner join inv_prod_new.v_liste_points_lt2 v2 using (id_ech, id_point)
inner join point p on p.id_point = a2.id_point
inner join arbre_m1 am on a2.id_ech = am.id_ech and a2.id_point = am.id_point and a2.a = am.a
where v2.annee between 2020 and 2023
and not exists
	(
	select v1.npp ,a1.id_point ,a1.a
	from inv_prod_new.arbre a1
	inner join inv_prod_new.v_liste_points_lt1 v1 using (id_ech, id_point)
	inner join point p on p.id_point = a1.id_point
	WHERE v1.annee between 2020 and 2023
	and a1.id_point = a2.id_point and a2.a = a1.a
	)
order by npp, a;

-------------------------------------------------------------------------------
-- version 3
with arbres_v2 as
(
select v3.npp ,a1.id_point ,a1.a 
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1_pi2 v3 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
where v3.annee between 2020 and 2023
union
select v2.npp ,a2.id_point ,a2.a 
from inv_prod_new.arbre a2
inner join inv_prod_new.v_liste_points_lt2 v2 using (id_ech, id_point)
inner join point p on p.id_point = a2.id_point
where v2.annee between 2020 and 2023
),
arbres_v1 as 
(
select v1.npp ,a1.id_point ,a1.a 
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1 v1 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
where v1.annee between 2015 and 2018
)
select a2.npp ,a2.id_point, a1.a as a_v1, a2.a as a_v2, am.dpr_cm ,am.azpr_gd
from arbres_v2 a2
inner join arbre_m1 am using (id_point ,a)
left join arbres_v1 a1 using (id_point ,a)
where a1.a is null
order by npp, a;





