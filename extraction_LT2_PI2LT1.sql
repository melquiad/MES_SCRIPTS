---------------- selection des points 2ème visite 2023 ------------------

select vl.npp, vl.annee, vl.id_ech, vl.id_point, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
from v_liste_points_lt2 vl
inner join point p on p.id_point = vl.id_point
where vl.annee = '2023';

---------------- selection des points 2ème PI 1ère visite 2023 ------------------

select vl.npp, vl.annee, vl.id_ech, vl.id_point, ROUND(ST_X(p.geom)::NUMERIC) AS xl93, ROUND(ST_Y(p.geom)::NUMERIC) AS yl93
from v_liste_points_lt1_pi2 vl
inner join point p on p.id_point = vl.id_point
where vl.annee = '2023';