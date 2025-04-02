
-- correction de la numérotation d'arbres

WITH t0 AS (
    SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY a) AS rang_a,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY azpr_gd, dpr_cm, a) AS rang_az
    FROM v_liste_points_lt1 v
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    WHERE azpr_gd IS NOT NULL
    AND annee = 2024
)
, t1 AS (
     SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm, rang_a - rang_az AS gap,
     DENSE_RANK() OVER(PARTITION BY npp ORDER BY npp,
     ABS(rang_a - rang_az) DESC, rang_a - rang_az DESC) AS rang_ecart
     FROM t0
     WHERE rang_a <> rang_az
)
SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm, gap
FROM t1
WHERE rang_ecart = 1
ORDER BY npp, a;


BEGIN;

CREATE TEMPORARY TABLE corrections AS 
WITH t0 AS (
    SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY a) AS rang_a,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY azpr_gd, dpr_cm, a) AS rang_az
    FROM v_liste_points_lt1 v
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    WHERE azpr_gd IS NOT NULL
    AND annee = 2024
)
SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm, rang_a - rang_az AS gap, a + (rang_az - rang_a) AS new_a, 
DENSE_RANK() OVER(PARTITION BY npp ORDER BY npp,
ABS(rang_a - rang_az) DESC, rang_a - rang_az DESC) AS rang_ecart
FROM t0
WHERE rang_a <> rang_az;

WITH corre AS (
    SELECT *
    FROM corrections
)
, update_arbre_m1_2014 AS (
    UPDATE arbre_m1_2014 a
    SET a = c.new_a + 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a = c.a
)
, update_accroissement AS (
    UPDATE accroissement a
    SET a = c.new_a + 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a = c.a
)
, update_age AS (
    UPDATE age a
    SET a = c.new_a + 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a = c.a
)
, update_arbre_m1 AS (
    UPDATE arbre_m1 a
    SET a = c.new_a + 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a = c.a
)
, update_sante AS (
    UPDATE sante a
    SET a = c.new_a + 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a = c.a
)
, update_arbre_2014 AS (
    UPDATE arbre_2014 a
    SET a = c.new_a + 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a = c.a
)
UPDATE arbre a
SET a = c.new_a + 1000
FROM corre c
WHERE a.id_ech = c.id_ech
AND a.id_point = c.id_point
AND a.a = c.a;

WITH corre AS (
    SELECT *
    FROM corrections
)
, update_arbre_m1_2014 AS (
    UPDATE arbre_m1_2014 a
    SET a = a.a - 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a > 1000
)
, update_accroissement AS (
    UPDATE accroissement a
    SET a = a.a - 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a > 1000
)
, update_age AS (
    UPDATE age a
    SET a = a.a - 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a > 1000
)
, update_arbre_m1 AS (
    UPDATE arbre_m1 a
    SET a = a.a - 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a > 1000
)
, update_sante AS (
    UPDATE sante a
    SET a = a.a - 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a > 1000
)
, update_arbre_2014 AS (
    UPDATE arbre_2014 a
    SET a = a.a - 1000
    FROM corre c
    WHERE a.id_ech = c.id_ech
    AND a.id_point = c.id_point
    AND a.a > 1000
)
UPDATE arbre a
SET a = a.a - 1000
FROM corre c
WHERE a.id_ech = c.id_ech
AND a.id_point = c.id_point
AND a.a > 1000;


DROP TABLE corrections;

COMMIT;


-- CORRECTIONS ASSOCIÉS À DES PROBLÈMES SUR ARBAT

-- Les ARBAT à mettre à jour

UPDATE arbre_m1 SET suppl = NULL WHERE id_ech = 114 AND id_point = 1223787 AND a IN (7, 8);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 7}'::jsonb WHERE id_ech = 114 AND id_point = 1199906 AND a IN (7, 8);
UPDATE arbre_m1 SET suppl = NULL WHERE id_ech = 114 AND id_point = 1225644 AND a IN (17);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 18}'::jsonb WHERE id_ech = 114 AND id_point = 1225644 AND a IN (18, 19, 20, 24, 29);

