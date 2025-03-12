-- Correction de TCAT10 sur 8 points
/*UPDATE descript_m1
SET tcat10 = 1
WHERE id_ech = 104
AND id_point IN (1143209, 1156361, 1158521, 1159141, 1164922, 1176061, 1187450);

UPDATE descript_m1
SET tcat10 = 2
WHERE id_ech = 104
AND id_point = 1160934;

-- correction de PEUPNR et SVER sur 3 points
UPDATE description d
SET peupnr = '2', sver = NULL, suppl->>'cam' = NULL
FROM v_liste_points_lt1 v
INNER JOIN descript_m1 dm USING (id_ech, id_point)
WHERE v.annee = 2023
AND d.peupnr != '2'
AND dm.tcat10 = 0
AND d.dc = '1'
AND d.id_ech = v.id_ech
AND d.id_point = v.id_point;

-- PASSER QUELQUES CAM À NULL A POSTERIORI
UPDATE description
SET suppl = CASE WHEN suppl - 'cam' = '{}'::jsonb THEN NULL ELSE suppl - 'cam' END
WHERE (id_ech, id_point) IN ((104, 1158424), (104, 1151258), (104, 1166422));
*/
-- correction de la numérotation d'arbres

WITH t0 AS (
    SELECT npp, id_ech, id_point, a, azpr_gd, dpr_cm,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY a) AS rang_a,
    DENSE_RANK() OVER(PARTITION BY npp ORDER BY azpr_gd, dpr_cm, a) AS rang_az
    FROM v_liste_points_lt1 v
    INNER JOIN arbre a USING (id_ech, id_point)
    INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
    WHERE azpr_gd IS NOT NULL
    AND annee = 2023
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
*/

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
    AND annee = 2023
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

SELECT v.id_point, am.a, am.suppl->>'arbat' AS suppl
FROM arbre_m1 am
INNER JOIN arbre a USING (id_ech,id_point,a)
INNER JOIN v_liste_points_lt1 v USING (id_ech,id_point)
WHERE v.npp = '24-07-257-1-205T' AND a IN (7, 8);
--WHERE v.id_ech = 114 AND am.suppl IS NOT NULL;




UPDATE arbre_m1  SET suppl = (COALESCE(am.suppl, '{}'::jsonb)) || '{"arbat": 999}'::jsonb
FROM arbre
INNER JOIN arbre_m1 am USING (id_ech, id_point, a)
INNER JOIN v_liste_points_lt1 v USING (id_ech, id_point)
WHERE v.id_ech = 114 AND v.npp = '24-17-126-1-210T' AND am.a IN (7, 8);
---------------------------------------------------------------------------------------------------------

SELECT v.npp, v.id_point
FROM v_liste_points_lt1 v
WHERE v.npp IN ('24-07-257-1-205T', '24-56-059-1-143T', '24-53-100-1-118T', '24-17-126-1-210T');

UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 7}'::jsonb WHERE id_ech = 114 AND id_point = 1199906 AND a IN (7, 8);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 7}'::jsonb WHERE id_ech = 114 AND id_point = 1193931 AND a IN (7, 8);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 7}'::jsonb WHERE id_ech = 114 AND id_point = 1223787 AND a IN (7, 8);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat":""}'::jsonb WHERE id_ech = 114 AND id_point = 1225644 AND a IN (17);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 18}'::jsonb WHERE id_ech = 114 AND id_point = 1225644 AND a IN (18, 19, 20, 24, 29);
/*-- Les ARBAT à supprimer
UPDATE arbre_m1
SET suppl = CASE WHEN suppl - 'arbat' =  '{}'::jsonb THEN NULL ELSE suppl - 'arbat' END
WHERE id_ech = 104
AND (id_point, a) IN (
(1138495, 9), (1138495, 10)
, (1138568, 2), (1138568, 3)
, (1151305, 4)
, (1155058, 7), (1155058, 8)
, (1162014, 4), (1162014, 6)
, (1163898, 20)
, (1169366, 8), (1169366, 9)
, (1155784, 27), (1155784, 28)
);*/

-- Les ARBAT à mettre à jour
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 5}'::jsonb WHERE id_ech = 104 AND id_point = 1151305 AND a IN (5, 6);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 19}'::jsonb WHERE id_ech = 104 AND id_point = 1162392 AND a IN (19, 20);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 21}'::jsonb WHERE id_ech = 104 AND id_point = 1163898 AND a IN (21, 22);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 29}'::jsonb WHERE id_ech = 104 AND id_point = 1163898 AND a IN (29, 30);
UPDATE arbre_m1 SET suppl = (COALESCE(suppl, '{}'::jsonb)) || '{"arbat": 11}'::jsonb WHERE id_ech = 104 AND id_point = 1188928 AND a IN (11, 12);

