--  La carte géologique est maintenant accessible depuis la base de production.
-- En base de production, il s'agit de la table (étrangère) SIG_INVENTAIRE.CARTE_GEOL.

-- Exemple de requête croisant les points terrain de la campagne à venir, première visite (sur première PI), en me limitant à 10 points seulement pour que le croisement ne dure pas des heures :
SELECT v.*, cg.*
FROM v_liste_points_lt1 v
INNER JOIN point p USING (id_point)
INNER JOIN sig_inventaire.carte_geol cg ON st_intersects(p.geom, cg.geometry)
WHERE v.annee = 2024
LIMIT 10;

-- Pour la liste des polygones à moins de 100 m de chaque point d'inventaire, c'est déjà plus compliqué pour ne pas avoir une requête affreusement lente... Donc, en limitant à 10 points de la campagne à venir, voici un exemple qui passe par une table temporaire pour indexer la géométrie liée au buffer de 100 m autour des points (sinon, l'indexation spatiale n'est pas utilisée) :

CREATE TEMPORARY TABLE pts_2024_geom_100 AS 
SELECT v.*, st_buffer(p.geom, 100) AS geom
FROM v_liste_points_lt1 v
INNER JOIN point p USING (id_point)
WHERE v.annee = 2024
LIMIT 10;

CREATE INDEX pts_2024_geom_100_idx ON pts_2024_geom_100 USING gist (geom);
ANALYZE pts_2024_geom_100;

SELECT p.npp, p.nph, p.id_ech, p.id_point, cg.*
FROM pts_2024_geom_100 p
INNER JOIN sig_inventaire.carte_geol cg ON p.geom && cg.geometry AND  st_intersects(st_buffer(p.geom, 100), cg.geometry);

DROP TABLE pts_2024_geom_100;

-- Pour le coup, ce genre de question nécessite d'être optimisé...
