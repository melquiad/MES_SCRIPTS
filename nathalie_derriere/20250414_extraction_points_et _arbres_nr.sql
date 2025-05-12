

CREATE TABLE public.placette
	(
	campagne INT2,
	visite INT2,
	idp char(7)
	)
WITHOUT oids;

\COPY public.placette FROM '/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/nathalie_derriere/PLACETTE.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

TABLE public.placette;
--------------------------------------------------------------------------------------------
-- Données placettes
--------------------------------------------------------------------------------------------
SET enable_nestloop = FALSE;

-- 1ère visite
SELECT v.annee AS campagne, pla.visite, p.idp, pl.datepoint, e.dateeco, ec.passage --p.npp, p.id_point --, p.npp, p.id_point, min(pl.datepoint) AS datepoint
FROM v_liste_points_lt1 v
INNER JOIN point p USING (id_point)
INNER JOIN public.placette pla ON p.idp = pla.idp 
INNER JOIN point_lt pl USING (id_point)
INNER JOIN descript_m1 d1 ON pl.id_ech = d1.id_ech AND pl.id_point = d1.id_point
LEFT JOIN ecologie e ON e.id_ech = d1.id_ech AND e.id_point = d1.id_point
INNER JOIN echantillon ec ON e.id_ech = ec.id_ech 
--WHERE v.annee BETWEEN 2005 and 2023
WHERE v.annee = 2023
AND pla.visite = 1
AND ec.passage = 1
UNION
SELECT vp.annee AS campagne, pla.visite, p.idp, pl.datepoint, e.dateeco, ec.passage --, p.npp, p.id_point
FROM v_liste_points_lt1_pi2 vp
INNER JOIN point p USING (id_point)
INNER JOIN public.placette pla ON p.idp = pla.idp 
INNER JOIN point_lt pl USING (id_point)
INNER JOIN descript_m1 d1 ON pl.id_ech = d1.id_ech AND pl.id_point = d1.id_point
LEFT JOIN ecologie e ON e.id_ech = d1.id_ech AND e.id_point = d1.id_point
INNER JOIN echantillon ec ON e.id_ech = ec.id_ech 
--WHERE vp.annee BETWEEN 2016 and 2023
WHERE vp.annee = 2023
AND pla.visite = 1
AND ec.passage = 2
UNION
SELECT v.annee AS campagne, pla.visite, p.idp, pl.datepoint, e.dateeco, ec.passage --, p.npp, p.id_point-- , max(pl.datepoint) AS datepoint
FROM v_liste_points_lt2 v
INNER JOIN point p USING (id_point)
INNER JOIN public.placette pla ON p.idp = pla.idp 
INNER JOIN point_lt pl USING (id_point)
INNER JOIN descript_m1 d1 ON pl.id_ech = d1.id_ech AND pl.id_point = d1.id_point
LEFT JOIN ecologie e ON e.id_ech = d1.id_ech AND e.id_point = d1.id_point
INNER JOIN echantillon ec ON pl.id_ech = ec.id_ech 
--WHERE v.annee BETWEEN 2010 and 2023
WHERE v.annee = 2023
AND pla.visite = 1
AND ec.passage = 2
--GROUP BY p.npp, p.id_point, v.annee, p.idp, p.npp, p.id_point, pla.visite--, ec.passage
ORDER BY 1, 3;


-- 2ème visite 
SELECT v.annee AS campagne, pla.visite, p.idp, max(pl.datepoint) AS datepoint, p.npp, p.id_point
FROM v_liste_points_lt2 v
INNER JOIN point p USING (id_point)
INNER JOIN public.placette pla ON p.idp = pla.idp 
INNER JOIN point_lt pl USING (id_point)
INNER JOIN descript_m2 d2 ON pl.id_ech = d2.id_ech AND pl.id_point = d2.id_point
INNER JOIN echantillon ec ON pl.id_ech = ec.id_ech 
--WHERE v.annee BETWEEN 2010 and 2023
WHERE v.annee = 2023
AND pla.visite = 2
--AND ec.passage = 2
GROUP BY p.npp, p.id_point, v.annee, p.idp, p.npp, p.id_point, pla.visite--, ec.passage
ORDER BY 1, 3;


---------------------------------------------------------------------------------------
-- autre version : utiliser celle-ci pour des requêtes DATAIFN
	-- 1ère visite
SET enable_nestloop = FALSE;