-- mise à jour de DPR_CM / C13_MM pour corriger la distance liée à ARBAT
INSERT INTO recodage (date_recodage, donnee_cible, ancienne_valeur)
SELECT --id_ech, id_point, donnee, 
  now()::date AS date_recodage
, jsonb_build_object('id_ech', 104) || jsonb_build_object('id_point', 1169907) || jsonb_build_object('donnee', 'C13_MM') || jsonb_build_object('table_origine', 'ARBRE') || jsonb_build_object('note', 'Valeur initiale') AS donnee_cible
, 549
UNION 
SELECT --id_ech, id_point, donnee, 
  now()::date AS date_recodage
, jsonb_build_object('id_ech', 104) || jsonb_build_object('id_point', 1169907) || jsonb_build_object('donnee', 'DPR_CM') || jsonb_build_object('table_origine', 'ARBRE_M1') || jsonb_build_object('note', 'Valeur initiale') AS donnee_cible
, 312;

UPDATE arbre_m1 SET dpr_cm = 590 WHERE id_ech = 104 AND id_point = 1168242 AND a = 5;
UPDATE arbre_m1 SET dpr_cm = 549 WHERE id_ech = 104 AND id_point = 1169907 AND a = 3;
UPDATE arbre SET c13_mm = 312 WHERE id_ech = 104 AND id_point = 1169907 AND a = 3;


-- Corrections sur VEGET5
UPDATE arbre_m2
SET veget5 = 'M'
WHERE id_ech = 105
AND (id_point, a) IN ((907245, 10), (886033, 3), (879630, 8), (862543, 11), (908070, 4), (868850, 1));

UPDATE arbre_m2
SET veget5 = '2'
WHERE id_ech = 105
AND (id_point, a) IN ((895405, 2), (865206, 3), (899891, 3));

-- Correction sur DEF5
UPDATE reco_m2
SET def5 = '5'
WHERE id_ech = 105
AND id_point = 889766;


-- Correction ARBAT renseigné => ORI = 2
UPDATE arbre_m1
SET ori = '2'
WHERE id_ech IN (104, 105)
AND suppl->>'arbat' IS NOT NULL;

-- Corrections d'incohérences entre arbres levés et descriptions de couvert / flore
INSERT INTO espar_r (id_ech, id_point, espar, tcr10, tclr10, p7ares, cible)
VALUES (104, 1173240, '18C', 0, 0, '1', '1');

UPDATE arbre_m1
SET espar = '12V'
WHERE id_ech = 104
AND id_point = 1139271
AND a = 1;

UPDATE arbre_m1
SET espar = '12V'
WHERE id_ech = 104
AND id_point = 1169560
AND a = 13;

UPDATE arbre_m1
SET espar = '49FA'
WHERE id_ech = 104
AND id_point = 1153156
AND a = 1;

UPDATE espar_r
SET espar = '69JC'
WHERE id_ech = 104
AND id_point = 1153156
AND espar = '69';

INSERT INTO espar_r (id_ech, id_point, espar, tcr10, tclr10, p7ares, cible)
VALUES (104, 1156996, '23PC', 0, 0, '1', '1');

UPDATE flore
SET codesp = '3290'
WHERE id_ech = 104
AND id_point = 1156996
AND codesp = '9083';


/*
  ÉCOLOGIE
*/

CREATE UNLOGGED TABLE public.corr_eco (
    npp CHAR(16),
    donnee TEXT,
    old_val TEXT,
    new_val TEXT
);

\COPY public.corr_eco FROM '/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/production/Incref18/donnees/corrections_ecologie_2023.csv' WITH CSV DELIMITER ';' NULL AS 'NA' HEADER

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
FROM public.corr_eco; -- 120 corrections

SELECT count(*)
FROM public.corr_eco ce
INNER JOIN v_liste_points_lt1 vp USING (npp); -- 119 corrections

SELECT count(*)
FROM public.corr_eco ce
INNER JOIN v_liste_points_lt2 vp USING (npp); -- 0 correction

SELECT count(*)
FROM public.corr_eco ce
INNER JOIN v_liste_points_lt1_pi2 vp ON ce.npp = vp.nppr; -- 1 correction

