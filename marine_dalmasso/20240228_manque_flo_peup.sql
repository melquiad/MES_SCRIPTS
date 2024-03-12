CREATE TABLE public.manque_flore_peup (
	idp bpchar(7),
	cd_ref varchar(12),
	campagne int2,
	lib_ref varchar(60));

DROP TABLE public.manque_flore_peup;

\COPY public.manque_flore_peup FROM '/home/lhaugomat/Documents/MES_SCRIPTS/marine_dalmasso/manque_flo_peup_exp.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

SET enable_nestloop TO FALSE;

SELECT DISTINCT m.idp, p.id_point, f.id_point, p.npp, m.cd_ref,  m.lib_ref, g.gmode, a.libelle, f.codesp 
FROM public.manque_flore_peup m
INNER JOIN inv_prod_new.point p ON m.idp = p.idp
INNER JOIN inv_prod_new.flore f ON p.id_point = f.id_point
INNER JOIN metaifn.abgroupe g ON g.gunite = 'CDREF13' AND g.unite = 'CODESP' AND g.gmode = m.cd_ref AND g."mode" = f.codesp 
INNER JOIN metaifn.abmode a ON g.gmode = a."mode"
ORDER BY 2, 6;


/*
SELECT DISTINCT m.idp, p.idp, p.id_point, p.npp, f.codesp
FROM inv_prod_new.flore f
INNER JOIN inv_prod_new.point p USING (id_point)
INNER JOIN public.manque_flore_peup m ON p.idp = m.idp
order by 3;
*/

