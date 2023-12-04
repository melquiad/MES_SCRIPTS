select v1.npp, v1.id_point, round(st_x(p.geom)::numeric) as xl93, round(st_y(p.geom)::numeric) as yl93, pe.zp as z
from v_liste_points_lt1 v1 
inner join point_ech pe using (id_ech,id_point)
inner join point p on p.id_point  = pe.id_point 
where v1.annee=2023 and pe.dep in ('2A','2B');

select v2.npp, v2.id_point, round(st_x(p.geom)::numeric) as xl93, round(st_y(p.geom)::numeric) as yl93, pe.zp as z
from v_liste_points_lt2 v2
inner join point_ech pe using (id_ech,id_point)
inner join point p on p.id_point  = pe.id_point 
where v2.annee=2023 and pe.dep in ('2A','2B');

select p2.npp, p2.id_point, round(st_x(p.geom)::numeric) as xl93, round(st_y(p.geom)::numeric) as yl93, pe.zp as z
from v_liste_points_lt1_pi2 p2
inner join point_ech pe using (id_ech,id_point)
inner join point p on p.id_point  = pe.id_point
where p2.annee=2023 and pe.dep in ('2A','2B');

----------------------------------OU--------------------------------------------

select v1.npp, v1.id_point, round(st_x(p.geom)::numeric) as xl93, round(st_y(p.geom)::numeric) as yl93, pe.zp as z
from v_liste_points_lt1 v1 
inner join point_ech pe using (id_ech,id_point)
inner join point p using (npp,id_point) 
where v1.annee=2023 and pe.dep in ('2A','2B');