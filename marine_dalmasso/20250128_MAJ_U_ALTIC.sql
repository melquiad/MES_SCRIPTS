


-- nouveau calcul 
SELECT npp, e.incref, zp, rayo, u_altic, zp + 440 * (1 - (rayo::real /100)) AS new_u_altic
FROM inv_exp_nm.g3ecologie e
LEFT JOIN inv_exp_nm.e1point using(npp)
LEFT JOIN inv_exp_nm.u_g3foret using(npp)
WHERE e.incref IN (15,16,17,18)
UNION
SELECT npp, e.incref, zp, rayo, u_altic, zp + 440 * (1 - (rayo::real /100)) AS new_u_altic
FROM inv_exp_nm.p3ecologie e
LEFT JOIN inv_exp_nm.e1point using(npp)
LEFT JOIN inv_exp_nm.u_p3point using(npp)
WHERE e.incref IN (15,16,17,18)
ORDER BY npp;


-- mise à jour de U_ALTIC pour les incref 15 à 18
WITH maj AS (
		SELECT npp, e.incref, zp, rayo, u_altic, zp + 440 * (1 - (rayo::real /100))AS new_u_altic
		FROM inv_exp_nm.g3ecologie e
		LEFT JOIN inv_exp_nm.e1point USING (npp)
		LEFT JOIN inv_exp_nm.u_g3foret USING (npp)
		WHERE e.incref IN (15,16,17,18)
		ORDER BY npp
		)
UPDATE inv_exp_nm.u_g3foret g
SET u_altic = m.new_u_altic
FROM maj m
WHERE g.npp = m.npp;


WITH maj AS (
		SELECT npp, e.incref, zp, rayo, u_altic, zp + 440 * (1 - (rayo::real /100)) AS new_u_altic
		FROM inv_exp_nm.p3ecologie e
		LEFT JOIN inv_exp_nm.e1point using(npp)
		LEFT JOIN inv_exp_nm.u_p3point using(npp)
		WHERE e.incref IN (15,16,17,18)
		ORDER BY npp
		)
UPDATE inv_exp_nm.u_p3point p
SET u_altic = m.new_u_altic
FROM maj m
WHERE p.npp = m.npp;


		