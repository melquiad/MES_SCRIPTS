
-- re-mise en ordre de "position" pour HAB
WITH nr AS
	(
	SELECT unite, "mode", ROW_NUMBER () OVER (ORDER BY "mode") AS "position"
	FROM metaifn.abmode a
	WHERE unite = 'HAB'
	)
UPDATE metaifn.abmode ab
SET "position" = nr."position"
FROM nr
WHERE ab."mode" = nr."mode" AND ab.unite = 'HAB';

-- re-mise en ordre de "classe" pour HAB
WITH nr AS
	(
	SELECT unite, "mode", ROW_NUMBER () OVER (ORDER BY "mode") AS classe
	FROM metaifn.abmode a
	WHERE unite = 'HAB'
	)
UPDATE metaifn.abmode ab
SET classe = nr.classe
FROM nr
WHERE ab."mode" = nr."mode" AND ab.unite = 'HAB';

-- re-mise en ordre de "position" pour CD_HAB
WITH nr AS
	(
	SELECT unite, "mode", ROW_NUMBER () OVER (ORDER BY "libelle") AS "position", libelle
	FROM metaifn.abmode a
	WHERE unite = 'CD_HAB'
	)
UPDATE metaifn.abmode ab
SET "position" = nr."position"
FROM nr
WHERE ab."mode" = nr."mode" AND ab.unite = 'CD_HAB';


-- re-mise en ordre de "classe" pour CD_HAB
WITH nr AS
	(
	SELECT unite, "mode", ROW_NUMBER () OVER (ORDER BY "libelle") AS classe, libelle
	FROM metaifn.abmode a
	WHERE unite = 'CD_HAB'
	)
UPDATE metaifn.abmode ab
SET classe = nr.classe
FROM nr
WHERE ab."mode" = nr."mode" AND ab.unite = 'CD_HAB';


/* Finalement ne convient pas !
-- version Cédric avec expression régulière pour mieux trier par le champ "mode"
WITH nr AS
	(
	SELECT unite, "mode", row_number() OVER (ORDER BY (regexp_replace("mode", '[A-Za-z]', '', 'g'))::NUMERIC, "position") AS "position"
	FROM metaifn.abmode a
	WHERE unite = 'HAB'
	)
UPDATE metaifn.abmode ab
SET "position" = nr."position"
FROM nr
WHERE ab."mode" = nr."mode" AND ab.unite = 'HAB';


WITH nr AS
	(
	SELECT unite, "mode", row_number() OVER (ORDER BY (regexp_replace("mode", '[A-Za-z]', '', 'g'))::NUMERIC, classe) AS classe
	FROM metaifn.abmode a
	WHERE unite = 'HAB'
	)
UPDATE metaifn.abmode ab
SET classe = nr.classe
FROM nr
WHERE ab."mode" = nr."mode" AND ab.unite = 'HAB';
*/