SELECT *
FROM public.corr_eco ce
INNER JOIN v_liste_points_lt1_pi2 vp ON ce.npp = vp.nppr; -- 1 correction

SELECT donnee, count(*)
FROM public.corr_eco
GROUP BY 1
ORDER BY 1;

TABLE public.corr_eco;

-- Corrections qui n'en sont pas
SELECT *
FROM public.corr_eco
WHERE old_val = new_val;

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

/*
-- Requête dynamique de récupération des anciennes valeurs écologiques
SELECT vp.id_ech, vp.id_point, ce.donnee AS donnee, ce.old_val, 
'UNION SELECT id_ech, id_point, donnee AS donnee, ' || lower(donnee) || '::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$' || npp || '$$ AND ' || lower(donnee) || ' IS NOT NULL AND donnee = $$' || donnee || '$$' AS requete
FROM v_liste_points_lt1 vp
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee NOT LIKE '\_%' --
AND ce.donnee NOT IN ('ABOND', 'CODESP', 'INCO_FLOR')
AND ce.old_val IS NOT NULL
ORDER BY id_ech, id_point;
*/

-- On l'utilise pour insérer dans RECODAGE
WITH anciens AS (
    SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-02-173-1-058T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, olt::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie_2017 e USING (id_ech, id_point) WHERE npp = $$23-06-332-1-201T$$ AND olt IS NOT NULL AND donnee = $$OLT$$
    UNION SELECT id_ech, id_point, donnee AS donnee, ofr::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie_2017 e USING (id_ech, id_point) WHERE npp = $$23-06-332-1-201T$$ AND ofr IS NOT NULL AND donnee = $$OFR$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-06-332-1-201T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-06-334-1-195T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-09-190-1-287T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-11-230-1-273T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-12-219-1-216T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-18-166-1-135T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-18-171-1-120T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-18-173-1-122T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-18-173-1-132T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-18-175-1-118T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-18-177-1-146T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-18-181-1-144T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-18-181-1-144T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, pgley::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-24-158-1-213T$$ AND pgley IS NOT NULL AND donnee = $$PGLEY$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-24-172-1-217T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-26-284-1-203T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, pcalf::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-27-120-1-085T$$ AND pcalf IS NOT NULL AND donnee = $$PCALF$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-29-007-1-132T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-30-246-1-223T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-33-134-1-227T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-33-134-1-237T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, pcalf::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-33-135-1-221T$$ AND pcalf IS NOT NULL AND donnee = $$PCALF$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-33-144-1-243T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-34-246-1-239T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-35-081-1-114T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-37-126-1-147T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-37-132-1-143T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-37-135-1-142T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-37-150-1-143T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, obstopo::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-40-124-1-267T$$ AND obstopo IS NOT NULL AND donnee = $$OBSTOPO$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-40-130-1-265T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-41-162-1-123T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-41-166-1-131T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-41-169-1-126T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-45-161-1-118T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-45-162-1-119T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-45-165-1-118T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-45-178-1-103T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-48-233-1-206T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-48-238-1-213T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-48-241-1-206T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-48-245-1-208T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-49-101-1-152T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-51-188-1-065T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-51-214-1-060T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-54-255-1-050T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-56-043-1-144T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-56-043-1-146T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-56-053-1-144T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-56-055-1-144T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-56-058-1-135T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-58-187-1-116T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-58-189-1-118T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-58-201-1-132T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-59-182-1-019T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-60-159-1-066T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-60-161-1-062T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-60-163-1-056T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-60-164-1-055T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-60-165-1-050T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-60-167-1-056T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-60-167-1-056T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-61-101-1-106T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, oln::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie_2017 e USING (id_ech, id_point) WHERE npp = $$23-67-276-1-029T$$ AND oln IS NOT NULL AND donnee = $$OLN$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-67-280-1-051T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-67-281-1-040T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-67-282-1-035T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-67-282-1-047T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-67-282-1-055T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-68-288-1-079T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-70-249-1-100T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-72-117-1-106T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-72-131-1-118T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-77-168-1-085T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-77-172-1-065T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-77-173-1-064T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-77-175-1-094T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-77-179-1-088T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-78-152-1-093T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-78-155-1-084T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, tsol::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-79-115-1-158T$$ AND tsol IS NOT NULL AND donnee = $$TSOL$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-79-121-1-158T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, humus::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-88-263-1-062T$$ AND humus IS NOT NULL AND donnee = $$HUMUS$$
    UNION SELECT id_ech, id_point, donnee AS donnee, typcai::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie_2017 e USING (id_ech, id_point) WHERE npp = $$23-88-267-1-050T$$ AND typcai IS NOT NULL AND donnee = $$TYPCAI$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-94-165-1-078T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
    UNION SELECT id_ech, id_point, donnee AS donnee, roche::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN ecologie e USING (id_ech, id_point) WHERE npp = $$23-95-155-1-070T$$ AND roche IS NOT NULL AND donnee = $$ROCHE$$
)
INSERT INTO recodage (date_recodage, donnee_cible, ancienne_valeur)
SELECT --id_ech, id_point, donnee, 
  now()::date AS date_recodage
