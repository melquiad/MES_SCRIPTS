-- Sélection des données dont l'unité a changé pour report dans les métadonnées de dataIFN
	-- à jouer dans test-inv-prod ou inv-prod
SELECT donnee, unite, validite
FROM ifn_meta.donnee_unite du
INNER JOIN visu_metadonnees.donnee d USING (donnee)
WHERE lower(validite) = 2024
AND EXISTS (
    SELECT 1
    FROM donnee_unite du2
    WHERE du.donnee = du2.donnee
    AND du.unite != du2.unite
)
ORDER BY donnee;