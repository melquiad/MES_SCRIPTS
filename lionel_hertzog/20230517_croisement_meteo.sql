-- IMPORT de la couche dans le schéma public de la base d'exploitation
/*
shp2pgsql -s 931007 -D -i -I -W utf-8 "/home/lhaugomat/Documents/MES_SCRIPTS/lionel_hertzog/safran_grid.gpkg" public.safran_grid | psql -h test-inv-exp.ign.fr -U LHaugomat -d exploitation
*/

-- Requête de croisement
SELECT sg.id, sg.id_ras, ep2.npp, ep2.incref--, ROUND(ST_X(ec.geom)::NUMERIC) AS xl93, ROUND(ST_Y(ec.geom)::NUMERIC) AS yl93
FROM  inv_exp_nm.e2point ep2
INNER JOIN inv_exp_nm.e1coord ec ON ep2.npp = ec.npp
INNER JOIN public.safran_grid sg ON st_within(ec.geom, sg.geom)
UNION
SELECT sg.id, sg.id_ras, ep2.npp, NULL AS incref--, ROUND(ST_X(st_transform(st_setsrid(st_point(ep.xl,ep.yl),932006),931007))::NUMERIC) AS xl93,
--ROUND(ST_Y(st_transform(st_setsrid(st_point(ep.xl,ep.yl),932006),931007))::NUMERIC) AS yl93
FROM  inv_exp_am.e2point ep2
INNER JOIN inv_exp_am.e1point ep ON ep2.npp = ep.npp
INNER JOIN public.safran_grid sg ON st_within(st_transform(st_setsrid(st_point(ep.xl,ep.yl),932006),931007), sg.geom);



SELECT st_transform(st_setsrid(st_point(ep.xl,ep.yl),932006),931007) AS geom
FROM inv_exp_nm.e1point ep;



