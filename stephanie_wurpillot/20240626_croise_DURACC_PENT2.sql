

CREATE TABLE public.duracc_pente AS 
			(
			SELECT c.millesime, r2.leve, r.csa, e.id_ech, p.npp, p.id_point, pm.duracc, ec.pent2, p.geom,
				CASE WHEN pm.duracc = '01' AND ec.pent2 <= 30 THEN 0
					 WHEN pm.duracc IN ('02','03') AND ec.pent2 <= 30 THEN 1
					 WHEN pm.duracc IN ('04','05','06','07','08','09','10','11','12','13') AND ec.pent2 <=30 THEN 1
					 WHEN pm.duracc = '01' AND 30 < ec.pent2 AND ec.pent2 <= 50 THEN 1
					 WHEN pm.duracc IN ('02','03') AND 30 < ec.pent2 AND ec.pent2 <= 50 THEN 1
					 WHEN pm.duracc IN ('04','05','06','07','08','09','10','11','12','13') AND 30 < ec.pent2 AND ec.pent2 <= 50 THEN 2
					 WHEN pm.duracc = '01' AND ec.pent2 > 50 THEN 2
					 WHEN pm.duracc IN ('02','03')AND ec.pent2 > 50 THEN 2
					 WHEN pm.duracc IN ('04','05','06','07','08','09','10','11','12','13') AND ec.pent2 > 50 THEN 2
				END diff
			FROM campagne c
			INNER JOIN echantillon e USING (id_campagne)
			INNER JOIN point_ech pe USING (id_ech)
			INNER JOIN point p USING (id_point)
			INNER JOIN reconnaissance r USING (id_ech,id_point)
			INNER JOIN point_m1 pm USING (id_ech,id_point)
			INNER JOIN reco_2015 r2 USING (id_ech,id_point)
			INNER JOIN ecologie ec USING (id_ech,id_point)
			WHERE r2.leve = '1'
			AND r.csa IN ('1','3','5')
			AND c.millesime BETWEEN 2021 AND 2023
			ORDER BY npp
			);







