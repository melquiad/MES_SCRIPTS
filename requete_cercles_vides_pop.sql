create table sig.cercles_vides_pop as
	(
	select cv.id , cv.X, cv.Y, cv.r, sum(c.Ind) as population, cv.geom 
	from sig.cercles_vides as cv
	left join sig.carreaux_population_200m as c on st_within(st_centroid(c.geom), cv.geom)
	group by cv.id , cv.X, cv.Y, cv.r
	order by population desc
	);