/*
SELECT v.npp, v.id_point, a.id_point, a.a, a.suppl
FROM v_liste_points_lt1 v
INNER JOIN arbre_m1 a USING (id_ech, id_point)
WHERE v.npp IN ('24-56-059-1-143T', '24-53-100-1-118T', '24-17-126-1-210T');
*/


-----------------------------------------------------------------------------------------
-- ÉCOLOGIE

CREATE UNLOGGED TABLE public.corr_eco (
    npp CHAR(16),
    donnee TEXT,
    old_val TEXT,
    new_val TEXT
);

\COPY public.corr_eco FROM '/home/lhaugomat/Documents/ECHANGES/MES_SCRIPTS/campagne_2024/00_prod/corrections_eco_2024.csv' WITH CSV DELIMITER ';' NULL AS 'NA' HEADER

-- On passe les noms de données en majuscules
UPDATE public.corr_eco
SET donnee = upper(donnee);

/* Vérifications préalables
-- Décompte des corrections par données corrigées
SELECT donnee, count(*)
FROM public.corr_eco
GROUP BY 1
ORDER BY 2, 1;

-- Vérification du type de point : première visite, deuxième visite, première visite sur deuxième PI
SELECT count(*)
FROM public.corr_eco; -- 60 corrections

SELECT count(*)
FROM public.corr_eco ce
INNER JOIN v_liste_points_lt1 vp USING (npp); -- 58 corrections

SELECT count(*)
FROM public.corr_eco ce
INNER JOIN v_liste_points_lt2 vp USING (npp); -- 0 correction

SELECT count(*)
FROM public.corr_eco ce
INNER JOIN v_liste_points_lt1_pi2 vp ON ce.npp = vp.nppr; -- 2 corrections

SELECT *
FROM public.corr_eco ce
INNER JOIN v_liste_points_lt1_pi2 vp ON ce.npp = vp.nppr; -- 2 corrections

SELECT donnee, count(*)
FROM public.corr_eco
GROUP BY 1
ORDER BY 1;

TABLE public.corr_eco;

-- Corrections qui n'en sont pas
SELECT *
FROM public.corr_eco
WHERE old_val = new_val; --> 0 ligne

-- Comparaison à la valeur initiale pour CODESP
SELECT ce.npp, f.codesp, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN public.corr_eco ce USING (npp)
LEFT JOIN flore f ON vp.id_ech = f.id_ech AND vp.id_point = f.id_point AND ce.old_val = f.codesp
WHERE ce.donnee = 'CODESP'
AND (f.codesp IS NOT DISTINCT FROM ce.new_val OR f.codesp IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour HUMUS
SELECT ce.npp, e.humus, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'HUMUS'
AND (e.humus IS NOT DISTINCT FROM ce.new_val OR e.humus IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour _HUMUS
SELECT ce.npp, e.*, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = '_HUMUS';

-- Comparaison à la valeur initiale pour OBSTOPO
SELECT ce.npp, e.obstopo, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'OBSTOPO'
AND (e.obstopo IS NOT DISTINCT FROM ce.new_val OR e.obstopo IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour OFR
SELECT ce.npp, e.ofr, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie_2017 e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'OFR'
AND (e.ofr IS NOT DISTINCT FROM ce.new_val OR e.ofr IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour OLN
SELECT ce.npp, e.oln, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie_2017 e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'OLN'
AND (e.oln IS NOT DISTINCT FROM ce.new_val OR e.oln IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour OLT
SELECT ce.npp, e.olt, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie_2017 e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'OLT'
AND (e.olt IS NOT DISTINCT FROM ce.new_val OR e.olt IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour PCALF
SELECT ce.npp, e.pcalf, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'PCALF'
AND (e.pcalf IS NOT DISTINCT FROM ce.new_val OR e.pcalf IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour PGLEY
SELECT ce.npp, e.pgley, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'PGLEY'
AND (e.pgley IS NOT DISTINCT FROM ce.new_val OR e.pgley IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour ROCHE
SELECT ce.npp, e.roche, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'ROCHE'
AND (e.roche IS NOT DISTINCT FROM ce.new_val OR e.roche IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour _ROCHE
SELECT ce.npp, e.*, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = '_ROCHE';

SELECT ce.npp, e.*, ce.old_val, ce.new_val
FROM v_liste_points_lt1_pi2 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce ON vp.nppr = ce.npp
WHERE ce.donnee = '_ROCHE';

-- Comparaison à la valeur initiale pour TSOL
SELECT ce.npp, e.tsol, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'TSOL'
AND (e.tsol IS NOT DISTINCT FROM ce.new_val OR e.tsol IS DISTINCT FROM ce.old_val);

-- Comparaison à la valeur initiale pour _TSOL
SELECT ce.npp, e.*, ce.old_val, ce.new_val
FROM v_liste_points_lt1 vp
INNER JOIN ecologie e USING (id_ech, id_point)
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = '_TSOL';
*/


