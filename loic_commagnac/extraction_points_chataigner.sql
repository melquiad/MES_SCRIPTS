with tsLesPointsLeves as
	(
	select npp as npp1, csa 
	from inv_exp_nm.e2point 
	where incref between 11 and 15 and leve = '1'
	),
	pointsZone as
	(
	select npp as npp2, xl, yl, st_x(geom), st_y(geom), st_astext(geom), tsLesPointsLeves.csa
	from inv_exp_nm.e1point as e1p
	inner join tsLesPointsLeves on tsLesPointsLeves.npp1 = e1p.npp
	where geom && 'BOX3D(424984 6334298, 611572 6652467)'::box3d
	),
	chataignier as
	(
	select g3f.npp as g3fnpp, g3f.div_r, g3f.esspre, g3f.recens, g3f.comp_r, g3f.compel_r, g3f.incref as g3incref,
	pointsZone.st_x, pointsZone.st_y, pointsZone.st_astext, pointsZone.xl, pointsZone.yl
	from inv_exp_nm.g3foret as g3f
	inner join pointsZone on g3f.npp = pointsZone.npp2
	where g3f.comp_r like '%CAS%' and g3f.esspre = '10' and recens = '1'
	)
select * from chataignier;



