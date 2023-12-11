BEGIN

ALTER TABLE inv_exp_nm.g3foret ADD COLUMN accessphy character(1); COMMENT ON COLUMN inv_exp_nm.g3foret.accessphy IS 'Accessibilité physique' ;
ALTER TABLE inv_exp_nm.p3point ADD COLUMN accessphy character(1); COMMENT ON COLUMN inv_exp_nm.p3point.accessphy IS 'Accessibilité physique' ;

COMMIT;


-- EXPLOITABILITE EN FORET
BEGIN;

UPDATE inv_exp_nm.g3foret AS u
SET accessphy = 
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
FROM inv_exp_nm.u_g3foret AS f
WHERE u.incref BETWEEN 3 AND 17 AND f.npp = u.npp; -- modif v3
 
-- EXPLOITABILITÉ EN PEUPLERAIE
UPDATE inv_exp_nm.p3point AS u
SET accessphy = 
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
FROM inv_exp_nm.u_p3point AS f
WHERE u.incref BETWEEN 3 AND 17 AND f.npp = u.npp; -- modif v3

																										

-- METADONNEES
BEGIN;

SELECT * FROM metaifn.ajoutdonnee('ACCESSPHY', NULL, 'EXP5', 'IFN', NULL, 5, 'char(1)', 'CC', TRUE, TRUE, $$Accessibilité physique$$, $$Donnée qualifiant l’accessibilité physique des placettes, selon une grille validée en 2023 par un groupe de travail partenarial externe$$);
SELECT * FROM metaifn.ajoutchamp('ACCESSPHY', 'G3FORET', 'INV_EXP_NM', FALSE, 3, 17, 'varchar', 1, NULL, 'FALSE', 'LHaugomat');
SELECT * FROM metaifn.ajoutchamp('ACCESSPHY', 'P3POINT', 'INV_EXP_NM', FALSE, 3, 17, 'varchar', 1, NULL, 'FALSE', 'LHaugomat');

UPDATE metaifn.afchamp 
SET calcin = 3, calcout = 17, validin = 3, validout = 17, defout = 17  
WHERE famille = 'INV_EXP_NM' AND donnee = 'ACCESSPHY'; -- modif v3

COMMIT;

/*
-- VERIFICATION																										
SELECT count(e2.npp), ug3.accessphy
FROM inv_exp_nm.g3foret ug3 
INNER JOIN inv_exp_nm.e2point e2 ON e2.npp = ug3.npp
WHERE e2.incref >= 3 AND e2.us_nm IN ('1') 
GROUP BY accessphy;

SELECT f.npp--, f.incref, f.pentexp_0x, f.iti, f.portance_2x, f.asperite_0x, f.dist
FROM inv_exp_nm.g3foret f
WHERE accessphy IS NULL; 

SELECT f.npp, f.incref, f.pentexp_0x, f.iti, f.portance_2x, f.asperite_0x, f.dist 
FROM inv_exp_nm.g3foret f
LEFT JOIN inv_exp_nm.u_g3foret uf ON uf.npp = f.npp
WHERE accessphy IS NULL;
*/