SELECT c.millesime AS campagne, pla.visite, p.idp, pl.datepoint, g.dateeco, e.passage--, p.npp, p.id_point, e.id_ech
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN ecologie g ON pe.id_ech = g.id_ech AND pe.id_point = g.id_point
INNER JOIN point_lt pl ON g.id_point = pl.id_point AND g.id_ech = pl.id_ech
INNER JOIN public.placette pla ON p.idp = pla.idp
WHERE c.millesime = 2023
--WHERE c.millesime BETWEEN 2005 AND 2023
AND pla.visite = 1
--AND e.passage = 1  --> 6210
--AND e.passage = 2  --> 101
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
ORDER BY 1, 3;

	-- 2ème visite
SELECT c.millesime AS campagne, pla.visite, p.idp AS idp, pl.datepoint, e.passage-- p.npp, p.id_point
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN point_lt pl ON pe.id_point = pl.id_point AND pe.id_ech = pl.id_ech
INNER JOIN public.placette pla ON p.idp = pla.idp
WHERE c.millesime = 2023
--WHERE c.millesime BETWEEN 2010 AND 2023
AND pla.visite = 2
--AND e.passage = 2
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
ORDER BY 1, 3;


-------------------------------------------------------------------------------------------
-- Version DUCKDB
-- via DuckDB , c'est à dire dans la console :

duckdb

LOAD postgres;

ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=inv-dev.ign.fr port=5432 user=haugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);

-- 1ère visite
SELECT c.millesime AS campagne, pla.visite, p.idp, pl.datepoint, g.dateeco, e.passage--, p.npp, p.id_point, e.id_ech
FROM pg.inv_prod_new.campagne c
INNER JOIN pg.inv_prod_new.echantillon e USING (id_campagne)
INNER JOIN pg.inv_prod_new.point_ech pe USING (id_ech)
INNER JOIN pg.inv_prod_new.point p USING (id_point)
INNER JOIN pg.inv_prod_new.ecologie g ON pe.id_ech = g.id_ech AND pe.id_point = g.id_point
INNER JOIN pg.inv_prod_new.point_lt pl ON g.id_point = pl.id_point AND g.id_ech = pl.id_ech
INNER JOIN read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/nathalie_derriere/PLACETTE.csv') AS pla ON p.idp = pla.idp
WHERE c.millesime = 2023
--WHERE c.millesime BETWEEN 2005 AND 2023
AND pla.visite = 1
--AND e.passage = 1  --> 6210
--AND e.passage = 2  --> 101
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
ORDER BY 1, 3;

-- 2ème visite
SELECT c.millesime AS campagne, pla.visite, p.idp AS idp, pl.datepoint, e.passage-- p.npp, p.id_point
FROM pg.inv_prod_new.campagne c
INNER JOIN pg.inv_prod_new.echantillon e USING (id_campagne)
INNER JOIN pg.inv_prod_new.point_ech pe USING (id_ech)
INNER JOIN pg.inv_prod_new.point p USING (id_point)
INNER JOIN pg.inv_prod_new.point_lt pl ON pe.id_point = pl.id_point AND pe.id_ech = pl.id_ech
INNER JOIN read_csv('/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/nathalie_derriere/PLACETTE.csv') AS pla ON p.idp = pla.idp
WHERE c.millesime = 2023
--WHERE c.millesime BETWEEN 2010 AND 2023
AND pla.visite = 2
--AND e.passage = 2
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
ORDER BY 1, 3;

DETACH pg;

--------------------------------------------------------------------------------------------
-- Données arbres
--------------------------------------------------------------------------------------------
SET enable_nestloop = FALSE;

WITH new_arbres AS 
(
SELECT v2.annee AS campagne, p.idp, v2.id_ech, v2.npp, v2.id_point, a2.a, pla.visite
FROM v_liste_points_lt2 v2
INNER JOIN arbre a2 USING (id_ech, id_point)
INNER JOIN point p USING (id_point)
INNER JOIN public.placette pla ON p.idp = pla.idp --> c'est cette TABLE qui double le compte
WHERE NOT EXISTS (
			SELECT 1
			FROM v_liste_points_lt1 v1
			INNER JOIN arbre a1 USING (id_ech, id_point)
			WHERE v1.annee = v2.annee - 5
			AND v1.id_point = v2.id_point
			AND a1.a = a2.a
				)
--AND v2.annee BETWEEN 2015 AND 2023
AND v2.annee = 2023
ORDER BY annee, npp, a
)
SELECT DISTINCT na.campagne, na.idp, na.a
FROM new_arbres na
ORDER BY idp, a;



TABLE public.placette
ORDER BY idp;

