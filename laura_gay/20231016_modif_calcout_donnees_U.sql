-- Import du fichier de Laura
CREATE TABLE public.donnees_U_MAJ_camp2022 (
    code TEXT,
    last_camp_calc smallint,
    last_year_calc smallint);

\COPY public.donnees_U_MAJ_camp2022 FROM '/home/lhaugomat/Documents/MES_SCRIPTS/laura_gay/donnees_U_MAJ_camp2022.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

UPDATE metaifn.afchamp a
SET calcout = d.last_year_calc - 2005
FROM public.donnees_u_maj_camp2022 d
WHERE d.code = a.donnee AND a.famille = 'INV_EXP_NM';

UPDATE metaifn.afchamp a
SET validout = d.last_year_calc - 2005
FROM public.donnees_u_maj_camp2022 d
WHERE d.code = a.donnee AND a.famille = 'INV_EXP_NM';

DROP TABLE public.donnees_U_MAJ_camp2022;