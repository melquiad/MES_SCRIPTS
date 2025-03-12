
-- chargement des shapefiles
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/sic_ue_2022/sic.shp carto_inpn.sic_ue_2022 | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/sic_ue_2022/sic/sic.shp carto_inpn.sic_ue_2022 | psql -h inv-bdd-dev.ign.fr -U haugomat -d inventaire
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/sic_ue_2022/sic/sic.shp carto_inpn.sic_ue_2022 | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
shp2pgsql -s 931007 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/sic_ue_2022/sic/sic.shp carto_inpn.sic_ue_2022 | psql -h inv-exp.ign.fr -U LHaugomat -d exploitation

-- mise à jour du propriétaire et des droits
ALTER TABLE carto_inpn.sic_ue_2022 OWNER TO exploitation_admin;
GRANT ALL ON TABLE carto_inpn.sic_ue_2022 TO exploitation_admin;
GRANT SELECT ON TABLE carto_inpn.sic_ue_2022 TO exploitation_datareader;
GRANT SELECT ON TABLE carto_inpn.sic_ue_2022 TO carto_datareader;


-- croisement des points
SELECT e1.incref + 2005 AS campagne, e1.idp, c.npp, ag.gmode AS pf_maaf, ab.libelle AS lib_pf_maaf, f.esspre, a.libelle, s.sitecode, s.sitename
, CASE WHEN s.gid IS NOT NULL THEN 'IN' ELSE 'OUT' END AS sic
FROM inv_exp_nm.e1coord c
INNER JOIN inv_exp_nm.e1point e1 ON e1.npp = c.npp
INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = c.npp
INNER JOIN inv_exp_nm.g3foret f ON f.npp = c.npp
INNER JOIN metaifn.abmode a ON f.esspre = a."mode" AND a.unite = 'ESS'
INNER JOIN metaifn.abgroupe ag ON e2.pro_nm = ag."mode" AND ag.unite = 'PRO_2015' AND ag.gunite = 'PF_MAAF'
INNER JOIN metaifn.abmode ab ON ag.gmode = ab."mode" AND ab.unite = 'PF_MAAF'
LEFT JOIN carto_inpn.sic_ue_2022 s ON ST_Intersects(c.geom, s.geom)
WHERE e1.incref = 18
UNION
SELECT e1.incref + 2005 AS campagne, e1.idp, c.npp, ag.gmode AS pf_maaf, ab.libelle AS lib_pf_maaf, p.esspre, a.libelle, s.sitecode, s.sitename
, CASE WHEN s.gid IS NOT NULL THEN 'IN' ELSE 'OUT' END AS sic
FROM inv_exp_nm.e1coord c
INNER JOIN inv_exp_nm.e1point e1 ON e1.npp = c.npp
INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = c.npp
INNER JOIN inv_exp_nm.p3point p ON p.npp = c.npp
INNER JOIN metaifn.abmode a ON p.esspre = a."mode" AND a.unite = 'ESS'
INNER JOIN metaifn.abgroupe ag ON e2.pro_nm = ag."mode" AND ag.unite = 'PRO_2015' AND ag.gunite = 'PF_MAAF'
INNER JOIN metaifn.abmode ab ON ag.gmode = ab."mode" AND ab.unite = 'PF_MAAF'
LEFT JOIN carto_inpn.sic_ue_2022 s ON ST_Intersects(c.geom, s.geom)
WHERE e1.incref = 18
ORDER BY npp;
-------------------------------------------------------------------------------------------------------------------------------------

