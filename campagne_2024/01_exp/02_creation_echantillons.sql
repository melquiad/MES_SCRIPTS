BEGIN;
 /*--> en cas d'erreurs d'insertion d'échantillon
--DELETE FROM inv_exp_nm.unite_ech WHERE id_ech IN (49); 
--DELETE FROM inv_exp_nm.echantillon WHERE id_ech IN (49, 50);
--SELECT setval('inv_exp_nm.echantillon_id_ech_seq',48);
--ALTER SEQUENCE inv_exp_nm.echantillon_id_ech_seq RESTART 48;
*/
--SELECT * FROM inv_exp_nm.echantillon_id_ech_seq;
--SELECT * FROM inv_exp_nm.echantillon ORDER BY id_ech DESC;

WITH nb_pts1 AS (
    SELECT count(*) AS nb_pts_1
    FROM inv_exp_nm.e1point 
    WHERE incref = 19
)
, ins_ech_1 AS (
    INSERT INTO inv_exp_nm.echantillon (nom_ech, type_enquete, type_unites, usite, site, surf_dom, deb_temp, fin_temp, proprietaire, phase_stat, id_parent, taille_ech, url_script, cyc, incref, inv, code_famille_echantillon, famille, format)
    SELECT 'Echantillon annuel IFN 2024 - phase 1', 'S', 'P', 'P', 'F', 549435050594.037, 2024, 2024, 'DT', 1, NULL, nb_pts_1, NULL, '5', 19, 'T', 'IFN_PHASE1', 'INV_EXP_NM', 'TE1POINT'
    FROM nb_pts1
    RETURNING id_ech
)
, nb_pts2 AS (
    SELECT count(*) AS nb_pts_2
    FROM inv_exp_nm.e2point 
    WHERE incref = 19
)
, ins_ech_2 AS (
    INSERT INTO inv_exp_nm.echantillon (nom_ech, type_enquete, type_unites, usite, site, surf_dom, deb_temp, fin_temp, proprietaire, phase_stat, id_parent, taille_ech, url_script, cyc, incref, inv, code_famille_echantillon, famille, format)
    SELECT 'Echantillon annuel IFN 2024 - phase 2', 'S', 'P', 'P', 'F', 549435050594.037, 2024, 2024, 'DT', 2, ie1.id_ech, np2.nb_pts_2, NULL, '5', 19, 'T', 'IFN_PHASE2', 'INV_EXP_NM', 'TE2POINT'
    FROM ins_ech_1 ie1
    CROSS JOIN nb_pts2 np2
)
INSERT INTO inv_exp_nm.unite_ech (id_ech, id_unite, poids)
SELECT ie1.id_ech, id_unite, poids
FROM inv_exp_nm.e1point
CROSS JOIN ins_ech_1 ie1
WHERE incref = 19;

UPDATE inv_exp_nm.e2point p2
SET id_unite = p1.id_unite
FROM inv_exp_nm.e1point p1
WHERE p2.npp = p1.npp
AND p1.incref = 19;


/*
-- Vérification d'absence de doublons d'ID_UNITE dans E2POINT
SELECT id_unite, count(id_unite)
FROM inv_exp_nm.e2point
GROUP BY id_unite
HAVING count(id_unite) > 1;
*/

INSERT INTO inv_exp_nm.unite_ech (id_ech, id_unite, poids)
SELECT (SELECT last_value FROM inv_exp_nm.echantillon_id_ech_seq), id_unite, poids
FROM inv_exp_nm.e2point
WHERE incref = 19;

COMMIT;

VACUUM ANALYZE inv_exp_nm.unite_ech;
VACUUM ANALYZE inv_exp_nm.e1point;
VACUUM ANALYZE inv_exp_nm.e2point;