-- Requête dynamique de récupération des anciennes valeurs écologiques 
SELECT vp.id_ech, vp.id_point, ce.donnee AS donnee, ce.old_val, 
'UNION SELECT id_ech, id_point, donnee AS donnee, ' || lower(donnee) || '::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$' || npp || '$$ AND ' || lower(donnee) || ' IS NOT NULL AND donnee = $$' || donnee || '$$' AS requete
FROM v_liste_points_lt1 vp
INNER JOINTABLE public.corr_eco public.corr_eco ce USING (npp)
WHERE ce.donnee NOT LIKE '\_%' --
AND ce.donnee NOT IN ('ABOND', 'CODESP', 'INCO_FLOR')
AND ce.old_val IS NOT NULL
ORDER BY id_ech, id_point; --> 52 lignes au lieu de 60 car 8 pour lesquelles donnee est de la forme _data ou old_val à NULL


-- On l'utilise pour insérer dans RECODAGE
WITH anciens AS (
	SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, oh::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie_2017 e USING (id_ech, id_point) WHERE npp = $$24-01-253-1-149T$$ AND oh IS NOT NULL AND donnee = $$OH$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-03-212-1-158T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, num_hab::TEXT AS num_hab, hab::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN habitat e USING (id_ech, id_point) WHERE npp = $$24-03-219-1-143T$$ AND hab IS NOT NULL AND donnee = $$HAB1$$ AND num_hab = 1
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-04-295-1-195T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-04-295-1-197T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-04-301-1-189T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-04-305-1-199T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-05-301-1-185T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-05-303-1-185T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, num_hab::TEXT AS num_hab, hab::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN habitat e USING (id_ech, id_point) WHERE npp = $$24-07-256-1-178T$$ AND hab IS NOT NULL AND donnee = $$HAB1$$ AND num_hab = 1
	UNION SELECT id_ech, id_point, donnee AS donnee, num_hab::TEXT AS num_hab, hab::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN habitat e USING (id_ech, id_point) WHERE npp = $$24-08-197-1-023T$$ AND hab IS NOT NULL AND donnee = $$HAB1$$ AND num_hab = 1
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-08-207-1-038T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-09-191-1-281T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-09-208-1-282T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-11-233-1-259T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-13-273-1-231T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-13-296-1-232T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-14-093-1-095T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, num_hab::TEXT AS num_hab, hab::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN habitat e USING (id_ech, id_point) WHERE npp = $$24-23-167-1-171T$$ AND hab IS NOT NULL AND donnee = $$HAB2$$ AND num_hab = 2
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-26-287-1-203T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-27-129-1-075T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-32-160-1-256T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-32-160-1-256T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, pcalf::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-32-176-1-270T$$ AND pcalf IS NOT NULL AND donnee = $$PCALF$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-33-114-1-212T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-34-245-1-245T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-40-125-1-275T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-41-164-1-118T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-41-166-1-126T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-41-168-1-122T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-41-168-1-128T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-41-169-1-125T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-41-171-1-123T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-49-106-1-147T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-49-107-1-147T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-49-118-1-135T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-56-057-1-143T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-56-057-1-143T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, oh::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie_2017 e USING (id_ech, id_point) WHERE npp = $$24-57-247-1-031T$$ AND oh IS NOT NULL AND donnee = $$OH$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-59-156-1-014T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-60-152-1-058T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, num_hab::TEXT AS num_hab, hab::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN habitat e USING (id_ech, id_point) WHERE npp = $$24-66-227-1-279T$$ AND hab IS NOT NULL AND donnee = $$HAB1$$ AND num_hab = 1
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-66-229-1-277T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-69-242-1-162T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, num_hab::TEXT AS num_hab, hab::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN habitat e USING (id_ech, id_point) WHERE npp = $$24-71-226-1-124T$$ AND hab IS NOT NULL AND donnee = $$HAB1$$ AND num_hab = 1
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, pcalf::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-72-120-1-124T$$ AND pcalf IS NOT NULL AND donnee = $$PCALF$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-72-130-1-116T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-72-130-1-116T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-81-196-1-244T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-81-201-1-245T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-83-323-1-219T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
	UNION SELECT id_ech, id_point, donnee AS donnee, NULL AS num_hab, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$24-84-274-1-206T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
)
--INSERT INTO recodage (date_recodage, donnee_cible, ancienne_valeur)
SELECT --id_ech, id_point, donnee, 
  now()::date AS date_recodage
