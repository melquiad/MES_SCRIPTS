-- METADONNEES
BEGIN;

SELECT * FROM metaifn.ajoutdonnee('U_ACCESS', NULL, 'EXP5', 'AUTRE', NULL, 5, 'varchar(1)', 'CC', TRUE, TRUE, 
'Exploitabilite nouvelle grille v2', 'Exploitabilite nouvelle grille v2 pour etude de reference disponibilites', 
NULL, NULL, FALSE, NULL, NULL, NULL, NULL, 'cbastick');

SELECT * FROM metaifn.ajoutchamp('U_ACCESS', 'U_G3FORET', 'INV_EXP_NM', FALSE, 6, 16, 'varchar', 1, 214, 'FALSE', 'cbastick');
SELECT * FROM metaifn.ajoutchamp('U_ACCESS', 'U_P3POINT', 'INV_EXP_NM', FALSE, 6, 16, 'varchar', 1, 53, 'FALSE', 'cbastick');

COMMIT;

BEGIN;

ALTER TABLE inv_exp_nm.u_g3foret ADD COLUMN u_access character(1); COMMENT ON COLUMN inv_exp_nm.u_g3foret.u_access IS 'Exploitabilite nouvelle grille v2' ;
ALTER TABLE inv_exp_nm.u_p3point ADD COLUMN u_access character(1); COMMENT ON COLUMN inv_exp_nm.u_p3point.u_access IS 'Exploitabilite nouvelle grille v2' ;

COMMIT;


-- EXPLOITABILITE EN FORET
BEGIN;

UPDATE inv_exp_nm.u_g3foret AS u
SET u_access = 
CASE
	WHEN (portance_2x IN ('0') OR asperite_0x IN ('2')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('2') AND dist IN ('0','1','2') THEN '3'
	WHEN (portance_2x IN ('0') OR asperite_0x IN ('2')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('0','1') AND dist IN ('0','1','2') THEN '2'
	WHEN (portance_2x IN ('0') OR asperite_0x IN ('2')) THEN '4'											  

	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('2','3') AND pentexp_0x IN ('0', '1') AND dist IN ('1') THEN '2' -- modif v3
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('2','3') AND dist IN ('3','4') THEN '4'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('2','3') AND pentexp_0x IN ('3') AND dist IN ('2') THEN '4'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('2','3') AND pentexp_0x IN ('4') THEN '4'
	
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('4') AND dist IN ('3','4') THEN '4'	
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('2') AND dist IN ('0','1') THEN '2'
																										
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('0','1') AND dist IN ('3') THEN '2'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('0','1') AND dist IN ('2') THEN '1'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('0','1') AND dist IN ('0','1') THEN '0'	
																										
    WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND pentexp_0x IN ('5') THEN '4'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) THEN '3'
										  
ELSE NULL END 
FROM inv_exp_nm.g3foret AS f
WHERE u.incref BETWEEN 3 AND 17 AND f.npp = u.npp; -- modif v3
 
-- EXPLOITABILITÉ EN PEUPLERAIE
UPDATE inv_exp_nm.u_p3point AS u
SET u_access = 
CASE
	WHEN (portance_2x IN ('0') OR asperite_0x IN ('2')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('2') AND dist IN ('0','1','2') THEN '3'
	WHEN (portance_2x IN ('0') OR asperite_0x IN ('2')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('0','1') AND dist IN ('0','1','2') THEN '2'
	WHEN (portance_2x IN ('0') OR asperite_0x IN ('2')) THEN '4'											  

	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('2','3') AND pentexp_0x IN ('0', '1') AND dist IN ('1') THEN '2' -- modif v3
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('2','3') AND dist IN ('3','4') THEN '4'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('2','3') AND pentexp_0x IN ('3') AND dist IN ('2') THEN '4'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('2','3') AND pentexp_0x IN ('4') THEN '4'
	
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('4') AND dist IN ('3','4') THEN '4'	
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('2') AND dist IN ('0','1') THEN '2'
																										
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('0','1') AND dist IN ('3') THEN '2'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('0','1') AND dist IN ('2') THEN '1'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND iti IN ('0','1') AND pentexp_0x IN ('0','1') AND dist IN ('0','1') THEN '0'	
																										
    WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) 
		AND pentexp_0x IN ('5') THEN '4'
	WHEN (portance_2x IS NULL OR portance_2x IN ('1', '2')) AND (asperite_0x IS NULL OR asperite_0x IN ('0','1')) THEN '3'
										  
ELSE NULL END 
FROM inv_exp_nm.p3point AS f
WHERE u.incref BETWEEN 3 AND 17 AND f.npp = u.npp; -- modif v3

UPDATE metaifn.afchamp 
SET calcin = 3, calcout = 17, validin = 3, validout = 17, defout = 17  
WHERE famille = 'INV_EXP_NM' AND donnee = 'U_ACCESS'; -- modif v3
																										
COMMIT;

-- VERIFICATION																										
SELECT count(e2.npp), ug3.u_access 
FROM inv_exp_nm.u_g3foret ug3 
INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = ug3.npp
WHERE e2.incref >= 3 AND e2.us_nm IN ('1') 
GROUP BY u_access;

SELECT f.npp, f.incref, f.pentexp_0x, f.iti, f.portance_2x, f.asperite_0x, f.dist 
FROM inv_exp_nm.g3foret f
LEFT JOIN inv_exp_nm.u_g3foret uf ON uf.npp = f.npp
WHERE f.incref >= 3 AND u_access IS NULL;																										