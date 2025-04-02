
-- suppression de l'ancienne donnée U_ mais pas de son unité qui sera utilisée par la donnée IFN
DELETE FROM metaifn.afchamp WHERE donnee = 'U_V0PR_AN';
DELETE FROM metaifn.addonnee WHERE donnee = 'U_V0PR_AN';

-- On crée les champs dans g3arbre et p3arbre
ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN v0pr_an float(8);
ALTER TABLE inv_exp_nm.p3arbre ADD COLUMN v0pr_an float(8);
	--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3arbre ADD COLUMN v0pr_an float(8);
ALTER FOREIGN TABLE inv_exp_nm.p3arbre ADD COLUMN v0pr_an float(8);

-- Documentation metaifn

-- partie donnee
SELECT * FROM metaifn.ajoutdonnee('V0PR_AN', NULL, 'm3/an', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Volume total aérien prélevé annualisé', 'Volume total aérien prélevé annualisé');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('V0PR_AN', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('V0PR_AN', 'P3ARBRE', 'INV_EXP_NM', FALSE, 0, 18, 'float8', 1);

-- Calcul de la donnée à partir de U_V0PR_AN

UPDATE inv_exp_nm.g3arbre g
SET v0pr_an = ug.u_v0pr_an
FROM inv_exp_nm.u_g3arbre ug
WHERE g.npp = ug.npp
AND g.a = ug.a;

UPDATE inv_exp_nm.p3arbre p
SET v0pr_an = up.u_v0pr_an
FROM inv_exp_nm.u_p3arbre up
WHERE p.npp = up.npp
AND p.a = up.a;

/*-- contrôle
SELECT incref, count(v0pr_an), avg(v0pr_an)
FROM inv_exp_nm.g3arbre
GROUP BY incref
ORDER BY incref DESC;

SELECT incref, count(v0pr_an), avg(v0pr_an)
FROM inv_exp_nm.p3arbre
GROUP BY incref
ORDER BY incref DESC;
*/

-- On supprime les champs dans u_g3arbre et u_p3arbre
ALTER TABLE inv_exp_nm.u_g3arbre DROP COLUMN u_v0pr_an;
ALTER TABLE inv_exp_nm.u_p3arbre DROP COLUMN u_v0pr_an;

