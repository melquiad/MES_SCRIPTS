

-- MAJ 2023 et 2024

SELECT incref, count(u_hab)
FROM inv_exp_nm.u_g3foret
--WHERE u_hab IS null
GROUP BY incref
ORDER BY incref DESC;

BEGIN;

UPDATE inv_exp_nm.u_g3foret f
SET u_hab = h.hab
FROM inv_exp_nm.g3habitat h
WHERE f.npp = h.npp AND num_hab = 1
AND f.incref > 17;


SELECT f.npp, hab, u_hab
FROM inv_exp_nm.u_g3foret f
INNER JOIN inv_exp_nm.g3habitat h ON f.npp = h.npp
WHERE u_hab != hab AND incref > 17
ORDER BY u_hab, hab;

UPDATE metaifn.afchamp
SET defin = 0, calcin = 0, validin = 0, defout = NULL, calcout = 19, validout = 19
WHERE donnee = 'U_HAB' ;

COMMIT;

-------------------------------------------------------------
-- MAJ 2005 --> 2023 (en particulier pour la GRECO H)

UPDATE inv_exp_nm.u_g3foret f
SET u_hab = h.hab
FROM inv_exp_nm.g3habitat h
WHERE f.npp = h.npp AND num_hab = 1
AND f.incref < 18;

SELECT f.npp, hab, u_hab
FROM inv_exp_nm.u_g3foret f
INNER JOIN inv_exp_nm.g3habitat h ON f.npp = h.npp
WHERE u_hab != hab AND incref < 18
ORDER BY u_hab, hab;











