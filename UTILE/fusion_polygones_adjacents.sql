DROP TABLE IF EXISTS su_35.massifor_35;
---------------------------------------------------------------
CREATE TABLE su_35.massifor_35 as
(
SELECT
row_number() OVER() AS id,
string_agg(g.tfv::text, ', ') AS tfvs,
g.id_foret,
g.tfv,
m.geom::geometry(polygon, 932006) AS geom
FROM 
	(SELECT (ST_Dump(ST_Union(f.geom,10))).geom AS geom
        FROM su_35.for_35 f
        WHERE ST_IsValid(f.geom)) m

JOIN su_35.for_35 g
    ON ST_Intersects(g.geom, m.geom)
GROUP BY g.id_foret, g.tfv, m.geom
);
-----------------------------------------------------------------
ALTER TABLE su_35.massifor_35 ADD PRIMARY KEY (id);
CREATE INDEX ON su_35.massifor_35 USING GIST (geom);




-----------------------------------------------------------------
-----------------------------------------------------------------
--Ajout d'une colonne pour discriminer forêt/non-forêt-----------

ALTER TABLE su_35.for_35 DROP COLUMN foret;
ALTER TABLE su_35.for_35 ADD COLUMN foret INT;
ALTER TABLE su_35.for_35 ADD COLUMN foret VARCHAR;
ALTER TABLE su_35.for_35 ALTER COLUMN foret TYPE INT USING foret::integer;

--Sélection des codes tfv "forêt" pour les passer à 1------------SELECT f.tfv, f.foret FROM su_35.for_35 f WHERE LEFT(tfv,1)='F';

UPDATE su_35.for_35 SET foret = CASE WHEN LEFT(tfv,1) ='F' THEN 1 ELSE 0 END; ------- si 'foret' de type integer
UPDATE su_35.for_35 SET foret = CASE WHEN LEFT(tfv,1) ='F' THEN '1' ELSE '0' END; --- si 'foret' de type string

--Création de massif par département-----------------------------

CREATE TABLE su_35.massifor_35 AS
	(
	SELECT f.foret, (ST_Dump(ST_Union(f.geom))).geom  AS geom
	FROM su_35.for_35 f
	WHERE f.foret = 1
	GROUP BY f.foret 
	);

ALTER TABLE su_35.massifor_35 ADD COLUMN id serial PRIMARY KEY;
CREATE INDEX ON su_35.massifor_35 USING GIST (geom);
-------------------------- sans DUMP ---------------------------------

CREATE TABLE su_35.massifor_35 AS
	(
	SELECT f.foret, ST_Union(f.geom) AS geom
	FROM su_35.for_35 f
	WHERE f.foret = 1
	GROUP BY f.foret 
	);

ALTER TABLE su_35.massifor_35 ADD COLUMN id serial PRIMARY KEY;
CREATE INDEX ON su_35.massifor_35 USING GIST (geom);
-------------------------------------------------------------------
-------------------------------------------------------------------




CREATE TABLE su_35.for_35_dump AS
	(
	SELECT (ST_Dump(f.geom)).geom  AS geom
	FROM su_35.for_35 f
	);

ALTER TABLE su_35.for_35_dump ADD COLUMN id serial PRIMARY KEY;
	