-- dernière version :
WITH croise AS (
		SELECT e1.incref + 2005 AS campagne, e1.idp, c.npp, ag.gmode AS pf_maaf, ab.libelle AS lib_pf_maaf, f.esspre AS essence, a.libelle, c.geom
		, CASE WHEN s.gid IS NOT NULL THEN 'IN' ELSE 'OUT' END AS sic
		FROM inv_exp_nm.e1coord c
		INNER JOIN inv_exp_nm.e1point e1 ON e1.npp = c.npp
		INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = c.npp
		INNER JOIN inv_exp_nm.g3foret f ON f.npp = c.npp
		INNER JOIN metaifn.abmode a ON f.esspre = a."mode" AND a.unite = 'ESS'
		INNER JOIN metaifn.abgroupe ag ON e2.pro_nm = ag."mode" AND ag.unite = 'PRO_2015' AND ag.gunite = 'PF_MAAF'
		INNER JOIN metaifn.abmode ab ON ag.gmode = ab."mode" AND ab.unite = 'PF_MAAF'
		LEFT JOIN carto_inpn.sic_ue_2022 s ON ST_Intersects(c.geom, s.geom)
		--WHERE e1.incref = 18
		UNION
		SELECT e1.incref + 2005 AS campagne, e1.idp, c.npp, ag.gmode AS pf_maaf, ab.libelle AS lib_pf_maaf, p.esspre AS essence, a.libelle, c.geom
		, CASE WHEN s.gid IS NOT NULL THEN 'IN' ELSE 'OUT' END AS sic
		FROM inv_exp_nm.e1coord c
		INNER JOIN inv_exp_nm.e1point e1 ON e1.npp = c.npp
		INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = c.npp
		INNER JOIN inv_exp_nm.p3point p ON p.npp = c.npp
		INNER JOIN metaifn.abmode a ON p.esspre = a."mode" AND a.unite = 'ESS'
		INNER JOIN metaifn.abgroupe ag ON e2.pro_nm = ag."mode" AND ag.unite = 'PRO_2015' AND ag.gunite = 'PF_MAAF'
		INNER JOIN metaifn.abmode ab ON ag.gmode = ab."mode" AND ab.unite = 'PF_MAAF'
		LEFT JOIN carto_inpn.sic_ue_2022 s ON ST_Intersects(c.geom, s.geom)
		--WHERE e1.incref = 18
		ORDER BY npp
		)
SELECT e.campagne, e.idp, e.pf_maaf, e.lib_pf_maaf, e.essence, e.libelle, sitecode, sitename, e.sic, distance
FROM croise e
CROSS JOIN LATERAL (
	SELECT sitecode, sitename, round(ST_Distance(e.geom, geom)::NUMERIC,1) AS distance
	FROM carto_inpn.sic_ue_2022 
	ORDER BY ST_Distance(e.geom, geom)
	LIMIT 1)
ORDER BY distance;

-------------------------------------------------------------------------------------------------------------------------------------

-- 1ère version :
WITH exter AS (
	SELECT e1.incref + 2005 AS campagne, e1.idp, e1.npp, e2.pro_nm, ab.libelle AS propriete, f.esspre, a.libelle AS essence, c.geom
	, CASE WHEN s.gid IS NOT NULL THEN 'IN' ELSE 'OUT' END AS sic
	FROM inv_exp_nm.e1coord c
	INNER JOIN inv_exp_nm.e1point e1 ON e1.npp = c.npp
	INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = c.npp
	INNER JOIN inv_exp_nm.g3foret f ON f.npp = c.npp
	INNER JOIN metaifn.abmode a ON f.esspre = a."mode" AND a.unite = 'ESS'
	INNER JOIN metaifn.abmode ab ON e2.pro_nm = ab."mode" AND ab.unite = 'PRO_2015'
	LEFT JOIN carto_inpn.sic_ue_2022 s ON ST_Intersects(c.geom, s.geom)
	--WHERE e1.incref = 18
	UNION
	SELECT e1.incref + 2005 AS campagne, e1.idp, e1.npp, e2.pro_nm, ab.libelle AS propriete, p.esspre, a.libelle AS essence, c.geom
	, CASE WHEN s.gid IS NOT NULL THEN 'IN' ELSE 'OUT' END AS sic
	FROM inv_exp_nm.e1coord c
	INNER JOIN inv_exp_nm.e1point e1 ON e1.npp = c.npp
	INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = c.npp
	INNER JOIN inv_exp_nm.p3point p ON p.npp = c.npp
	INNER JOIN metaifn.abmode a ON p.esspre = a."mode" AND a.unite = 'ESS'
	INNER JOIN metaifn.abmode ab ON e2.pro_nm = ab."mode" AND ab.unite = 'PRO_2015'
	LEFT JOIN carto_inpn.sic_ue_2022 s ON ST_Intersects(c.geom, s.geom)
	--WHERE e1.incref = 18
	)
