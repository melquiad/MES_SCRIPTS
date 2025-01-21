
CREATE TABLE public.donnees_passage (
	donnee varchar(20), -- ou : donnee TEXT PRIMARY KEY
	typ_donnee varchar(20),
	used_rap_valid varchar(3),
	used_memento varchar(3),
	used_ts varchar(3),
	used_groupe varchar(100),
	CONSTRAINT pkdonnee PRIMARY KEY (donnee)
	) WITHOUT OIDS;

-- sous PSQL
-- \COPY public.donnees_passage FROM '/home/lhaugomat/Documents/MES_SCRIPTS/EXOS/Donnees_Passage.csv' WITH CSV HEADER DELIMITER ';' NULL AS ''

TABLE public.donnees_passage;

------------------------------- Version 2 ----------------------------------------------

SELECT e.donnee, a3.operation, a.famille, min(a.defin) + 2005 AS année_début, max(a.defout) + 2005 AS année_fin,
CASE WHEN a3.codage = '1' THEN 1 ELSE count(DISTINCT(a2.dcunite)) END AS nb_unites	
FROM public.donnees_passage e
INNER JOIN metaifn.addonnee a3 ON e.donnee = a3.donnee
LEFT JOIN metaifn.afchamp a ON e.donnee = a.donnee AND a.famille = 'INV_EXP_NM' --AND a.defin IS NOT NULL
LEFT JOIN metaifn.aiunite a2 ON a3.unite = a2.unite AND a2.inv = 'T' -->  T pour récupérer uniquement les données nouvelles méthodes
--WHERE a.defin IS NOT NULL AND a.famille = 'INV_EXP_NM'
GROUP BY e.donnee, a3.codage, a3.operation, a.famille
ORDER BY e.donnee;--, unite;

----------------------------- Version Cédric ------------------------------------------------------------------------------

SELECT dp.donnee, d.operation AS operation, d.libelle, c.famille, min(c.defin) + 2005 AS an_deb, max(c.defout) + 2005 AS an_fin,
CASE WHEN d.codage = 1::BIT THEN 1 ELSE count(DISTINCT u.dcunite) END AS nb_unites
FROM public.donnees_passage dp
INNER JOIN metaifn.addonnee d ON dp.donnee = d.donnee
LEFT JOIN metaifn.afchamp c ON dp.donnee = c.donnee AND c.famille = 'INV_EXP_NM'
LEFT JOIN metaifn.aiunite u ON d.unite = u.unite AND u.inv = 'T'
GROUP BY dp.donnee, d.operation, d.libelle, c.famille, d.codage
ORDER BY dp.donnee;

DROP TABLE public.donnees_passage;




