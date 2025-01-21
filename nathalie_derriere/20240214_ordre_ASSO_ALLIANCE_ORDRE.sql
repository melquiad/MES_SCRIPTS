-- re-mise en ordre de "position" pour HAB_HIER
WITH tmp AS
	(
	SELECT am.unite, am."mode", ag.gunite, ag.gmode, ROW_NUMBER () OVER (ORDER BY "libelle") AS "position",  am.libelle
	FROM metaifn.abmode am
	INNER JOIN metaifn.groupe ag ON am.unite = ag.unite AND am."mode" = ag."mode"
	WHERE am.unite = 'HAB_HIER'
	)
UPDATE metaifn.abmode ab
SET "position" = tmp."position"
FROM tmp
WHERE ab."mode" = tmp."mode" AND ab.unite = 'HAB_HIER';

-- re-mise en ordre de "classe" pour HAB_HIER
WITH tmp AS
	(
	SELECT am.unite, am."mode", ag.gunite, ag.gmode, ROW_NUMBER () OVER (ORDER BY "libelle") AS "classe",  am.libelle
	FROM metaifn.abmode am
	INNER JOIN metaifn.groupe ag ON am.unite = ag.unite AND am."mode" = ag."mode"
	WHERE am.unite = 'HAB_HIER'
	)
UPDATE metaifn.abmode ab
SET "classe" = tmp."classe"
FROM tmp
WHERE ab."mode" = tmp."mode" AND ab.unite = 'HAB_HIER';



/* finalement pas utile, le tri sur HAB_HIER seul suffit

-- re-mise en ordre de "position" pour alliance, association, ordre (ALL, ASSO, OR)
WITH tmp AS
	(
	SELECT ag.gunite, ag.gmode, am.unite, am."mode", ROW_NUMBER () OVER (ORDER BY "libelle") AS "position",  am.libelle
	FROM metaifn.abgroupe ag
	INNER JOIN metaifn.abmode am ON ag.unite = am.unite AND ag."mode" = am."mode"
	AND  ag.gmode = 'ALL' AND ag.gunite = 'RANG_HAB'
	)
UPDATE metaifn.abmode ab
SET "position" = tmp."position"
FROM tmp
WHERE ab."mode" = tmp."mode" AND ab.unite = 'HAB_HIER';


WITH tmp AS
	(
	SELECT ag.gunite, ag.gmode, am.unite, am."mode", ROW_NUMBER () OVER (ORDER BY "libelle") AS "position",  am.libelle
	FROM metaifn.abgroupe ag
	INNER JOIN metaifn.abmode am ON ag.unite = am.unite AND ag."mode" = am."mode"
	AND  ag.gmode = 'ASSO' AND ag.gunite = 'RANG_HAB'
	)
UPDATE metaifn.abmode ab
SET "position" = tmp."position"
FROM tmp
WHERE ab."mode" = tmp."mode" AND ab.unite = 'HAB_HIER';


WITH tmp AS
	(
	SELECT ag.gunite, ag.gmode, am.unite, am."mode", ROW_NUMBER () OVER (ORDER BY "libelle") AS "position",  am.libelle
	FROM metaifn.abgroupe ag
	INNER JOIN metaifn.abmode am ON ag.unite = am.unite AND ag."mode" = am."mode"
	AND  ag.gmode = 'OR' AND ag.gunite = 'RANG_HAB'
	)
UPDATE metaifn.abmode ab
SET "position" = tmp."position"
FROM tmp
WHERE ab."mode" = tmp."mode" AND ab.unite = 'HAB_HIER';
SELECT ag.gunite, ag.gmode, am.unite, am."mode", am.libelle
FROM metaifn.abgroupe ag
INNER JOIN metaifn.abmode am ON ag.unite = am.unite AND ag."mode" = am."mode"
AND  ag.gmode = 'ALL' AND ag.gunite = 'RANG_HAB'
ORDER BY 5;

-----------------------------------------------------------------------------------------------------------------------
SELECT ag.gunite, ag.gmode, am.unite, am."mode", am.libelle
FROM metaifn.abgroupe ag
INNER JOIN metaifn.abmode am ON ag.unite = am.unite AND ag."mode" = am."mode"
AND  ag.gmode = 'ALL' AND ag.gunite = 'RANG_HAB'
ORDER BY 5;

SELECT ag.gunite, ag.gmode, am.unite, am."mode", am.libelle
FROM metaifn.abgroupe ag
INNER JOIN metaifn.abmode am ON ag.unite = am.unite AND ag."mode" = am."mode"
AND  ag.gmode = 'ASSO' AND ag.gunite = 'RANG_HAB'
ORDER BY 5;

SELECT ag.gunite, ag.gmode, am.unite, am."mode", am.libelle
FROM metaifn.abgroupe ag
INNER JOIN metaifn.abmode am ON ag.unite = am.unite AND ag."mode" = am."mode"
AND  ag.gmode = 'OR' AND ag.gunite = 'RANG_HAB'
ORDER BY 5;

*/