, jsonb_build_object('id_ech', id_ech) || jsonb_build_object('id_point', id_point) || jsonb_build_object('donnee', donnee) || jsonb_build_object('table_origine', 'ECOLOGIE') || jsonb_build_object('note', 'Valeur initiale') AS donnee_cible
, ancienne_valeur
FROM anciens
ORDER BY id_ech, id_point;

/*
-- Requête dynamique de récupération des anciennes valeurs floristiques
SELECT vp.id_ech, vp.id_point, ce.donnee AS donnee, ce.old_val, 
'UNION SELECT id_ech, id_point, donnee AS donnee, ' || lower(donnee) || '::TEXT AS ancienne_valeur FROM v_liste_points_lt1 vp INNER JOIN public.corr_eco ce USING (npp) INNER JOIN flore e USING (id_ech, id_point) WHERE npp = $$' || npp || '$$ AND codesp = $$' || old_val || '$$ AND ' || lower(donnee) || ' IS NOT NULL AND donnee = $$' || donnee || '$$' AS requete
FROM v_liste_points_lt1 vp
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee = 'CODESP'
AND ce.old_val IS NOT NULL
ORDER BY id_ech, id_point;
*/

-- On l'utilise pour insérer dans RECODAGE
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

/*
-- Requête dynamique de récupération des nouvelles valeurs en écologie
SELECT vp.id_ech, vp.id_point, ce.donnee AS donnee, 
'UPDATE ecologie SET ' || lower(donnee) || ' = $$' || new_val || '$$ WHERE id_ech = ' || id_ech || ' AND id_point = '  || id_point || ';'
FROM v_liste_points_lt1 vp
INNER JOIN public.corr_eco ce USING (npp)
WHERE ce.donnee NOT LIKE '\_%' --
AND ce.donnee NOT IN ('ABOND', 'CODESP', 'INCO_FLOR')
ORDER BY id_ech, id_point;
*/

