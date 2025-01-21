with pts_v2 as
(
select npp, id_ech, id_point, st_astext(geom), round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_prod_new.v_liste_points_lt2
inner join inv_prod_new.point using (id_point,npp)
where annee between 2016 and 2020 and geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d
union
select npp, id_ech, id_point, st_astext(geom), round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_prod_new.v_liste_points_lt1_pi2
inner join inv_prod_new.point using (id_point,npp)
where annee between 2016 and 2020 and geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d
)
select p.id_ech, p.id_point, am.a, am.c13_mm --,am1.dpr_cm ,am1.azpr_gd--,am2.veget5
from pts_v2 p
inner join arbre am using (id_ech,id_point)
--left join arbre_m1 am1 on am.id_ech = am1.id_ech and am.id_point = am1.id_point and am.a = am1.a 
--left join arbre_m2 am2 on am.id_ech = am2.id_ech and am2.id_point = am2.id_point and am.a = am2.a
;