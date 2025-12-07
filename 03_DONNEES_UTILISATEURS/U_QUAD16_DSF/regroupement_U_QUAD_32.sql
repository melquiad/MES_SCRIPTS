CREATE TEMPORARY TABLE decoupe AS 
SELECT "mode", "position", libelle, definition
, (substr("mode", 1, 4))::int AS xl2, (substr("mode", 6, 4))::int AS yl2
, dense_rank() over(ORDER BY (substr("mode", 1, 4))::int) AS absc
, dense_rank() over(ORDER BY (substr("mode", 6, 4))::int) AS ord
FROM metaifn.abmode WHERE unite = 'U_QUAD'
ORDER BY absc, ord;

CREATE TEMPORARY TABLE decoupe2 AS 
SELECT "mode", "position", libelle, definition, xl2, yl2, absc, ord, (absc + 1)/2 AS absc2, ord/2 AS ord2
, dense_rank() over(PARTITION BY (absc + 1)/2, ord/2 ORDER BY absc, ord DESC) AS ordre_carre2
FROM decoupe
ORDER BY absc, ord;

CREATE TEMPORARY TABLE regroupe AS 
SELECT "mode", libelle, absc2, ord2
FROM decoupe2
WHERE ordre_carre2 = 1
ORDER BY absc2, ord2;

CREATE TEMPORARY TABLE regroupe2 AS 
SELECT r."mode", r.absc2, r.ord2, r.libelle, string_agg(d2.libelle, ' ; ') AS definition
FROM regroupe r
INNER JOIN decoupe2 d2 ON r.absc2 = d2.absc2 AND r.ord2 = d2.ord2
GROUP BY r."mode", r.libelle, r.absc2, r.ord2
ORDER BY absc2, ord2;

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_QUAD32', 'AUTRE', 'NOMINAL', $$Quadrats 32x32 km$$, $$Regroupement du découpage géographique des quadrats 16x16 km du DSF, en 32x32 km (4 quadrats en 1 regroupé).$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
SELECT 'U_QUAD32', "mode", row_number() over(), row_number() over(), 1, libelle, definition
FROM regroupe2
ORDER BY absc2, ord2;

INSERT INTO metaifn.abgroupe(gunite, gmode, unite, mode)
SELECT 'U_QUAD32' AS gunite, r."mode" AS gmode, 'U_QUAD' AS unite, d."mode"
FROM regroupe2 r
INNER JOIN decoupe2 d ON r.absc2 = d.absc2 AND r.ord2 = d.ord2
ORDER BY d.absc2, d.ord2, d.ordre_carre2;

DROP TABLE regroupe2;
DROP TABLE regroupe;
DROP TABLE decoupe2;
DROP TABLE decoupe;

