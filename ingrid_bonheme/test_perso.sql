SET enable_nestloop = FALSE;

WITH RECURSIVE x (unite, mode, punite, pmode, rang_hab, hab, niveau) AS (
    SELECT m.unite, m.mode, h.punite, h.pmode, g.gmode AS rang_hab, m.mode AS hab, 0 AS niveau
    FROM metaifn.abmode m
    INNER JOIN metaifn.abgroupe g1 ON g1.gunite = 'HAB_HIER' AND g1.unite = 'HAB' AND g1."mode" = m."mode"
    INNER JOIN metaifn.abgroupe g ON g.gunite = 'RANG_HAB' AND g.unite = g1.gunite AND g.mode = g1.gmode
    INNER JOIN metaifn.abhierarchie h ON h.punite = 'HAB_HIER' AND h.unite = 'HAB_HIER' AND h.mode = g1.gmode
    WHERE m.unite = 'HAB'
    UNION ALL
    SELECT m.unite, m.mode, h.punite, h.pmode, g.gmode, x.hab, x.niveau - 1
    FROM metaifn.abmode m
    INNER JOIN metaifn.abgroupe g ON g.gunite = 'RANG_HAB' AND g.unite = 'HAB_HIER' AND g.mode = m.mode
    LEFT JOIN metaifn.abhierarchie h ON m.unite = 'HAB_HIER' AND h.punite = 'HAB_HIER' AND h.unite = 'HAB_HIER' AND h.mode = m.mode
    INNER JOIN x ON m.unite = x.punite AND m.mode = x.pmode
)
, alliances AS (
    SELECT x.hab, m.libelle AS alliance
    FROM x
    INNER JOIN metaifn.abmode m ON m.unite = 'HAB_HIER' AND x.mode = m.mode
    WHERE rang_hab = 'ALL'
)
SELECT (p1.incref + 2005) AS campagne, p1.idp, p1.dep, round(st_x(p1.geom)::NUMERIC) AS xl93, round(st_y(p1.geom)::NUMERIC) AS yl93
, h.hab
, a.alliance
, gcdh.gmode AS cd_hab, mcdh.libelle AS lib_cd_hab
, ghic.gmode AS hic_hab1, mhic.libelle AS lib_hic
, geur.gmode AS eur15, meur.libelle as lib_eur15
, gcoi.gmode AS corine_ifn, mcoi.libelle AS lib_corine_ifn
, gcop.gmode AS corine_pvf2, mcop.libelle AS lib_corine_pvf2
, gfpv.gmode AS fichepvf2
, geun.gmode AS eunis, meun.libelle as lib_eunis
FROM inv_exp_nm.e1point p1
INNER JOIN inv_exp_nm.g3habitat h USING (npp)
INNER JOIN metaifn.abgroupe gcdh ON gcdh.unite = 'HAB' AND gcdh.gunite = 'CD_HAB' AND gcdh."mode" = h.hab
INNER JOIN metaifn.abmode mcdh ON gcdh.gunite = mcdh.unite AND gcdh.gmode = mcdh."mode"
INNER JOIN metaifn.abgroupe ghic ON ghic.unite = 'HAB' AND ghic.gunite = 'HIC' AND ghic."mode" = h.hab
INNER JOIN metaifn.abmode mhic ON ghic.gunite = mhic.unite AND ghic.gmode = mhic."mode"
INNER JOIN metaifn.abgroupe gcoi ON gcoi.unite = 'HAB' AND gcoi.gunite = 'CORINE_IFN' AND gcoi."mode" = h.hab
INNER JOIN metaifn.abmode mcoi ON gcoi.gunite = mcoi.unite AND gcoi.gmode = mcoi."mode"
INNER JOIN metaifn.abgroupe gcop ON gcop.unite = 'HAB' AND gcop.gunite = 'CORINE_PVF2' AND gcop."mode" = h.hab
INNER JOIN metaifn.abmode mcop ON gcop.gunite = mcop.unite AND gcop.gmode = mcop."mode"
INNER JOIN metaifn.abgroupe gfpv ON gfpv.unite = 'HAB' AND gfpv.gunite = 'FICHEPVF2' AND gfpv."mode" = h.hab
INNER JOIN metaifn.abmode mfpv ON gfpv.gunite = mfpv.unite AND gfpv.gmode = mfpv."mode"
INNER JOIN metaifn.abgroupe geun ON geun.unite = 'HAB' AND geun.gunite = 'EUNIS' AND geun."mode" = h.hab
INNER JOIN metaifn.abmode meun ON geun.gunite = meun.unite AND geun.gmode = meun."mode"
INNER JOIN metaifn.abgroupe geur ON geur.unite = 'HAB' AND geur.gunite = 'EUR15' AND geur."mode" = h.hab
INNER JOIN metaifn.abmode meur ON geur.gunite = meur.unite AND geur.gmode = meur."mode"
LEFT JOIN alliances a ON h.hab = a.hab
WHERE p1.dep IN ('79', '86', '17', '16', '24', '47', '33', '40', '64', '19', '87', '23')
AND h.num_hab = 1
AND NOT EXISTS (
    SELECT 1
    FROM inv_exp_nm.g3habitat h2
    WHERE h.npp = h2.npp
    AND h2.num_hab > 1
)
ORDER BY idp;