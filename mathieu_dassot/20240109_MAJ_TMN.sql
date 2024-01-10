/*
SELECT *
FROM metaifn.addonnee
WHERE donnee IN ('TMN','TM','CYC','USA');

SELECT *
FROM inv_exp_am.e2point
WHERE tmn = '';

SELECT *
FROM inv_exp_am.e2point
WHERE (dep, cyc) IN (('46','2'),('47','2'),('54','2'),('63','2'),('67','1')) AND usa = '1';
*/

	
UPDATE inv_exp_am.e2point
SET tmn = '3'
WHERE (dep, cyc) IN (('46','2'),('47','2'),('54','2'),('63','2'),('67','1')) AND usa = '1';

UPDATE inv_exp_am.e2point
SET tmn = NULL
WHERE tmn = ' ';


