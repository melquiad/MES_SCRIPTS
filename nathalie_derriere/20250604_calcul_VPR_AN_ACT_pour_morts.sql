
-- ajout des colonnes en base
ALTER TABLE inv_exp_nm.g3morts ADD COLUMN vpr_an_act float(8);
ALTER TABLE inv_exp_nm.p3morts ADD COLUMN vpr_an_act float(8);
--> en base de production
ALTER FOREIGN TABLE inv_exp_nm.g3morts ADD COLUMN vpr_an_act float(8);
ALTER FOREIGN TABLE inv_exp_nm.p3morts ADD COLUMN vpr_an_act float(8);

-- Documentation metaifn

-- partie donnee --> inutile la donnée existe déjà pour les vivants
---SELECT * FROM metaifn.ajoutdonnee('VPR_AN_ACT', NULL, 'm3/an', 'IFN', NULL, 0, 'float', 'CC', TRUE, TRUE, 'Volume total aérien prélevé annualisé et actualisé', 'Volume total aérien prélevé annualisé et actualisé');

-- partie champ
SELECT * FROM metaifn.ajoutchamp('VPR_AN_ACT', 'G3MORTS', 'INV_EXP_NM', FALSE, 0, 13, 'float8', 1);
SELECT * FROM metaifn.ajoutchamp('VPR_AN_ACT', 'P3MORTS', 'INV_EXP_NM', FALSE, 0, 13, 'float8', 1);




--CALCUL
-- volume prélevé en forêt
UPDATE inv_exp_nm.g3morts g3a
SET vpr_an_act = 
CASE 
	WHEN u3.u_vpr_an > 0 THEN g3a.v / 5
	ELSE 0 
END
FROM inv_exp_nm.u_g3morts u3
INNER JOIN inv_exp_nm.e2point e2p ON u3.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE g3a.npp = u3.npp AND g3a.a = u3.a
AND g3a.incref >= 6;

/*
SELECT count(*) FROM inv_exp_nm.g3morts WHERE incref = 14 AND vpr_an_act IS NULL; 

SELECT p.incref, sum(p.poids * a.w * a.vpr_an_act) as vpr_an_act, sum(p.poids * a.w * ua.u_vpr_an) as u_vpr_an
FROM inv_exp_nm.g3morts a
INNER JOIN inv_exp_nm.u_g3morts ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY 1
ORDER BY 1 DESC;
*/

-- volume prélevé en peupleraie
UPDATE inv_exp_nm.p3morts p3a
SET vpr_an_act = 
CASE 
	WHEN u3.u_vpr_an > 0 THEN p3a.v / 5
	ELSE 0 
END
FROM inv_exp_nm.u_p3morts u3
INNER JOIN inv_exp_nm.e2point e2p ON u3.npp = e2p.npp
INNER JOIN inv_exp_nm.u_e2point u2 ON e2p.npp = u2.npp
WHERE p3a.npp = u3.npp AND p3a.a = u3.a
AND p3a.incref >= 6;

/*
SELECT count(*) FROM inv_exp_nm.p3morts WHERE incref = 14 AND vpr_an_act IS NULL; 

SELECT p.incref, sum(p.poids * a.w * a.vpr_an_act) as vpr_an_act, sum(p.poids * a.w * ua.u_vpr_an) as u_vpr_an
FROM inv_exp_nm.p3morts a
INNER JOIN inv_exp_nm.u_p3morts ua USING (npp, a)
INNER JOIN inv_exp_nm.e2point p USING (npp)
GROUP BY 1
ORDER BY 1 DESC;
*/


-- Mise à jour des métadonnées

UPDATE metaifn.afchamp
SET defin = 0, defout = NULL, calcin = 0, calcout = 14, validin = 0, validout = 13
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'TG3ARBRE'
AND donnee ~~* 'VPR_AN_ACT';

UPDATE metaifn.afchamp
SET defin = 0, defout = NULL, calcin = 0, calcout = 14, validin = 0, validout = 13
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'TP3ARBRE'
AND donnee ~~* 'VPR_AN_ACT';

UPDATE metaifn.afchamp
SET defin = 6, defout = NULL, calcin = 6, calcout = 14, validin = 6, validout = 13
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'TG3MORTS'
AND donnee ~~* 'VPR_AN_ACT';

UPDATE metaifn.afchamp
SET defin = 6, defout = NULL, calcin = 6, calcout = 14, validin = 6, validout = 13
WHERE famille ~~* 'inv_exp_nm'
AND format ~~* 'TP3MORTS'
AND donnee ~~* 'VPR_AN_ACT';

