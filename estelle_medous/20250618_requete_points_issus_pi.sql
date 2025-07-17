

SELECT ne.ztir, n.tirmax, n.id_noeud, p.id_point
, pe.poids AS poids1 
-- Données photo-interprétées
,ppi.occ, ppi.uspi, ppi.cso, fla1haie.id_transect AS haie -- Le champ `haie` est rempli dès lors qu'au moins un segment linéaire inventorié, hors alignement, à moins de 25 m du point est observé à la PI (en table fla_pi), vide sinon.
FROM inv_prod_new.campagne c
INNER JOIN inv_prod_new.echantillon e ON e.id_campagne = c.id_campagne
INNER JOIN inv_prod_new.echantillon e2 ON e2.ech_parent_stat = e.id_ech
INNER JOIN inv_prod_new.noeud_ech ne ON ne.id_ech = e2.id_ech -- ZTIR est renseigné sur l'échantillon de noeuds de deuxième phase (identique à l'échantillon de noeuds de première phase)
INNER JOIN inv_prod_new.noeud n ON n.id_noeud = ne.id_noeud
INNER JOIN inv_prod_new.point_ech pe ON pe.id_ech = e.id_ech AND pe.id_noeud = ne.id_noeud
INNER JOIN inv_prod_new.point p ON p.id_point = pe.id_point
INNER JOIN inv_prod_new.transect t ON t.id_transect = p.id_transect
INNER JOIN inv_prod_new.point_pi ppi ON ppi.id_ech = pe.id_ech AND ppi.id_point = pe.id_point
LEFT JOIN (SELECT DISTINCT fpi.id_transect
           FROM inv_prod_new.campagne c
           INNER JOIN inv_prod_new.echantillon e ON e.id_campagne = c.id_campagne
           INNER JOIN inv_prod_new.transect_ech te ON te.id_ech = e.id_ech
           INNER JOIN inv_prod_new.fla_pi fpi ON fpi.id_ech = te.id_ech AND fpi.id_transect = te.id_transect
           WHERE c.millesime = 2026
             AND e.type_ech = 'IFN' AND e.type_ue = 'T' AND e.phase_stat = 1
             AND flpi IN ('H', 'B', 'C')
             AND ABS(disti) <= 25
           ) fla1haie ON fla1haie.id_transect = t.id_transect
WHERE c.millesime = 2026
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 1
AND e.ech_parent_stat IS NULL
AND e.ech_parent IS NULL;
