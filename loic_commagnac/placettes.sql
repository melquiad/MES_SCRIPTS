--Deodatie
with tsLesPointsLeves as
(
select npp as npp1, csa
from inv_exp_nm.e2point
where incref in (6, 7, 8, 9, 10, 11 ,12 ,13 ,14 ,15) and leve = '1'
),
pointsZone as
(
select npp as npp2, xl, yl, st_astext(geom), tsLesPointsLeves.csa, round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_exp_nm.e1coord as e1p
inner join tsLesPointsLeves on tsLesPointsLeves.npp1 = e1p.npp
where geom && 'BOX3D(979340 6804730, 1005570 6832370)'::box3d
)
select * from pointsZone;

--pnr74
with tsLesPointsLeves as
(
select npp as npp1, csa
from inv_exp_nm.e2point
where incref in (6, 7, 8, 9, 10, 11 ,12 ,13 ,14 ,15) and leve = '1'
),
pointsZone as
(
select npp as npp2, xl, yl, st_astext(geom), tsLesPointsLeves.csa, round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_exp_nm.e1coord as e1p
inner join tsLesPointsLeves on tsLesPointsLeves.npp1 = e1p.npp
where geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d
)
select * from pointsZone;

--------------------------------Sélection de données sur points retours , incref 6 à 10--------------------------------------------------

with tsLesPointsLeves as
(
select npp as npp1, csa
from inv_exp_nm.e2point
where incref in (6, 7, 8, 9, 10, 11 ,12 ,13 ,14 ,15) and leve = '1'
),
pointsZone as
(
select npp as npp2, xl, yl, st_astext(geom), round(st_x(geom)::numeric) as xl93, round(st_y(geom)::numeric) as yl93
from inv_exp_nm.e1coord as e1p
inner join tsLesPointsLeves on tsLesPointsLeves.npp1 = e1p.npp
where geom && 'BOX3D(927700 6498000, 966400 6537000)'::box3d
)
select pz.npp2 ,ga.a ,ga.c13_5,ga.wac ,ga.htot ,ga.ess ,ga.veget ,gac.azpr ,gac.dpr
from pointsZone pz
inner join inv_exp_nm.g3arbre ga on pz.npp2 = ga.npp
inner join inv_exp_nm.g3arbre_coord gac using (npp,a)
where ga.c13_5 is not null
order by npp2 desc;