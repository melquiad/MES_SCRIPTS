
--Voici un exemple de requête :
LOAD postgres;

ATTACH 'host=inv-prod.ign.fr port=5432 user=CDuprez dbname=production' AS pgp (TYPE postgres);

CALL postgres_execute('pgp', 'SET enable_nestloop = FALSE;');

CREATE TABLE coord_prod AS 
SELECT *
FROM postgres_query('pgp', 'SELECT DISTINCT p.idp 
, ROUND(st_x(st_transform(m.geom, 921048))::NUMERIC, 5) AS xgps_maille, ROUND(st_y(st_transform(m.geom, 921048))::NUMERIC, 5) AS ygps_maille
, ROUND(st_x(st_transform(p.geom, 921048))::NUMERIC, 5) AS xgps_point,  ROUND(st_y(st_transform(p.geom, 921048))::NUMERIC, 5) AS ygps_point
, ROUND(st_x(st_transform(n.geom, 921048))::NUMERIC, 5) AS xgps_noeud,  ROUND(st_y(st_transform(n.geom, 921048))::NUMERIC, 5) AS ygps_noeud
, ROUND(st_x(st_transform(st_setsrid(st_makepoint(p1.xl, p1.yl), 27572), 4326))::NUMERIC, 5) AS xgps_point_exp, ROUND(st_y(st_transform(st_setsrid(st_makepoint(p1.xl, p1.yl), 27572), 4326))::NUMERIC, 5) AS ygps_point_exp
FROM inv_prod_new.point p
INNER JOIN public.pts_xdm x USING (idp)
INNER JOIN inv_prod_new.maille m USING (id_maille)
INNER JOIN inv_prod_new.description d USING (id_point)
INNER JOIN inv_prod_new.point_ech pe USING (id_ech, id_point)
INNER JOIN inv_prod_new.noeud_ech ne ON pe.id_ech_nd = ne.id_ech AND pe.id_noeud = ne.id_noeud
INNER JOIN inv_prod_new.noeud n ON ne.id_noeud = n.id_noeud
LEFT JOIN inv_exp_nm.e1point p1 ON p.npp = p1.npp
ORDER BY idp;');

--Ça crée une table dans DuckDB à partir des données récupérées par une requête qui fait plusieurs jointures entre différentes tables, parfois volumineuses, sous PostgreSQL.
--Les jointures sont gérées sous PostgreSQL, pas par DuckDB qui, dans ce cas précis, n'est pas bon (ce n'est pas son rôle de suppléer PostgreSQL pour faire ces jointures).

--Cédric

