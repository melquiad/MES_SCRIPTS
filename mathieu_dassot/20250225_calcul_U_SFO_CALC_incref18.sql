
-- MAJ incref 18

-- 1. Requête des arbres
CREATE TEMPORARY TABLE arbres_tot AS
SELECT ar.npp, ar.incref, ar.a, ar.ess, ar.espar, ar.wac,
ar.d13, ar.gtot, ar.ori, ar.lib, ar.htot,
CASE WHEN ar.npp IN ('16-15-212-1-201T') AND ar.a IN ('3') THEN 'PB' -- pour corriger les arbres qui n'auraient pas dus être simplifiés
	 WHEN ar.npp IN ('16-21-215-1-110T') AND ar.a IN ('1') THEN 'BM'
	 WHEN ar.npp IN ('16-33-142-1-241T') AND ar.a IN ('1') THEN 'PB'
	 WHEN ar.npp IN ('17-06-324-1-210T') AND ar.a IN ('4') THEN 'PB'
	 WHEN ar.npp IN ('18-23-189-1-170T') AND ar.a IN ('6') THEN 'PB'	 
	 WHEN ar.c13 < 0.3949 AND ar.incref NOT IN ('9','10') THEN 'TPB'
     WHEN ar.c13 < 0.3949 AND ar.incref IN ('9','10') THEN 'PB'
     WHEN ar.c13 > 0.3949 AND ar.c13 < 0.7049 THEN 'PB' 
     WHEN ar.c13 > 0.7049 AND ar.c13 < 1.1749 THEN 'BM'
     WHEN ar.c13 > 1.1749 AND ar.c13 < 1.6449 THEN 'GB'
     WHEN ar.c13 > 1.6449 THEN 'TGB' ELSE NULL END AS dimess
FROM inv_exp_nm.g3arbre ar
WHERE ar.npp NOT LIKE '18PCB%' -- virer inventaire à façon
AND ar.incref = 18
ORDER BY ar.incref, ar.npp ;

-- 2. Imputation des hauteurs aux arbres simplifiés
CREATE TEMPORARY TABLE arbres_input AS
SELECT ar.npp, ar.incref, ar.a, ar.ess, ar.espar, ar.wac, ar.d13, ar.gtot, ar.ori, ar.lib, ar.dimess, ar.htot,
CASE WHEN ar.htot IS NULL AND ar.dimess IN ('TPB', 'PB', 'BM') AND hm IS NOT NULL THEN hm*(d13/dm)
WHEN ar.htot IS NULL AND ar.dimess IN ('GB', 'TGB') AND hm IS NOT NULL THEN hm
ELSE ar.htot END AS htot_p
FROM arbres_tot ar
LEFT JOIN (SELECT arbres_tot.npp, arbres_tot.espar, arbres_tot.dimess, 
				  	avg(arbres_tot.htot) AS hm, avg(arbres_tot.d13) AS dm
	  		FROM arbres_tot 
	 		WHERE arbres_tot.htot IS NOT NULL AND arbres_tot.incref IN (18)
	  		GROUP BY arbres_tot.npp, arbres_tot.dimess, arbres_tot.espar) AS ar_mes 
ON ar_mes.npp = ar.npp AND ar_mes.espar = ar.espar AND ar_mes.dimess = ar.dimess ;

-- 3. Calcul de la haueur de référence
CREATE TEMPORARY TABLE points_href AS
SELECT ht.npp, avg(ht.htot_p) AS href, avg(ht.hmax) AS hmax, count(ht.pos) AS nba_href
FROM(SELECT ar.npp, ar.htot_p, max(htot_p) OVER(PARTITION BY ar.npp) AS hmax,
			ROW_NUMBER() OVER(PARTITION BY ar.npp ORDER BY ar.htot_p DESC) AS pos -- pas de rank car on veut pas les ex-aequo
	 FROM arbres_input ar) ht
WHERE ht.htot_p >= (2.0/3.0) * ht.hmax AND ht.pos < 4 
GROUP BY ht.npp ;

