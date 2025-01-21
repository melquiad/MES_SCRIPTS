/*SET ROLE = 'lhaugomat';

CREATE EXTENSION file_fdw;

CREATE SERVER IF NOT EXISTS lucas_data
FOREIGN DATA WRAPPER file_fdw;

CREATE FOREIGN TABLE lucas_d11 (
  lucas integer,
  npp CHAR(16),
  ser_86 CHAR(3),
  esspre CHAR(3),
  sver CHAR(2),
  vh FLOAT,
  hm FLOAT
) SERVER lucas_data
OPTIONS ( filename '/home/lhaugomat/Documents/MES_SCRIPTS/nikola_besik/Lucas_data_d11.csv', format 'csv' );

TABLE lucas_d11;
*/
----------------- autres options ------------------------------------------------------------------------
--- interrogation en base de production
CREATE UNLOGGED TABLE public.lucas_d11 (
  id smallint,
  npp char(16),
  ser_86 char(3),
  esspre char(3),
  sver char(2),
  vh float,
  hm float,
  CONSTRAINT lucasd11__pkey PRIMARY KEY (npp)
)
WITHOUT OIDS;

TABLE public.lucas_d11;
DROP TABLE public.lucas_d11;

\COPY public.lucas_d11 FROM '/home/lhaugomat/Documents/MES_SCRIPTS/nikola_besik/Lucas_data_d11.csv' WITH CSV HEADER DELIMITER ',' NULL AS ''

SELECT DISTINCT lf.npp, lf.ser_86, lf.esspre, lf.sver, lf.vh, lf.hm, c.millesime as annee, round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM public.lucas_d11 lf
INNER JOIN point p USING (npp)
INNER JOIN point_ech pe USING (id_point)--ON p.id_point = pe.id_point 
INNER JOIN echantillon e USING (id_ech)--ON pe.id_ech = e.id_ech 
INNER JOIN campagne c USING (id_campagne)--ON e.id_campagne = c.id_campagne 
WHERE c.millesime  IN (2020,2021,2022)
ORDER BY npp, annee;
-- ou --
SELECT DISTINCT lf.npp, lf.ser_86, lf.esspre, lf.sver, lf.vh, lf.hm, vlpl.annee , round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM public.lucas_d11 lf
INNER JOIN point p USING (npp)
INNER JOIN point_ech pe USING (id_point)--ON p.id_point = pe.id_point
INNER JOIN v_liste_points_lt1 vlpl USING (id_point, id_ech)
WHERE vlpl.annee IN (2020,2021,2022)
ORDER BY npp, annee;
-- ou --
SELECT DISTINCT lf.npp, lf.ser_86, lf.esspre, lf.sver, lf.vh, lf.hm, vlpl.annee , round(st_x(p.geom)::NUMERIC) AS xl93,  round(st_y(p.geom)::NUMERIC) AS yl93
FROM v_liste_points_lt1 vlpl
INNER JOIN point_ech pe USING (id_point, id_ech)
INNER JOIN point p USING (npp)
INNER JOIN public.lucas_d11 lf USING (npp)
WHERE vlpl.annee IN (2020,2021,2022)
ORDER BY npp, annee;





-- interrogation en base d'esploitation

SELECT lf.npp, lf.ser_86, lf.esspre, lf.sver, lf.vh, lf.hm, ep2.incref + 2005 AS annee, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM public.lucas_d11 lf
INNER JOIN inv_exp_nm.e2point ep2 USING( npp)
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
WHERE incref IN ('15','16','17');