, jsonb_build_object('id_ech', id_ech) || jsonb_build_object('id_point', id_point) || jsonb_build_object('donnee', donnee) || jsonb_build_object('num_hab', num_hab::int2) || jsonb_build_object('table_origine', 'HABITAT') || jsonb_build_object('note', 'Valeur initiale') AS donnee_cible
, ancienne_valeur
FROM anciens a
WHERE donnee IN ('HAB1', 'HAB2')
UNION
SELECT --id_ech, id_point, donnee, 
  now()::date AS date_recodage
, jsonb_build_object('id_ech', id_ech) || jsonb_build_object('id_point', id_point) || jsonb_build_object('donnee', donnee) || jsonb_build_object('table_origine', 'ECOLOGIE_2017') || jsonb_build_object('note', 'Valeur initiale') AS donnee_cible
, ancienne_valeur
FROM anciens a
WHERE donnee = 'OH'
UNION
SELECT --id_ech, id_point, donnee, 
  now()::date AS date_recodage
, jsonb_build_object('id_ech', id_ech) || jsonb_build_object('id_point', id_point) || jsonb_build_object('donnee', donnee) || jsonb_build_object('table_origine', 'ECOLOGIE') || jsonb_build_object('note', 'Valeur initiale') AS donnee_cible
, ancienne_valeur
FROM anciens a
WHERE donnee NOT IN ('OH', 'HAB1', 'HAB2')
ORDER BY id_ech , id_point;






/* --> sans objet en 2024
-- Requête dynamique de récupération des anciennes valeurs floristiques 
SELECT vp.id_ech, vp.id_point, ce.donnee AS donnee, ce.old_val, 
'UNION SELECT id_ech, id_point, donnee AS donnee, ' || lower(donnee) || '::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN flore e USING (id_ech, id_point) WHERE npp = $$' || npp || '$$ AND codesp = $$' || old_val || '$$ AND ' || lower(donnee) || ' IS NOT NULL AND donnee = $$' || donnee || '$$' AS requete
FROM v_liste_points_lt1 vp
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'CODESP'
AND ce.old_val IS NOT NULL
ORDER BY id_ech, id_point;
*/
/*
-- On l'utilise pour insérer dans RECODAGE --> sans objet en 2024
WITH anciens AS (
    SELECT id_ech, id_point, donnee AS donnee, codesp::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN flore e USING (id_ech, id_point) WHERE npp = $$23-43-244-1-191T$$ AND codesp = $$9388$$ AND codesp IS NOT NULL AND donnee = $$CODESP$$
    UNION SELECT id_ech, id_point, donnee AS donnee, codesp::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN flore e USING (id_ech, id_point) WHERE npp = $$23-43-245-1-188T$$ AND codesp = $$9519$$ AND codesp IS NOT NULL AND donnee = $$CODESP$$
)
INSERT INTO recodage (date_recodage, donnee_cible, ancienne_valeur)
SELECT --id_ech, id_point, donnee, 
  now()::date AS date_recodage
, jsonb_build_object('id_ech', id_ech) || jsonb_build_object('id_point', id_point) || jsonb_build_object('donnee', donnee) || jsonb_build_object('table_origine', 'FLORE') || jsonb_build_object('note', 'Valeur initiale') AS donnee_cible
, ancienne_valeur
FROM anciens
ORDER BY id_ech, id_point;
*/

