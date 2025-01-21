------------------------------------------- DEODATIE -----------------------------------------------------------

--------------------------------------- points 1ère visite -----------------------------------------------------
select npp, id_ech, id_point, st_astext(geom), round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_prod_new.v_liste_points_lt1
inner join inv_prod_new.point using (id_point,npp)
where annee between 2016 and 2020 and geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d;

---------------------------------- points 2ème visite -----------------------------------------------------------
select npp, id_ech, id_point, st_astext(geom), round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_prod_new.v_liste_points_lt2
inner join inv_prod_new.point using (id_point,npp)
where annee between 2016 and 2020 and geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d
union
select npp, id_ech, id_point, st_astext(geom), round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_prod_new.v_liste_points_lt1_pi2
inner join inv_prod_new.point using (id_point,npp)
where annee between 2016 and 2020 and geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d;


------------------------------------------- PNR74 -----------------------------------------------------------

--------------------------------------- points 1ère visite -----------------------------------------------------
select npp, id_ech, id_point, st_astext(geom), round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_prod_new.v_liste_points_lt1
inner join inv_prod_new.point using (id_point,npp)
where annee between 2016 and 2020 and geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d

---------------------------------- points 2ème visite -----------------------------------------------------------
select npp, id_ech, id_point, st_astext(geom), round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_prod_new.v_liste_points_lt2
inner join inv_prod_new.point using (id_point,npp)
where annee between 2016 and 2020 and geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d
union
select npp, id_ech, id_point, st_astext(geom), round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_prod_new.v_liste_points_lt1_pi2
inner join inv_prod_new.point using (id_point,npp)
where annee between 2016 and 2020 and geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d;