WITH RECURSIVE CompteurCTE AS
	(
	SELECT 1 AS i
	UNION ALL
	SELECT i + 1
	FROM CompteurCTE
	WHERE i < 5
	)
SELECT *
FROM CompteurCTE;
---------------------------------------------------------------------------------------------------------------
SELECT m.unite, m.mode, h.punite, h.pmode, g.gmode AS rang_hab, m.mode AS hab, 0 AS niveau
    FROM metaifn.abmode m
    INNER JOIN metaifn.abgroupe g1 ON g1.gunite = 'HAB_HIER' AND g1.unite = 'HAB' AND g1."mode" = m."mode"
    INNER JOIN metaifn.abgroupe g ON g.gunite = 'RANG_HAB' AND g.unite = g1.gunite AND g.mode = g1.gmode
    INNER JOIN metaifn.abhierarchie h ON h.punite = 'HAB_HIER' AND h.unite = 'HAB_HIER' AND h.mode = g1.gmode
    WHERE m.unite = 'HAB';  