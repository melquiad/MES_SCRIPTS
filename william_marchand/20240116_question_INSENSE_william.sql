CREATE TABLE public.insense_manquant (
    campagne INT2, 
    idp varchar(7),
    CONSTRAINT insense_manquant_pkey PRIMARY KEY (idp)
);

\COPY public.insense_manquant FROM '~/Documents/MES_SCRIPTS/william_marchand/insense_manquant.csv' WITH CSV HEADER DELIMITER ',' NULL AS ''

TABLE public.insense_manquant;

-- en base d'exploitation
SELECT im.campagne, e.idp, im.idp, g.insense
FROM inv_exp_nm.e1point e
INNER JOIN public.insense_manquant im USING (idp)
INNER JOIN inv_exp_nm.g3ecologie g USING (npp)
UNION
SELECT im.campagne, e.idp, im.idp, p.insense
FROM inv_exp_nm.e1point e
INNER JOIN public.insense_manquant im USING (idp)
INNER JOIN inv_exp_nm.p3ecologie p USING (npp)
ORDER BY 2; --> ne renvoie rien donc les points de im sont absents de g3ecologie et de p3ecologie

SELECT im.campagne, e.idp, im.idp, e.npp
FROM inv_exp_nm.e1point e
INNER JOIN public.insense_manquant im USING (idp)
ORDER BY 1,2;

-- en base de production
SELECT p.npp, p.idp, im.idp, e.humus, e.pcalc, e.text1, e.text2, e2.htext
,e.prof1, e.prof2
FROM public.insense_manquant im
INNER JOIN point p ON im.idp = p.idp
INNER JOIN ecologie e USING (id_point)
INNER JOIN ecologie_2017 e2 ON p.id_point = e2.id_point
ORDER BY 2;

SELECT p.npp, p.idp, im.idp, p.id_point, e.id_point
FROM public.insense_manquant im
INNER JOIN point p USING (idp)
INNER JOIN ecologie e USING (id_point);

/* --> contrôle : 235 + 655 = 890
SELECT p.npp, p.idp, im.idp, p.id_point, v.id_point
FROM v_liste_points_lt2 v
INNER JOIN point p USING (id_point)
INNER JOIN public.insense_manquant im  ON p.idp = im.idp;

SELECT p.npp, p.idp, im.idp, p.id_point, v.id_point
FROM v_liste_points_lt1_pi2 v
INNER JOIN point p USING (id_point)
INNER JOIN public.insense_manquant im  ON p.idp = im.idp;
*/





