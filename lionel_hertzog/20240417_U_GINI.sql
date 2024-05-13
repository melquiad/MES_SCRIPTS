
-- 1. metaifn
BEGIN;

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_GINI', 'AUTRE', 'CONTINU', 'Coefficient de gini', 'Coefficient mesurant l hétérogénéité de la distribution de surface terrière des arbres');

SELECT * FROM metaifn.ajoutdonnee ('U_GINI', NULL, 'U_GINI', 'AUTRE', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Coefficient de gini', 'Coefficient mesurant l hétérogénéité de la distribution de surface terrière des arbres');

SELECT * FROM metaifn.ajoutchamp ('U_GINI', 'U_G3FORET', 'INV_EXP_NM', FALSE, 0, NULL, 'float8',NULL);
SELECT * FROM metaifn.ajoutchamp ('U_GINI', 'U_P3POINT', 'INV_EXP_NM', FALSE, 0, NULL, 'float8',NULL);

UPDATE metaifn.afchamp
SET validin = 0, validout = 17, calcin = 0, calcout = 17
WHERE famille = 'INV_EXP_NM' and donnee = 'U_GINI';

INSERT INTO utilisateur.autorisation_groupe_donnee (groupe, donnee)
VALUES ('LIF', 'U_GINI');

COMMIT;

-- 2. Ajout et remplissage de la colonne
BEGIN;

ALTER TABLE inv_exp_nm.u_g3foret ADD COLUMN u_gini float8;
ALTER TABLE inv_exp_nm.u_p3point ADD COLUMN u_gini float8;

COMMIT;



BEGIN;

WITH prep_table AS (
	SELECT npp, gtot, row_number() OVER(PARTITION BY ga.npp ORDER BY gtot) * gtot AS num
	FROM inv_exp_nm.g3arbre ga
	),
	cc_table AS (
	SELECT ga.npp, cast(count(*) AS float) AS n
	FROM inv_exp_nm.g3arbre ga 
	GROUP BY ga.npp
	),
	tmp AS (select p.npp, ((2 * sum(p.num)) / (c.n * sum(p.gtot))) - ((c.n + 1) / c.n) as gini
	FROM prep_table p
	INNER JOIN cc_table c ON p.npp = c.npp
	GROUP BY p.npp, c.n
	)
UPDATE inv_exp_nm.u_g3foret gf
SET u_gini = t.gini
FROM tmp t
WHERE gf.npp = t.npp AND incref BETWEEN 0 AND 18;


WITH prep_table AS (
	SELECT npp, gtot, row_number() OVER(PARTITION BY ga.npp ORDER BY gtot) * gtot AS num
	FROM inv_exp_nm.p3arbre ga
	),
	cc_table AS (
	SELECT ga.npp, cast(count(*) AS float) AS n
	FROM inv_exp_nm.p3arbre ga 
	GROUP BY ga.npp
	),
	tmp AS (select p.npp, ((2 * sum(p.num)) / (c.n * sum(p.gtot))) - ((c.n + 1) / c.n) as gini
	FROM prep_table p
	INNER JOIN cc_table c ON p.npp = c.npp
	GROUP BY p.npp, c.n
	)
UPDATE inv_exp_nm.u_p3point pp
SET u_gini = t.gini
FROM tmp t
WHERE pp.npp = t.npp AND incref BETWEEN 0 AND 18;


COMMIT;


----------------------------------------------------------------------------------------------
-- Requête fournie par Lionel Hertzog (avec inv_exp-am à l'origine)
with prep_table as (
	select npp, gtot, row_number() over(partition by ga.npp order by gtot) * gtot as num
	from inv_exp_nm.g3arbre ga
	),
	cc_table as (
	select ga.npp, cast(count(*) as float) as n
	from inv_exp_nm.g3arbre ga 
	group by ga.npp
	)
select p.npp, ((2 * sum(p.num)) / (c.n * sum(p.gtot))) - ((c.n + 1) / c.n) as gini
from prep_table p
inner join cc_table c
on p.npp = c.npp
group by p.npp, c.n;
