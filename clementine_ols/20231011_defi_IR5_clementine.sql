-- On crée une variable utilisateur d'entrée u_IR5_Ols dans la table u_g3arbre (variable qu'il faudra utiliser pour faire tourner le calcul de production)
ALTER TABLE u_g3arbre
ADD COLUMN u_ir5_ols float;

-- On crée une variable utilisateur de sortie u_C13_5_Ols (variable qui servira au calcul de u_PV2_Ols)
ALTER TABLE u_g3arbre
ADD COLUMN u_c13_5_ols float;

-- On crée une variable utilisateur de sortie u_PV2_Ols (variable qui stockera la production calculée à partir de u_IR5_Ols)
ALTER TABLE u_g3arbre
ADD COLUMN u_pv2_ols float;

/*
-- réinitialisation de u_ir5_ols, u_pv2_ols et de u_c13_5_ols
UPDATE u_g3arbre u
SET u_c13_5_ols = NULL, u_ir5_ols = NULL, u_pv2_ols = NULL;
*/

-- Importation du fichier de Clémentine
CREATE TABLE public.corr_ir5_ess (
    essence TEXT,
    ess bpchar(2),
    delta_moy_prct float(4));

\COPY public.corr_ir5_ess FROM '/home/lhaugomat/Documents/MES_SCRIPTS/clementine_ols/CorrectionIR5_ESS_retrac_new.csv' WITH CSV DELIMITER ';' NULL AS '' HEADER

-- On met le coeff du noyer à 0
UPDATE public.corr_ir5_ess 
SET delta_moy_prct = 0
WHERE ess = '27';

-- Calcul de u_ir5_ols
UPDATE u_g3arbre u
SET u_ir5_ols = g.ir5 * (1 + (c.delta_moy_prct / 100))
FROM  public.corr_ir5_ess c
INNER JOIN g3arbre g ON c.ess = g.ess
WHERE g.incref = 8 AND u.npp = g.npp AND u.a = g.a;

/*
SELECT u.npp, u.a, u.u_ir5_ols, c.ess, c.essence
FROM u_g3arbre u
INNER JOIN g3arbre g USING (npp,a)
INNER JOIN public.corr_ir5_ess c ON c.ess = g.ess
WHERE u.u_ir5_ols < 0 AND g.incref = 8;
*/

-- calcul du u_c13_5_ols
UPDATE inv_exp_nm.u_g3arbre u
SET u_c13_5_ols = GREATEST(c13 - (2 * PI() * u_ir5_ols) / (1 - 2 * PI() * c.coeftarif), 0)
FROM prod_exp.c4ctarif c
INNER JOIN g3arbre g ON c.ess = g.ess
INNER JOIN prod_exp.c4tarifs t ON c.ntarif = t.ntarif AND t.typtarif = 'E1'
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif AND a.incref = 8 AND format = 'DTOTAL' AND domaine = 0
WHERE c.nctarif = 1 AND u.npp = g.npp AND u.a = g.a AND g.incref = 8;

/* 
Déjà calculé dans u_g3arbre
-- calcul des volumes par tarif à 1 entrée en log de C13 
UPDATE inv_exp_nm.u_g3arbre u
SET u_v13 = t.vest, u_v13_5 = t.vest_5
FROM (
	SELECT * FROM PROD_EXP.calcVolArbreLnC13(8)
) t
WHERE u.npp = t.npp AND u.a = t.a;
*/

-- calcul de la nouvelle production u_pv2_ols
UPDATE inv_exp_nm.u_g3arbre u
SET u_pv2_ols = 0.2 *
CASE	WHEN u.u_c13_5_ols < 0.235 THEN a.v
		ELSE a.v * (1 - u.u_v13_5 / u.u_v13)
END
, u_abv2 = 0.2 * a.v * (1 - u.u_v13_5 / u.u_v13)
FROM inv_exp_nm.g3arbre a
WHERE u.npp = a.npp AND u.a = a.a
AND a.incref = 8;






