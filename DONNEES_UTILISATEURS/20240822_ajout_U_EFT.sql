
-- création de l'unité U_EFT (European Forest Types)

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_EFT', 'AUTRE', 'NOMINAL', 'European Forest Types', 'Différents types de forêts Européennes');

SELECT * FROM metaifn.abunite WHERE unite = 'U_EFT';

-- insertion des modalités

CREATE TABLE public.eft (
    unite char(12),
    mode  char(12),
    position smallint,
    classe smallint,
	libelle char(60),
	definition char(255));

DROP TABLE public.eft;

\COPY public.eft FROM '/mnt/echange/MES_SCRIPTS/ingrid_bonheme/EFT/abmode_EFT.csv' WITH CSV HEADER DELIMITER ',' NULL AS ''

INSERT INTO metaifn.abmode (unite, "mode", "position", classe, etendue, libelle, definition)
SELECT unite, "mode", "position", classe, 1 AS etendue, libelle, definition FROM public.eft;

-- DELETE FROM metaifn.abmode WHERE unite = 'U_EFT';

SELECT * FROM metaifn.abmode WHERE unite = 'U_EFT';

