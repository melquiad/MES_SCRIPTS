SET enable_nestloop = FALSE;


-- Il manque quelques points deuxième PI premier levés terrain (points passés à la forêt en 5 ans)
-- , ainsi que quelques points non forêt au premier passage (lande par exemple) et passés forêt au deuxième.

	--en base d'exploitation
SELECT ep2.npp, ep2.incref, st_x(st_transform(ec.geom,4326)) AS lon, st_y(st_transform(ec.geom,4326)) AS lat, ec.zp
, ge.topo, ge.obstopo, ge.obschemin, ge.distriv, ge.typriv, ge.denivriv, ge.pent2, ge.expo, ge.masque, ge.msud
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
INNER JOIN inv_exp_nm.g3ecologie ge ON ec.npp = ge.npp
WHERE ep2.incref BETWEEN 12 AND 18
UNION 
SELECT ep2.npp, ep2.incref, st_x(st_transform(ec.geom,4326)) AS lon, st_y(st_transform(ec.geom,4326)) AS lat, ec.zp
, pe.topo, pe.obstopo, pe.obschemin, pe.distriv, pe.typriv, pe.denivriv, pe.pent2, pe.expo, pe.masque, pe.msud
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
INNER JOIN inv_exp_nm.p3ecologie pe ON ec.npp = pe.npp
WHERE ep2.incref BETWEEN 12 AND 18
ORDER BY incref, npp;

-------------------------------------------------------------------------------------------------------------------
	--en base de production
SELECT p.npp, v.annee, st_x(st_transform(p.geom,4326)) AS lon, st_y(st_transform(p.geom,4326)) AS lat, pe.zp
, e.topo, e.obstopo, e.obschemin, e.distriv, e2.typriv, e.denivriv, e.pent2, e.expo, e.masque, e2.msud
FROM v_liste_points_lt1 v
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN ecologie_2017 e2 USING (id_ech, id_point)
WHERE v.annee BETWEEN 2017 AND 2023
ORDER BY annee, npp;

-- COMPLEMENTS
	-- points deuxième PI premier levés terrain (points passés à la forêt en 5 ans)
SELECT p.npp, v.annee, st_x(st_transform(p.geom,4326)) AS lon, st_y(st_transform(p.geom,4326)) AS lat, pe.zp
, e.topo, e.obstopo, e.obschemin, e.distriv, e2.typriv, e.denivriv, e.pent2, e.expo, e.masque, e2.msud
FROM v_liste_points_lt1_pi2 v
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN ecologie_2017 e2 USING (id_ech, id_point)
WHERE v.annee = 2023
--WHERE v.annee BETWEEN 2017 AND 2023
ORDER BY annee, npp;

	-- points non forêt au premier passage (lande par exemple) et passés forêt au deuxième.
SELECT p.npp, v.annee, st_x(st_transform(p.geom,4326)) AS lon, st_y(st_transform(p.geom,4326)) AS lat, pe.zp
, e.topo, e.obstopo, e.obschemin, e.distriv, e2.typriv, e.denivriv, e.pent2, e.expo, e.masque, e2.msud
FROM v_liste_points_lt2 v
INNER JOIN point p USING (id_point)
INNER JOIN point_ech pe USING (id_ech, id_point)
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN ecologie_2017 e2 USING (id_ech, id_point)
WHERE v.annee = 2023
--WHERE v.annee BETWEEN 2017 AND 2023
ORDER BY annee, npp;


 -- je vérifie que ces points complémentaires n'étaient pas forêt en première PI :
SELECT v.npp, v.cso
FROM v_infos_pi1 v
WHERE v.npp IN (
		SELECT p.npp
		FROM v_liste_points_lt1_pi2 v
		INNER JOIN point p USING (id_point)
		INNER JOIN point_ech pe USING (id_ech, id_point)
		INNER JOIN ecologie e USING (id_ech, id_point)
		INNER JOIN ecologie_2017 e2 USING (id_ech, id_point)
		WHERE v.annee = 2023
		--WHERE v.annee BETWEEN 2017 AND 2023
		ORDER BY annee, npp
		)
 AND v.annee = 2018;
 --AND v.annee BETWEEN 2012 AND 2017;


 -- je vérifie que ces points complémentaires n'étaient pas forêt au premier levé terrain :
SELECT v.npp, r.csa
FROM v_liste_points_lt1 v
INNER JOIN reconnaissance r USING (id_ech, id_point)
WHERE v.npp IN (
		SELECT p.npp
		FROM v_liste_points_lt2 v
		INNER JOIN point p USING (id_point)
		INNER JOIN point_ech pe USING (id_ech, id_point)
		INNER JOIN ecologie e USING (id_ech, id_point)
		INNER JOIN ecologie_2017 e2 USING (id_ech, id_point)
		WHERE v.annee = 2023
		--WHERE v.annee BETWEEN 2017 AND 2023
		ORDER BY annee, npp
		)
 AND v.annee = 2018;
 --AND v.annee BETWEEN 2012 AND 2017;



 