SELECT e.campagne, e.idp, e.pro_nm, e.propriete, e.esspre, e.essence, sitecode, sitename, e.sic, distance
FROM exter e
CROSS JOIN LATERAL (
	SELECT sitecode, sitename, round(ST_Distance(e.geom, geom)::NUMERIC,1) AS distance
	FROM carto_inpn.sic_ue_2022 
	ORDER BY ST_Distance(e.geom, geom)
	LIMIT 1)
ORDER BY distance;


---------------------------------------------------------------------------------------------
---------------------------- Test avec ST_Subdivide -----------------------------------------

UPDATE carto_inpn.sic_ue_2022 set geom = st_makevalid(geom) WHERE NOT st_isvalid(geom);

CREATE TABLE public.sic_ue_2022_div100 AS
	(SELECT gid, sitecode, sitename, st_subdivide(geom, 100) AS new_geom FROM carto_inpn.sic_ue_2022);

CREATE index sp_idx_sic_ue_2022_div ON sic_ue_2022_div100 USING gist(new_geom);

DROP TABLE public.sic_ue_2022_div100;

WITH exter AS (
	SELECT e1.idp, e1.npp, e2.pro_nm, ab.libelle AS propriete, f.esspre, a.libelle AS essence, c.geom
	, CASE WHEN s.gid IS NOT NULL THEN 'IN' ELSE 'OUT' END AS sic
	FROM inv_exp_nm.e1coord c
	INNER JOIN inv_exp_nm.e1point e1 ON e1.npp = c.npp
	INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = c.npp
	INNER JOIN inv_exp_nm.g3foret f ON f.npp = c.npp
	INNER JOIN metaifn.abmode a ON f.esspre = a."mode" AND a.unite = 'ESS'
	INNER JOIN metaifn.abmode ab ON e2.pro_nm = ab."mode" AND ab.unite = 'PRO_2015'
	LEFT JOIN public.sic_ue_2022_div100 s ON ST_Intersects(c.geom, s.new_geom)
	WHERE e1.incref = 18
	UNION
	SELECT e1.idp, e1.npp, e2.pro_nm, ab.libelle AS propriete, p.esspre, a.libelle AS essence, c.geom
	, CASE WHEN s.gid IS NOT NULL THEN 'IN' ELSE 'OUT' END AS sic
	FROM inv_exp_nm.e1coord c
	INNER JOIN inv_exp_nm.e1point e1 ON e1.npp = c.npp
	INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = c.npp
	INNER JOIN inv_exp_nm.p3point p ON p.npp = c.npp
	INNER JOIN metaifn.abmode a ON p.esspre = a."mode" AND a.unite = 'ESS'
	INNER JOIN metaifn.abmode ab ON e2.pro_nm = ab."mode" AND ab.unite = 'PRO_2015'
	LEFT JOIN public.sic_ue_2022_div100 s ON ST_Intersects(c.geom, s.new_geom)
	WHERE e1.incref = 18
	)
SELECT e.idp, e.pro_nm, e.propriete, e.esspre, e.essence, sitecode, sitename, e.sic, distance
FROM exter e
CROSS JOIN LATERAL (
	SELECT sitecode, sitename, round(ST_Distance(e.geom, new_geom)::NUMERIC,1) AS distance
	FROM public.sic_ue_2022_div100
	ORDER BY ST_Distance(e.geom, new_geom)
	LIMIT 1)
ORDER BY distance;