-- On l'utilise pour mettre à jour ECOLOGIE
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1135596;
UPDATE ecologie_2017 SET ofr = $$2$$ WHERE id_ech = 104 AND id_point = 1138459;
UPDATE ecologie SET humus = $$25$$ WHERE id_ech = 104 AND id_point = 1138459;
UPDATE ecologie_2017 SET olt = $$0$$ WHERE id_ech = 104 AND id_point = 1138459;
UPDATE ecologie SET tsol = $$33$$ WHERE id_ech = 104 AND id_point = 1138493;
UPDATE ecologie SET tsol = $$34$$ WHERE id_ech = 104 AND id_point = 1139668;
UPDATE ecologie SET tsol = $$33$$ WHERE id_ech = 104 AND id_point = 1141205;
UPDATE ecologie SET tsol = $$34$$ WHERE id_ech = 104 AND id_point = 1141844;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1145198;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1145231;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1145264;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1145274;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1145304;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1145384;
UPDATE ecologie SET humus = $$48$$ WHERE id_ech = 104 AND id_point = 1145511;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1145511;
UPDATE ecologie SET pgley = $$X$$ WHERE id_ech = 104 AND id_point = 1148944;
UPDATE ecologie SET humus = $$48$$ WHERE id_ech = 104 AND id_point = 1149401;
UPDATE ecologie SET humus = $$40$$ WHERE id_ech = 104 AND id_point = 1150694;
UPDATE ecologie SET pcalf = $$X$$ WHERE id_ech = 104 AND id_point = 1150900;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1151967;
UPDATE ecologie SET tsol = $$17$$ WHERE id_ech = 104 AND id_point = 1153585;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1155885;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1155895;
UPDATE ecologie SET pcalf = $$X$$ WHERE id_ech = 104 AND id_point = 1155905;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1156177;
UPDATE ecologie SET tsol = $$33$$ WHERE id_ech = 104 AND id_point = 1156781;
UPDATE ecologie SET humus = $$28$$ WHERE id_ech = 104 AND id_point = 1157463;
UPDATE ecologie SET tsol = $$11$$ WHERE id_ech = 104 AND id_point = 1158411;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1158527;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1158606;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1158962;
UPDATE ecologie SET obstopo = $$6$$ WHERE id_ech = 104 AND id_point = 1160347;
UPDATE ecologie SET tsol = $$58$$ WHERE id_ech = 104 AND id_point = 1160553;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1161752;
UPDATE ecologie SET humus = $$48$$ WHERE id_ech = 104 AND id_point = 1161824;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1161866;
UPDATE ecologie SET humus = $$48$$ WHERE id_ech = 104 AND id_point = 1163713;
UPDATE ecologie SET humus = $$48$$ WHERE id_ech = 104 AND id_point = 1163738;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1163810;
UPDATE ecologie SET humus = $$48$$ WHERE id_ech = 104 AND id_point = 1164067;
UPDATE ecologie SET tsol = $$34$$ WHERE id_ech = 104 AND id_point = 1165511;
UPDATE ecologie SET tsol = $$34$$ WHERE id_ech = 104 AND id_point = 1165640;
UPDATE ecologie SET tsol = $$34$$ WHERE id_ech = 104 AND id_point = 1165703;
UPDATE ecologie SET tsol = $$34$$ WHERE id_ech = 104 AND id_point = 1165775;
UPDATE ecologie SET humus = $$48$$ WHERE id_ech = 104 AND id_point = 1165972;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1167232;
UPDATE ecologie SET humus = $$47$$ WHERE id_ech = 104 AND id_point = 1167909;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1169540;
UPDATE ecologie SET humus = $$28$$ WHERE id_ech = 104 AND id_point = 1170376;
UPDATE ecologie SET humus = $$40$$ WHERE id_ech = 104 AND id_point = 1170378;
UPDATE ecologie SET humus = $$28$$ WHERE id_ech = 104 AND id_point = 1170580;
UPDATE ecologie SET humus = $$28$$ WHERE id_ech = 104 AND id_point = 1170618;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1170671;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1171563;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1171577;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1171803;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1172798;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1173196;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1173233;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 104 AND id_point = 1173272;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1173294;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1173313;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 104 AND id_point = 1173363;
UPDATE ecologie SET humus = $$28$$ WHERE id_ech = 104 AND id_point = 1173363;
UPDATE ecologie SET tsol = $$11$$ WHERE id_ech = 104 AND id_point = 1173544;
UPDATE ecologie_2017 SET oln = $$2$$ WHERE id_ech = 104 AND id_point = 1177385;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 104 AND id_point = 1177532;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 104 AND id_point = 1177554;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 104 AND id_point = 1177581;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 104 AND id_point = 1177589;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 104 AND id_point = 1177597;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1177971;
UPDATE ecologie SET humus = $$28$$ WHERE id_ech = 104 AND id_point = 1178409;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1179904;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1180270;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1182153;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1182267;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1182302;
UPDATE ecologie SET roche = $$330$$ WHERE id_ech = 104 AND id_point = 1182403;
UPDATE ecologie SET tsol = $$09$$ WHERE id_ech = 104 AND id_point = 1182522;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1182842;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1182884;
UPDATE ecologie SET tsol = $$85$$ WHERE id_ech = 104 AND id_point = 1182953;
UPDATE ecologie SET humus = $$47$$ WHERE id_ech = 104 AND id_point = 1183119;
UPDATE ecologie SET humus = $$48$$ WHERE id_ech = 104 AND id_point = 1188397;
UPDATE ecologie_2017 SET typcai = $$212$$ WHERE id_ech = 104 AND id_point = 1188472;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1189623;
UPDATE ecologie SET roche = $$230$$ WHERE id_ech = 104 AND id_point = 1189706;

-- mise à jour des données FLORE
UPDATE flore SET codesp = 'A530' WHERE id_ech = 104 AND id_point = 1162806 AND codesp = '9388';
UPDATE flore SET codesp = '9519' WHERE id_ech = 104 AND id_point = 1162821 AND codesp = '9382';

INSERT INTO flore (id_ech, id_point, codesp, abond, inco_flor)
VALUES (104, 1162010, 'A040', '1', NULL)
, (104, 1162821, '9388', '1', '4')
, (104, 1162821, '9455', '1', '4');

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


