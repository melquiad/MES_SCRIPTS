SET enable_nestloop = FALSE;
 ------------------------------- PNR74 puid DEODATIE ------------------------------------------------------

select v3.npp ,a1.id_point ,a1.a ,am.dpr_cm ,am.azpr_gd
from inv_prod_new.arbre a1
inner join inv_prod_new.v_liste_points_lt1_pi2 v3 using (id_ech, id_point)
inner join point p on p.id_point = a1.id_point
inner join arbre_m1 am on a1.id_ech = am.id_ech and a1.id_point = am.id_point and a1.a = am.a
--where geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d and v3.annee between 2016 and 2020
where geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d and v3.annee between 2016 and 2020
union
select v2.npp ,a2.id_point ,a2.a ,am.dpr_cm ,am.azpr_gd
from inv_prod_new.arbre a2
inner join inv_prod_new.v_liste_points_lt2 v2 using (id_ech, id_point)
inner join point p on p.id_point = a2.id_point
inner join arbre_m1 am on a2.id_ech = am.id_ech and a2.id_point = am.id_point and a2.a = am.a
--where geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d and v2.annee between 2016 and 2020
where geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d and v2.annee between 2016 and 2020
and not exists
	(
	select v1.npp ,a1.id_point ,a1.a
	from inv_prod_new.arbre a1
	inner join inv_prod_new.v_liste_points_lt1 v1 using (id_ech, id_point)
	inner join point p on p.id_point = a1.id_point
	--where geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d and v1.annee between 2011 and 2015
	where geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d and v1.annee between 2011 and 2015
	and a1.id_point = a2.id_point and a2.a = a1.a
	)
order by npp, a;