-- 4. Calcul du tclr de la strate haute et du tcr du taillis/futaie
CREATE TEMPORARY TABLE points_tcl AS
SELECT pt.npp, pt.href, 
	CASE WHEN sum(ar.wac * ar.gtot * ar.lib::numeric) > 0 
	THEN sum(ar.wac * ar.gtot * ar.lib::numeric/2 * (CASE WHEN ar.htot_p >= (2.0/3.0) *pt.href THEN 1 ELSE 0 END))/
		sum(ar.wac * ar.gtot * ar.lib::numeric/2) ELSE NULL END AS tclr_haut,
	CASE WHEN sum(ar.wac * ar.gtot * ar.lib::numeric) > 0
	THEN sum(ar.wac * ar.gtot * (CASE WHEN ar.ori IN ('0','2') AND ar.ess < '50' AND ar.dimess IN ('TPB', 'PB') THEN 1
												   WHEN ar.ori IN ('0') AND ar.ess > '50' AND ar.dimess IN ('TPB', 'PB') THEN 1
												   ELSE 0 END))/ 
		sum(ar.wac * ar.gtot * ar.lib::numeric/2) ELSE NULL END AS tcr_taillis,
	CASE WHEN sum(ar.wac * ar.gtot * ar.lib::numeric) > 0
	THEN sum(ar.wac * ar.gtot * (CASE WHEN ar.ori IN ('0','2') AND ar.ess < '50' AND ar.dimess IN ('TPB', 'PB') THEN 0
												   WHEN ar.ori IN ('0') AND ar.ess > '50' AND ar.dimess IN ('TPB', 'PB') THEN 0
												   ELSE 1 END))/ 
		sum(ar.wac * ar.gtot * ar.lib::numeric/2) ELSE NULL END AS tcr_futaie							 
FROM arbres_input ar
LEFT JOIN points_href pt ON pt.npp = ar.npp
GROUP BY pt.npp, pt.href;

-- 5. Calcul de la structure SFO_CALC
CREATE TEMPORARY TABLE points_sfo AS
SELECT e2.npp, pt.href, pt.tclr_haut, pt.tcr_taillis, pt.tcr_futaie,
	CASE WHEN e2.csp2 = '3' OR (pt.tclr_haut IS NULL AND pt.tcr_taillis IS NULL AND pt.tcr_futaie IS NULL) THEN 0
    WHEN pt.tcr_taillis < 0.25 AND pt.tclr_haut >= (2.0/3.0) THEN 1
	WHEN pt.tcr_taillis < 0.25 AND pt.tclr_haut < (2.0/3.0) THEN 2
	WHEN pt.tcr_taillis >= 0.25 AND pt.tcr_futaie >= 0.25 THEN 3
	WHEN pt.tcr_taillis >= 0.25 AND pt.tcr_futaie < 0.25 THEN 4 
	ELSE NULL END AS sfo_calc
FROM inv_exp_nm.e2point e2
LEFT JOIN points_tcl pt ON pt.npp = e2.npp;

-- 6. Remplissage de la colonne
BEGIN;
UPDATE inv_exp_nm.u_g3foret AS ug3
SET u_sfo_calc = sfo_calc
FROM points_sfo pt 
WHERE pt.npp = ug3.npp AND ug3.incref IN (18) ;
COMMIT;

-- 7. Renseignement de MetaIFN
BEGIN;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18, defout = 18
WHERE famille = 'INV_EXP_NM'
AND donnee = 'U_SFO_CALC';

SELECT *
FROM metaifn.afchamp
WHERE famille = 'INV_EXP_NM'
AND donnee = 'U_SFO_CALC';

COMMIT;
											   
-- 8. Vérification de la donnée
SELECT count(e2.npp), ug3.u_sfo_calc
FROM inv_exp_nm.u_g3foret ug3
LEFT JOIN inv_exp_nm.e2point e2 ON e2.npp = ug3.npp
WHERE e2.incref IN (18) --AND us_nm IN ('1')
GROUP BY u_sfo_calc;

SELECT incref, COUNT(u_sfo_calc)
FROM inv_exp_nm.u_g3foret
GROUP BY incref
ORDER BY incref;