-- Requête dynamique de récupération des nouvelles valeurs en écologie
SELECT vp.id_ech, vp.id_point, ce.donnee AS donnee, 
'UPDATE ecologie SET ' || lower(donnee) || ' = $$' || new_val || '$$ WHERE id_ech = ' || id_ech || ' AND id_point = '  || id_point || ';'
FROM v_liste_points_lt1 vp
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee NOT LIKE '\_%' --
AND ce.donnee NOT IN ('ABOND', 'CODESP', 'INCO_FLOR')
ORDER BY id_ech, id_point;


-- On l'utilise pour mettre à jour ECOLOGIE
UPDATE ecologie_2017 SET oh = $$0$$ WHERE id_ech = 114 AND id_point = 1189939;
UPDATE ecologie SET roche = $$930$$ WHERE id_ech = 114 AND id_point = 1191593;
UPDATE habitat SET hab = $$41.22A$$ WHERE id_ech = 114 AND id_point = 1191721 AND num_hab = 1;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1191891;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1191893;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1192045;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1192171;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1192892;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1192934;
UPDATE habitat SET hab = $$41.71C$$ WHERE id_ech = 114 AND id_point = 1193871 AND num_hab = 1;
UPDATE habitat SET hab = $$41.511BA$$ WHERE id_ech = 114 AND id_point = 1194265 AND num_hab = 1;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1194505;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1194617;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1194931;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1196186;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1197294;
UPDATE ecologie SET humus = $$45$$ WHERE id_ech = 114 AND id_point = 1197642;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1197954;
UPDATE habitat SET hab = $$41.14F$$ WHERE id_ech = 114 AND id_point = 1203036 AND num_hab = 2;
UPDATE ecologie SET tsol = $$10$$ WHERE id_ech = 114 AND id_point = 1205671;
UPDATE ecologie SET humus = $$22$$ WHERE id_ech = 114 AND id_point = 1206037;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1209766;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1209766;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1210310;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1211721;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1215326;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1216705;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1216747;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1216775;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1216781;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1216791;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1216805;
UPDATE ecologie SET tsol = $$08$$ WHERE id_ech = 114 AND id_point = 1221036;
UPDATE ecologie SET tsol = $$08$$ WHERE id_ech = 114 AND id_point = 1221064;
UPDATE ecologie SET tsol = $$83$$ WHERE id_ech = 114 AND id_point = 1221323;
UPDATE ecologie SET tsol = $$83$$ WHERE id_ech = 114 AND id_point = 1225596;
UPDATE ecologie SET humus = $$80$$ WHERE id_ech = 114 AND id_point = 1225596;
UPDATE ecologie_2017 SET oh = $$0$$ WHERE id_ech = 114 AND id_point = 1226125;
UPDATE ecologie SET humus = $$40$$ WHERE id_ech = 114 AND id_point = 1227390;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1228009;
UPDATE habitat SET hab = $$41.12MB$$ WHERE id_ech = 114 AND id_point = 1231778 AND num_hab = 1;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1231808;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1233047;
UPDATE habitat SET hab = $$41.14A$$ WHERE id_ech = 114 AND id_point = 1234017 AND num_hab = 1;
UPDATE ecologie SET pcalf = $$X$$ WHERE id_ech = 114 AND id_point = 1234978;
UPDATE ecologie SET tsol = $$82$$ WHERE id_ech = 114 AND id_point = 1235215;
UPDATE ecologie SET humus = $$28$$ WHERE id_ech = 114 AND id_point = 1235215;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1239068;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1239137;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 114 AND id_point = 1240559;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 114 AND id_point = 1240694;

