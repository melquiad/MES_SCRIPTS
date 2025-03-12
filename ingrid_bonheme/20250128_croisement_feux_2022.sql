
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/Feux_2022/samos.shp public.feux_samos | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/Feux_2022/teste.shp public.feux_teste | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/Feux_2022/mano.shp public.feux_mano | psql -p 5433 -d inventaire
shp2pgsql -s 2154 -D -i -I -W utf-8 /home/lhaugomat/Documents/ECHANGES/SIG/Feux_2022/landiras.shp public.feux_landiras | psql -p 5433 -d inventaire

-- croisement
SELECT gf.incref+2005 AS campagne, ep.npp, ep.geom
FROM inv_exp_nm.e1coord c
INNER JOIN inv_exp_nm.e1point ep USING (npp)
INNER JOIN inv_exp_nm.g3foret gf USING (npp)
INNER JOIN public.feux_landiras fl ON st_within(c.geom,fl.geom)
UNION
SELECT gf.incref+2005 AS campagne, ep.npp, ep.geom
FROM inv_exp_nm.e1coord c
INNER JOIN inv_exp_nm.e1point ep USING (npp)
INNER JOIN inv_exp_nm.g3foret gf USING (npp)
INNER JOIN public.feux_teste ft ON st_within(c.geom,ft.geom)
UNION
SELECT gf.incref+2005 AS campagne, ep.npp, ep.geom
FROM inv_exp_nm.e1coord c
INNER JOIN inv_exp_nm.e1point ep USING (npp)
INNER JOIN inv_exp_nm.g3foret gf USING (npp)
INNER JOIN public.feux_mano fm ON st_within(c.geom,fm.geom)
UNION
SELECT gf.incref+2005 AS campagne, ep.npp, ep.geom
FROM inv_exp_nm.e1coord c
INNER JOIN inv_exp_nm.e1point ep USING (npp)
INNER JOIN inv_exp_nm.g3foret gf USING (npp)
INNER JOIN public.feux_samos fsa ON st_within(c.geom,fsa.geom)
ORDER BY campagne;


