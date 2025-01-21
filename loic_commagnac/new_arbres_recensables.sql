SET enable_nestloop = FALSE;

 ------------------------------- DEODATIE ------------------------------------------------------
with new_arbres as
(
select v3.npp ,a1.id_point ,a1.a
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1_pi2 v3 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
where geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d and v3.annee between 2016 and 2020
union
select v2.npp ,a2.id_point ,a2.a
from inv_prod_new.arbre a2
inner join inv_prod_new.v_liste_points_lt2 v2 using (id_ech, id_point)
inner join point p on p.id_point = a2.id_point
where geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d and v2.annee between 2016 and 2020
except 
select v1.npp ,a1.id_point ,a1.a
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1 v1 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
where geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d and v1.annee between 2011 and 2015
)
select na.npp ,na.id_point ,na.a ,am.dpr_cm ,am.azpr_gd 
from new_arbres na
inner join arbre_m1 am using (id_point ,a)
order by npp, a;
--table new_arbres_deodatie;


--------------------------------------- PNR74 -------------------------------------------
with new_arbres as
(
select v3.npp ,a1.id_point ,a1.a 
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1_pi2 v3 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
where geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d and v3.annee between 2016 and 2020
union
select v2.npp ,a2.id_point ,a2.a 
from inv_prod_new.arbre a2
inner join inv_prod_new.v_liste_points_lt2 v2 using (id_ech, id_point)
inner join point p on p.id_point = a2.id_point
where geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d and v2.annee between 2016 and 2020
except 
select v1.npp ,a1.id_point ,a1.a 
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1 v1 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
where geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d and v1.annee between 2011 and 2015
order by npp, a
)
select na.npp ,na.id_point ,na.a ,am.dpr_cm ,am.azpr_gd 
from new_arbres na
inner join arbre_m1 am using (id_point ,a);


