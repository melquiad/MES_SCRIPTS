--SET enable_nestloop = FALSE;

WITH RECURSIVE x (unite, mode, hmode, punite, pmode, rang_hab, hab, niveau) AS (
    SELECT m.unite, m.mode, g1.gmode AS hmode, h.punite, h.pmode, g.gmode AS rang_hab, m.mode AS hab, 0 AS niveau
    FROM metaifn.abmode m
    INNER JOIN metaifn.abgroupe g1 ON g1.gunite = 'HAB_HIER' AND g1.unite = 'HAB' AND g1."mode" = m."mode"
    INNER JOIN metaifn.abgroupe g ON g.gunite = 'RANG_HAB' AND g.unite = g1.gunite AND g.mode = g1.gmode
    INNER JOIN metaifn.abhierarchie h ON h.punite = 'HAB_HIER' AND h.unite = 'HAB_HIER' AND h."mode" = g1.gmode
    WHERE m.unite = 'HAB'
    UNION ALL
    SELECT m.unite, m.mode, m.mode AS hmode, h.punite, h.pmode, g.gmode, x.hab, x.niveau - 1
    FROM metaifn.abmode m
    INNER JOIN metaifn.abgroupe g ON g.gunite = 'RANG_HAB' AND g.unite = 'HAB_HIER' AND g.mode = m.mode
    LEFT JOIN metaifn.abhierarchie h ON m.unite = 'HAB_HIER' AND h.punite = 'HAB_HIER' AND h.unite = 'HAB_HIER' AND h."mode" = m.mode
    INNER JOIN x ON m.unite = x.punite AND m.mode = x.pmode
)
, alliances AS (
    SELECT x.hab, m.libelle AS alliance
    FROM x
    INNER JOIN metaifn.abmode m ON m.unite = 'HAB_HIER' AND x.hmode = m.mode
    WHERE rang_hab = 'ALL'
)
, sous_alliances AS (
    SELECT x.hab, m.libelle AS sous_alliance
    FROM x
    INNER JOIN metaifn.abmode m ON m.unite = 'HAB_HIER' AND x.hmode = m.mode
    WHERE rang_hab = 'SALL'
)
, ordres AS (
    SELECT x.hab, m.libelle AS ordre
    FROM x
    INNER JOIN metaifn.abmode m ON m.unite = 'HAB_HIER' AND x.hmode = m.mode
    WHERE rang_hab = 'OR'
)
, sous_ordres AS (
    SELECT x.hab, m.libelle AS sous_ordre
    FROM x
    INNER JOIN metaifn.abmode m ON m.unite = 'HAB_HIER' AND x.hmode = m.mode
    WHERE rang_hab = 'SOR'
)
, classes AS (
    SELECT x.hab, m.libelle AS classe
    FROM x
    INNER JOIN metaifn.abmode m ON m.unite = 'HAB_HIER' AND x.hmode = m.mode
    WHERE rang_hab = 'CL'
)
, sous_classes AS (
    SELECT x.hab, m.libelle AS sous_classe
    FROM x
    INNER JOIN metaifn.abmode m ON m.unite = 'HAB_HIER' AND x.hmode = m.mode
    WHERE rang_hab = 'SCLE'
)
, associations AS (
    SELECT x.hab, m.libelle AS association
    FROM x
    INNER JOIN metaifn.abmode m ON m.unite = 'HAB_HIER' AND x.hmode = m.mode
    WHERE rang_hab = 'ASSO'
)
SELECT h."mode", h.libelle,
gcoi.gmode AS corine_ifn, mcoi.libelle AS lib_corine_ifn
, ghic.gmode AS hic_hab1, mhic.libelle AS lib_hic
, geur.gmode AS eur15, meur.libelle as lib_eur15
, ass.association
, a.alliance
, sa.sous_alliance
, o.ordre
, so.sous_ordre
, c.classe
, sc.sous_classe
, gcop.gmode AS corine_pvf2, mcop.libelle AS lib_corine_pvf2
, gfpv.gmode AS fichepvf2
, gcdh.gmode AS cd_hab, mcdh.libelle AS lib_cd_hab
, geun.gmode AS eunis, meun.libelle as lib_eunis
FROM metaifn.abmode h
LEFT JOIN metaifn.abgroupe gcdh ON gcdh.unite = 'HAB' AND gcdh.gunite = 'CD_HAB' AND gcdh."mode" = h."mode"
LEFT JOIN metaifn.abmode mcdh ON gcdh.gunite = mcdh.unite AND gcdh.gmode = mcdh."mode"
LEFT JOIN metaifn.abgroupe ghic ON ghic.unite = 'HAB' AND ghic.gunite = 'HIC' AND ghic."mode" = h."mode"
LEFT JOIN metaifn.abmode mhic ON ghic.gunite = mhic.unite AND ghic.gmode = mhic."mode"
LEFT JOIN metaifn.abgroupe geur ON geur.unite = 'HAB' AND geur.gunite = 'EUR15' AND geur."mode" = h."mode"
LEFT JOIN metaifn.abmode meur ON geur.gunite = meur.unite AND geur.gmode = meur."mode"
LEFT JOIN metaifn.abgroupe gcoi ON gcoi.unite = 'HAB' AND gcoi.gunite = 'CORINE_IFN' AND gcoi."mode" = h."mode"
LEFT JOIN metaifn.abmode mcoi ON gcoi.gunite = mcoi.unite AND gcoi.gmode = mcoi."mode"
LEFT JOIN metaifn.abgroupe gcop ON gcop.unite = 'HAB' AND gcop.gunite = 'CORINE_PVF2' AND gcop."mode" = h."mode"
LEFT JOIN metaifn.abmode mcop ON gcop.gunite = mcop.unite AND gcop.gmode = mcop."mode"
LEFT JOIN metaifn.abgroupe gfpv ON gfpv.unite = 'HAB' AND gfpv.gunite = 'FICHEPVF2' AND gfpv."mode" = h."mode"
LEFT JOIN metaifn.abmode mfpv ON gfpv.gunite = mfpv.unite AND gfpv.gmode = mfpv."mode"
LEFT JOIN metaifn.abgroupe geun ON geun.unite = 'HAB' AND geun.gunite = 'EUNIS' AND geun."mode" = h."mode"
LEFT JOIN metaifn.abmode meun ON geun.gunite = meun.unite AND geun.gmode = meun."mode"
LEFT JOIN alliances a ON h."mode" = a.hab
LEFT JOIN sous_alliances sa ON h."mode" = sa.hab
LEFT JOIN ordres o ON h."mode" = o.hab
LEFT JOIN sous_ordres so ON h."mode" = so.hab
LEFT JOIN classes c ON h."mode" = c.hab
LEFT JOIN sous_classes sc ON h."mode" = sc.hab
LEFT JOIN associations ass ON h."mode" = ass.hab
WHERE h.unite = 'HAB'
ORDER BY h."mode";
