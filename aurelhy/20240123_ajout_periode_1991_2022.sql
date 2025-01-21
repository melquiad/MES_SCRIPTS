-- Table d'import des données mensuelles
CREATE TABLE public.aurel91 (
    xl2 INT4,
    yl2 INT4,
    annee_deb INT2,
    annee_fin INT2,
    mois INT2,
    rmoy NUMERIC,
    nbjrr NUMERIC,
    tnmoy NUMERIC,
    txmoy NUMERIC,
    nbjgel NUMERIC
);

-- import des données Aurelhy (1991 - 2020)
\copy public.aurel91 FROM '/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/exploitation/inv_exp_nm/Aurelhy/ign_1991_2020_mois.csv' WITH CSV DELIMITER ';' QUOTE '"'  NULL AS '' HEADER
\copy public.aurel91 FROM '/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/exploitation/inv_exp_nm/Aurelhy/ign_1991_2020_an.csv' WITH CSV DELIMITER ';' QUOTE '"'  NULL AS '' HEADER

-- Mise à jour des coordonnées Lambert 2 étendu du fichier initial
UPDATE public.aurel91
SET xl2 = xl2 * 100, yl2 = yl2 * 100;

/*
-- Vérification que tous les points sont déjà présents dans la table AURELHY_PT
SELECT count(DISTINCT (xl2, yl2))
FROM public.aurel91 a
WHERE NOT EXISTS (
    SELECT 1
    FROM carto_exo.aurelhy_pt ap
    WHERE a.xl2 = ap.xl2
    AND a.yl2 = ap.yl2
); -- 0 => tous les points existent déjà.
*/

ALTER TABLE carto_exo.aurelhy_an
    ALTER COLUMN ind_mart TYPE NUMERIC(7, 2);


-- Remplissage de la table des données mensuelles
WITH id_max_mois AS (
    SELECT max(id) AS id_max
    FROM carto_exo.aurelhy_mois
)
INSERT INTO carto_exo.aurelhy_mois (id, id_pt, annee_deb, annee_fin, mois, rmoy, nbjrr, tnmoy, txmoy, nbjgel)
SELECT id_max + ROW_NUMBER() OVER () AS id, id_pt, annee_deb, annee_fin, mois, rmoy, nbjrr, tnmoy, txmoy, nbjgel
FROM public.aurel91
INNER JOIN carto_exo.aurelhy_pt p USING (xl2, yl2)
CROSS JOIN id_max_mois
WHERE mois != 13;

-- Remplissage de la table des données annuelles
WITH id_max_an AS (
    SELECT max(id) AS id_max
    FROM carto_exo.aurelhy_an
)
INSERT INTO carto_exo.aurelhy_an (id, id_pt, annee_deb, annee_fin, rmoy, nbjrr, tnmoy, txmoy, nbjgel)
SELECT id_max + ROW_NUMBER() OVER () AS id, id_pt, annee_deb, annee_fin, rmoy, nbjrr, tnmoy, txmoy, nbjgel
FROM public.aurel91
INNER JOIN carto_exo.aurelhy_pt p USING (xl2, yl2)
CROSS JOIN id_max_an
WHERE mois = 13;

-- Calcul des données ajoutées
UPDATE carto_exo.aurelhy_an
SET tmoy = (tnmoy + txmoy) / 2.0
WHERE annee_deb = 1991;

WITH moyennes AS (
    SELECT id_pt, annee_deb, ROUND(AVG(txmoy), 2) AS tmax_ete, ROUND(AVG((tnmoy + txmoy) / 2.0), 2) AS tmoy_ete
    FROM carto_exo.aurelhy_mois
    WHERE mois BETWEEN 6 AND 8
    AND annee_deb = 1991
    GROUP BY id_pt, annee_deb
)
UPDATE carto_exo.aurelhy_an a
SET tmax_ete = m.tmax_ete, tmoy_ete = m.tmoy_ete
FROM moyennes m
WHERE a.id_pt = m.id_pt
AND a.annee_deb = m.annee_deb;

UPDATE carto_exo.aurelhy_an
SET ind_mart = ROUND(rmoy / (tmoy + 10), 2)
WHERE annee_deb = 1991;

WITH cumuls AS (
    SELECT id_pt, annee_deb, min(tnmoy) AS tnmin, max(txmoy) AS txmax
    FROM carto_exo.aurelhy_mois am
    WHERE annee_deb = 1991
    GROUP BY id_pt, annee_deb
)
UPDATE carto_exo.aurelhy_an a
SET ind_emb = 
  CASE 
    WHEN c.txmax = c.tnmin OR (c.tnmin + c.txmax = 0 ) THEN NULL
    ELSE 100 * a.rmoy / (2 * (c.tnmin + c.txmax) / 2 * (c.txmax - c.tnmin)) 
  END
FROM cumuls c 
WHERE a.id_pt = c.id_pt AND a.annee_deb = c.annee_deb;

WITH extremes AS (
    SELECT id_pt,
           annee_deb,
           MIN(tnmoy) tmin,
           MAX(txmoy) tmax,
           MIN(rmoy) pmin,
           MAX(rmoy) pmax
    FROM carto_exo.aurelhy_mois
    WHERE annee_deb = 1991
    GROUP BY id_pt,
             annee_deb
)
UPDATE carto_exo.aurelhy_an a
SET tmin = e.tmin, tmax = e.tmax, pmin = e.pmin, pmax = e.pmax
FROM extremes e
WHERE a.id_pt = e.id_pt AND a.annee_deb = e.annee_deb;

VACUUM ANALYZE carto_exo.aurelhy_an;

DROP TABLE public.aurel91;

-- ajout du croisement des mailles Aurelhy avec les points des campagnes 20, 21 et 22
INSERT INTO inv_exp_nm.point_aurelhy (npp, id_pt)
SELECT c.npp, p.id_pt
FROM inv_exp_nm.e1coord c
JOIN LATERAL (
    SELECT id_pt
    FROM carto_exo.aurelhy_pt a
    ORDER BY c.geom <-> a.geom
    LIMIT 1
) p ON TRUE
WHERE LEFT(c.npp,3) IN ('20-','21-','22-');

-- ou

INSERT INTO inv_exp_nm.point_aurelhy (npp, id_pt)
SELECT c.npp, p.id_pt
FROM inv_exp_nm.e1coord c
INNER JOIN inv_exp_nm.e1point e USING (npp)
JOIN LATERAL (
    SELECT id_pt
    FROM carto_exo.aurelhy_pt a
    ORDER BY c.geom <-> a.geom
    LIMIT 1
) p ON TRUE
WHERE e.incref IN (15,16,17);







