-- Je vais vous expliquer comment écrire une requête SQL récursive pour gérer une hiérarchie spatiale, par exemple pour naviguer dans des zones géographiques imbriquées (pays → régions → départements → communes).
-- Structure typique avec CTE récursive
-- Voici un exemple concret avec des zones administratives :

WITH RECURSIVE hierarchie_spatiale AS (
    -- Cas de base : point de départ (ex: une commune spécifique)
    SELECT 
        id,
        nom,
        geom,
        id_parent,
        niveau,
        1 as profondeur,
        CAST(nom AS VARCHAR(1000)) as chemin
    FROM zones_geo
    WHERE id = 123  -- Zone de départ  
    UNION ALL
    -- Cas récursif : remonte ou descend la hiérarchie
    SELECT 
        z.id,
        z.nom,
        z.geom,
        z.id_parent,
        z.niveau,
        h.profondeur + 1,
        h.chemin || ' > ' || z.nom
    FROM zones_geo z
    INNER JOIN hierarchie_spatiale h ON z.id_parent = h.id
    -- Ou pour descendre : ON z.id = h.id_parent
    WHERE h.profondeur < 10  -- Limite de sécurité
)
SELECT * FROM hierarchie_spatiale;
	-- Cas d'usage courants
	-- 1. Trouver tous les descendants d'une zone
WITH RECURSIVE descendants AS (
    SELECT id, nom, geom, id_parent, 0 as niveau
    FROM zones_geo
    WHERE id = 10  -- Zone parent (ex: une région)
    
    UNION ALL
    
    SELECT z.id, z.nom, z.geom, z.id_parent, d.niveau + 1
    FROM zones_geo z
    INNER JOIN descendants d ON z.id_parent = d.id
)
SELECT * FROM descendants;

	-- 2. Trouver tous les ancêtres d'un point
WITH RECURSIVE ancetres AS (
    SELECT id, nom, geom, id_parent
    FROM zones_geo
    WHERE id = 500  -- Zone de départ (ex: une commune)
    UNION ALL
    SELECT z.id, z.nom, z.geom, z.id_parent
    FROM zones_geo z
    INNER JOIN ancetres a ON a.id_parent = z.id
)
SELECT * FROM ancetres
ORDER BY id;
	-- 3. Avec critère spatial (PostGIS)
WITH RECURSIVE zones_contenues AS (
    -- Zones qui intersectent un point donné
    SELECT 
        id, nom, geom, id_parent, niveau,
        ST_Area(geom) as superficie
    FROM zones_geo
    WHERE ST_Contains(geom, ST_SetSRID(ST_Point(2.3522, 48.8566), 4326))
    
    UNION ALL
    
    -- Remonte aux zones englobantes
    SELECT 
        z.id, z.nom, z.geom, z.id_parent, z.niveau,
        ST_Area(z.geom)
    FROM zones_geo z
    INNER JOIN zones_contenues zc ON zc.id_parent = z.id
)
SELECT * FROM zones_contenues
ORDER BY superficie;

-- Conseils pratiques

-- Toujours inclure une limite (profondeur < N) pour éviter les boucles infinies
-- Indexer les colonnes id et id_parent pour les performances
-- Utiliser des index spatiaux (GIST pour PostGIS) sur les géométries
-- Vérifier l'intégrité : pas de cycles dans la hiérarchie
-- PostgreSQL gère très bien les CTE récursives avec PostGIS

----------------------------------------------------------------------------------------------------
-- Avez-vous un cas d'usage spécifique en tête ? Je peux adapter l'exemple à votre structure de données ¿
-- Mon cas consiste en un snowball sampling avec un critère de distance inférieur à 50km
-- Excellent cas d'usage ! Le snowball sampling spatial consiste à partir d'un ou plusieurs points initiaux et à récupérer itérativement tous les points voisins dans un rayon donné. Voici comment l'implémenter avec une requête SQL récursive :
-- Solution avec PostGIS

WITH RECURSIVE snowball AS (
    -- Cas de base : points de départ (seed)
    SELECT 
        id,
        nom,
        geom,
        0 as iteration,
        ARRAY[id] as chemin_ids  -- Pour éviter les cycles
    FROM points_geo
    WHERE id IN (1, 2, 3)  -- Vos points initiaux   
    UNION    
    -- Cas récursif : voisins à moins de 50km
    SELECT 
        p.id,
        p.nom,
        p.geom,
        s.iteration + 1,
        s.chemin_ids || p.id
    FROM points_geo p
    INNER JOIN snowball s ON ST_DWithin(
        s.geom::geography, 
        p.geom::geography, 
        50000  -- 50km en mètres
    )
    WHERE 
        p.id != ALL(s.chemin_ids)  -- Évite les doublons/cycles
        AND s.iteration < 10  -- Limite de profondeur
)
SELECT DISTINCT ON (id)
    id, 
    nom, 
    geom,
    iteration,
    ST_Distance(geom::geography, (SELECT geom FROM points_geo WHERE id = 1)::geography) / 1000 as distance_origine_km
