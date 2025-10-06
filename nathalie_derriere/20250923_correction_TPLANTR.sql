
SELECT incref, tplantr, count(tplantr), tplant, count(tplant)
FROM inv_exp_nm.g3foret
--WHERE tplantr IS NOT NULL
GROUP BY incref, tplantr, tplant
ORDER BY incref DESC;

SELECT incref, tplantr, count(tplantr), tplant, count(tplant)
FROM inv_exp_nm.p3point
--WHERE tplantr IS NOT NULL
GROUP BY incref, tplantr, tplant
ORDER BY incref DESC;

-- TPLANTR doit avoir une unité constante dans le temps, en l'occurrence TPLANT3

	-- pour les incref 12 à 13 (TPLANT = TPLANTR)

	-- pour incref >= 14
UPDATE inv_exp_nm.g3foret
SET tplantr = CASE WHEN tplant = '0' THEN '0' 
				   WHEN tplant = 'P' THEN 'P'
				   WHEN tplant = 'Q' THEN 'P' 
				   WHEN tplant = 'R' THEN '0'
				   WHEN tplant = 'X' THEN 'X' 			   
				   ELSE NULL END
WHERE incref >= 14;

UPDATE inv_exp_nm.p3point
SET tplantr = CASE WHEN tplant = '0' THEN '0' 
				   WHEN tplant = 'P' THEN 'P'
				   WHEN tplant = 'Q' THEN 'P' 
				   WHEN tplant = 'R' THEN '0'
				   WHEN tplant = 'X' THEN 'X' 			   
				   ELSE NULL END
WHERE incref >= 14;