/*
-- mise à jour des données FLORE --> sans objet en 2024
UPDATE flore SET codesp = 'A530' WHERE id_ech = 104 AND id_point = 1162806 AND codesp = '9388';
UPDATE flore SET codesp = '9519' WHERE id_ech = 104 AND id_point = 1162821 AND codesp = '9382';

INSERT INTO flore (id_ech, id_point, codesp, abond, inco_flor)
VALUES (104, 1162010, 'A040', '1', NULL)
, (104, 1162821, '9388', '1', '4')
, (104, 1162821, '9455', '1', '4');
*/

-- ajout ou mise à jour des doutes
WITH maj AS (
    SELECT ce.*, e.id_ech, e.id_point, e.qual_data, ce.new_val, t.*, t.donnee['qdonnee']->>0 AS qdonnee
    , CASE
        WHEN t.INDEX IS NOT NULL THEN jsonb_set(e.qual_data, ('{' || t.index - 1 || ', mode}')::TEXT[], ('"' || ce.new_val || '"')::JSONB, FALSE)
        WHEN e.qual_data IS NOT NULL THEN e.qual_data || ('[{"mode": "' || ce.new_val || '", "donnee": "' || ce.donnee || '", "qdonnee": "' || COALESCE(t.donnee['qdonnee']->>0, ce.donnee) || '"}]')::jsonb 
        ELSE ('[{"mode": "' || ce.new_val || '", "donnee": "' || ce.donnee || '", "qdonnee": "' || COALESCE(t.donnee['qdonnee']->>0, ce.donnee) || '"}]')::jsonb 
      END AS new_qual_data
    FROM public.corr_eco ce
    INNER JOIN v_liste_points_lt1 v1 USING (npp)
    INNER JOIN ecologie e USING (id_ech, id_point)
    LEFT JOIN LATERAL jsonb_array_elements(e.qual_data) WITH ORDINALITY AS t (donnee, index) ON t.donnee['donnee']->>0 = right(ce.donnee, -1)
    WHERE ce.donnee LIKE '\_%'
)
UPDATE ecologie ec
SET qual_data = new_qual_data
FROM maj m
WHERE ec.id_ech = m.id_ech
AND ec.id_point = m.id_point;

WITH maj AS (
    SELECT ce.*, e.id_ech, e.id_point, e.qual_data, ce.new_val, t.*, t.donnee['qdonnee']->>0 AS qdonnee
    , CASE
        WHEN t.INDEX IS NOT NULL THEN jsonb_set(e.qual_data, ('{' || t.index - 1 || ', mode}')::TEXT[], ('"' || ce.new_val || '"')::JSONB, FALSE)
        WHEN e.qual_data IS NOT NULL THEN e.qual_data || ('[{"mode": "' || ce.new_val || '", "donnee": "' || ce.donnee || '", "qdonnee": "' || COALESCE(t.donnee['qdonnee']->>0, ce.donnee) || '"}]')::jsonb 
        ELSE ('[{"mode": "' || ce.new_val || '", "donnee": "' || ce.donnee || '", "qdonnee": "' || COALESCE(t.donnee['qdonnee']->>0, ce.donnee) || '"}]')::jsonb 
      END AS new_qual_data
    FROM public.corr_eco ce
    INNER JOIN v_liste_points_lt1_pi2 v1 ON ce.npp = v1.nppr
    INNER JOIN ecologie e USING (id_ech, id_point)
    LEFT JOIN LATERAL jsonb_array_elements(e.qual_data) WITH ORDINALITY AS t (donnee, index) ON t.donnee['donnee']->>0 = right(ce.donnee, -1)
    WHERE ce.donnee LIKE '\_%'
)
UPDATE ecologie ec
SET qual_data = new_qual_data
FROM maj m
WHERE ec.id_ech = m.id_ech
AND ec.id_point = m.id_point;

DROP TABLE public.corr_eco;

-- Suppression des classes RPPGO sans aucune tige (décomptes tous égaux à 0)
DELETE FROM espar_renouv
WHERE nint = 0 AND nbrou = 0 AND nfrot = 0 AND nmixt = 0;