FROM snowball
ORDER BY id, iteration;

-- Version optimisée avec distance cumulée
-- Si vous voulez limiter par distance totale depuis l'origine (et non par itération) :
WITH RECURSIVE snowball AS (
    -- Initialisation
    SELECT 
        id,
        nom,
        geom,
        0 as iteration,
        0.0 as distance_cumulee,
        ARRAY[id] as visite
    FROM points_geo
    WHERE id = 1  -- Point de départ unique
    
    UNION
    
    -- Expansion
    SELECT 
        p.id,
        p.nom,
        p.geom,
        s.iteration + 1,
        s.distance_cumulee + ST_Distance(s.geom::geography, p.geom::geography) / 1000.0,
        s.visite || p.id
    FROM points_geo p
    INNER JOIN snowball s ON 
        ST_DWithin(s.geom::geography, p.geom::geography, 50000)
    WHERE 
        p.id != ALL(s.visite)
        AND s.iteration < 20
        AND s.distance_cumulee < 200  -- Distance max totale depuis l'origine
)
SELECT DISTINCT ON (id)
    id,
    nom,
    ST_AsText(geom) as coordonnees,
    iteration as vague,
    ROUND(distance_cumulee::numeric, 2) as distance_km
FROM snowball
ORDER BY id, iteration;
Version avec table de résultats enrichie
Pour analyser votre échantillonnage :
sqlWITH RECURSIVE snowball AS (
    SELECT 
        id,
        geom,
        0 as vague,
        NULL::integer as provenance_id,
        ARRAY[id] as chemin
    FROM points_geo
    WHERE id = 100  -- Seed   
    UNION  
    SELECT 
        p.id,
        p.geom,
        s.vague + 1,
        s.id as provenance_id,
        s.chemin || p.id
    FROM points_geo p
    INNER JOIN snowball s ON 
        ST_DWithin(s.geom::geography, p.geom::geography, 50000)
    WHERE 
        p.id != ALL(s.chemin)
        AND s.vague < 15
)
SELECT 
    s.id,
    s.vague,
    s.provenance_id,
    p.nom as nom_point,
    p_prov.nom as vient_de,
    COUNT(*) OVER (PARTITION BY s.vague) as points_par_vague,
    ST_Distance(s.geom::geography, origine.geom::geography) / 1000 as dist_origine_km
FROM snowball s
LEFT JOIN points_geo p ON s.id = p.id
LEFT JOIN points_geo p_prov ON s.provenance_id = p_prov.id
CROSS JOIN (SELECT geom FROM points_geo WHERE id = 100) origine
ORDER BY s.vague, s.id;
Optimisations importantes
Index spatiaux obligatoires :
sqlCREATE INDEX idx_points_geom_gist ON points_geo USING GIST(geom);
-- Ou pour geography :
CREATE INDEX idx_points_geog_gist ON points_geo USING GIST((geom::geography));
Pré-filtrage avec bbox (beaucoup plus rapide) :
sql-- Dans la jointure, ajouter :
AND ST_DWithin(
    ST_Transform(s.geom, 3857),  -- Projection métrique
    ST_Transform(p.geom, 3857),
    50000
	)
	
-- Variante : multiples seeds simultanés
WITH RECURSIVE snowball AS (
    SELECT 
        id, geom, 0 as vague, id as seed_id,
        ARRAY[id] as visite
    FROM points_geo
    WHERE categorie = 'seed'  -- Tous vos points de départ    
    UNION  
    SELECT 
        p.id, p.geom, s.vague + 1, s.seed_id,
        s.visite || p.id
    FROM points_geo p, snowball s
    WHERE 
        ST_DWithin(s.geom::geography, p.geom::geography, 50000)
        AND p.id != ALL(s.visite)
        AND s.vague < 10
)
SELECT DISTINCT ON (id) *
FROM snowball
ORDER BY id, vague;

/*
Points clés :

::geography donne des distances en mètres (précises)
ST_DWithin utilise les index spatiaux efficacement
Le tableau visite évite les cycles
DISTINCT ON (id) garde la première occurrence (vague minimale)

Quel est votre volume de données ? Je peux affiner la solution selon vos contraintes de performance.Claude est une IA et peut faire des erreurs. Veuillez vérifier les réponses.
*/



