

CREATE TEMPORARY TABLE states AS (
	SELECT npp, MAX(state) AS state
	FROM soif.point_states
	WHERE anref = 2024
	GROUP BY npp
);

ALTER TABLE states ADD CONSTRAINT states_pkey PRIMARY KEY (npp);
ANALYZE states;

SET enable_nestloop = FALSE;

SELECT te.id_ech, te.id_transect, vl.sl, vl.rep, vl.dseg_dm, vl.optersl, vl.tlhf2
FROM inv_prod_new.transect_ech te
INNER JOIN inv_prod_new.echantillon e ON te.id_ech = e.id_ech AND e.phase_stat = 2 AND e.type_ue = 'T'
INNER JOIN inv_prod_new.point p ON te.id_transect = p.id_transect
INNER JOIN soif.v1l2segment vl ON p.npp = vl.npp
INNER JOIN states ps ON vl.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vl.npp = v1.npp
WHERE v1.annee = 2024
AND (vl.rep, vl.dseg_dm, vl.optersl, vl.tlhf2) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
ORDER BY te.id_ech, te.id_transect, vl.sl;

SELECT te.id_ech, te.id_transect, p.id_point, p.npp, vl.npp, vl.sl, vl.rep, vl.dseg_dm, vl.optersl, vl.tlhf2
FROM inv_prod_new.transect_ech te
--INNER JOIN inv_prod_new.echantillon e ON te.id_ech = e.id_ech AND e.type_ech = 'T' AND e.phase_stat = 2
INNER JOIN inv_prod_new.point p ON te.id_transect = p.id_transect
INNER JOIN soif.v1l2segment vl ON p.npp = vl.npp
INNER JOIN states ps ON vl.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt1 v1 ON vl.npp = v1.npp
WHERE te.id_ech = 116 AND v1.annee = 2024 
AND (vl.rep, vl.dseg_dm, vl.optersl, vl.tlhf2) IS DISTINCT FROM (NULL, NULL, NULL, NULL)
ORDER BY te.id_ech, te.id_transect, vl.sl;
----------------------------------------------------------------------------------------------

-- mise à jour de TPLANT dans DESCRIPTION en chargement V2 avec V2E5POINT
WITH t AS (
		SELECT vp.tplant, v2.id_point, vp.npp
		FROM soif.v2e5point vp
		--INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
		INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
		WHERE v2.annee = 2024
		)
UPDATE inv_prod_new.description d
SET tplant = t.tplant
FROM t
WHERE t.id_point = d.id_point;

 -- contrôle
SELECT vp.tplant, d.tplant, d.id_point, d.id_ech, v2.id_point, v2.npp, vp.npp
FROM soif.v2e5point vp
--INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
INNER JOIN inv_prod_new.description d ON v2.id_ech = d.id_ech AND v2.id_point = d.id_point
WHERE v2.annee = 2024;
------------------------------------------------------------------------------------

-- mise à jour de dispnr fouil ornr predom prnr tcnr  dans DESCRIPT_M1 en chargement V2 avec V2E5NRPOINT

WITH t AS (
		SELECT vp.dispnr, vp.fouil, vp.ornr, vp.predom, vp.prnr, vp.tcnr, v2.id_point, vp.npp
		FROM soif.v2e5nrpoint vp
		--INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
		INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
		WHERE v2.annee = 2024
		)
UPDATE inv_prod_new.descript_m1 d
SET dispnr = t.dispnr, fouil = t.fouil, ornr = t.ornr, predom = t.predom, prnr = t.prnr, tcnr = t.tcnr
FROM t
WHERE t.id_point = d.id_point;

 -- contrôle
SELECT vp.dispnr, d.dispnr, vp.fouil, d.fouil, vp.ornr, d.ornr, vp.predom, d.predom, vp.prnr, d.prnr, vp.tcnr, d.tcnr, d.id_point, d.id_ech, v2.id_point, v2.npp, vp.npp
FROM soif.v2e5nrpoint vp
--INNER JOIN states ps ON vp.npp = ps.npp AND ps.state >= 'E'
INNER JOIN inv_prod_new.v_liste_points_lt2 v2 ON vp.npp = v2.npp
INNER JOIN inv_prod_new.descript_m1 d ON v2.id_ech = d.id_ech AND v2.id_point = d.id_point
WHERE v2.annee = 2024;





