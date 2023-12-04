
with  tab_parent as 
	(SELECT (p1.incref + 2005) as campagne, g5.gmode as niv_par, m4.libelle as lib_par,
	g6.gmode as niv_gpar, m5.libelle as lib_gpar, p1.idp, p1.dep, g.gmode AS hic_hab1, m.libelle as lib_hic, g2.gmode as corine_ifn, m2.libelle as lib_corine_ifn, g3.gmode as corine_pvf2, m3.libelle as lib_corine_pvf2, cp.xl93, cp.yl93
	FROM inv_exp_nm.e1point_coord_l2_l93 AS cp 
	INNER join inv_exp_nm.e1point AS p1  ON cp.npp = p1.npp and p1.dep IN ('79', '86', '17', '16', '24', '47','33', '40', '64', '19', '87', '23')
	INNER JOIN inv_exp_nm.habitats AS hab ON cp.npp = hab.npp and hab.hab2 is null and hab.hab3 is null	 
	left JOIN metaifn.abgroupe g ON g.gunite = 'HIC' AND g.unite = 'HAB' AND hab.hab1 = g.mode
	left join metaifn.abmode m on m.unite = g.gunite and m.mode = g.gmode	 
	left join metaifn.abgroupe g2 ON g2.gunite = 'CORINE_IFN' AND g2.unite = 'HAB' AND hab.hab1 = g2.mode
	left join metaifn.abmode m2 on m2.unite = g2.gunite and m2.mode = g2.gmode	 
	left join metaifn.abgroupe g3 ON g3.gunite = 'CORINE_PVF2' AND g3.unite = 'HAB' AND hab.hab1 = g3.mode
	left join metaifn.abmode m3 on m3.unite = g3.gunite and m3.mode = g3.gmode	 
	left join metaifn.abgroupe g4 on g4.mode = hab.hab1 and g4.gunite='HAB_HIER'
	left join metaifn.abhierarchie h on h.mode = g4.gmode and h.unite='HAB_HIER'
	left join metaifn.abhierarchie h2 on h2.unite='HAB_HIER' and h2.mode = h.pmode 
	left join metaifn.abgroupe g5 ON g5.unite = 'HAB_HIER' AND g5.gunite = 'RANG_HAB' AND h.pmode = g5.mode
	left join metaifn.abmode m4 ON m4.unite = 'HAB_HIER' AND m4.mode = h.pmode
	left join metaifn.abgroupe g6 ON g6.unite = 'HAB_HIER' AND g6.gunite = 'RANG_HAB' AND h2.pmode = g6.mode
	left join metaifn.abmode m5 ON m5.unite = 'HAB_HIER' AND m5.mode = h2.pmode)
select idp, case when tab_parent.niv_gpar = 'ALL' then tab_parent.lib_gpar
                    when tab_parent.niv_par='ALL' then tab_parent.lib_par
                    else '0'
                    end as Alliance, campagne, dep, hic_hab1, lib_hic, corine_ifn, lib_corine_ifn, corine_pvf2, lib_corine_pvf2, xl93, yl93
from tab_parent order by idp;
--------------------------------------------- HIC ----------------------------------------------------------------
SELECT (p1.incref + 2005) as campagne, p1.idp, p1.dep, g.gmode AS hic_hab1, m.libelle as lib_hic,cp.xl93, cp.yl93
	FROM inv_exp_nm.e1point_coord_l2_l93 AS cp 
	INNER join inv_exp_nm.e1point AS p1  ON cp.npp = p1.npp and p1.dep IN ('79', '86', '17', '16', '24', '47','33', '40', '64', '19', '87', '23')
	INNER JOIN inv_exp_nm.habitats AS hab ON cp.npp = hab.npp and hab.hab2 is null and hab.hab3 is null	 
	left JOIN metaifn.abgroupe g ON g.gunite = 'HIC' AND g.unite = 'HAB' AND hab.hab1 = g.mode
	left join metaifn.abmode m on m.unite = g.gunite and m.mode = g.gmode;
-------------------------------------------- CORINE_IFN et CORINE_PVF2 ------------------------------------------------------------
SELECT (p1.incref + 2005) as campagne, p1.idp, p1.dep, g2.gmode as corine_ifn, m2.libelle as lib_corine_ifn, g3.gmode as corine_pvf2, m3.libelle as lib_corine_pvf2, cp.xl93, cp.yl93
	FROM inv_exp_nm.e1point_coord_l2_l93 AS cp 
	INNER join inv_exp_nm.e1point AS p1  ON cp.npp = p1.npp and p1.dep IN ('79', '86', '17', '16', '24', '47','33', '40', '64', '19', '87', '23')
	INNER JOIN inv_exp_nm.habitats AS hab ON cp.npp = hab.npp and hab.hab2 is null and hab.hab3 is null	 	 
	left join metaifn.abgroupe g2 ON g2.gunite = 'CORINE_IFN' AND g2.unite = 'HAB' AND hab.hab1 = g2.mode
	left join metaifn.abmode m2 on m2.unite = g2.gunite and m2.mode = g2.gmode
	left join metaifn.abgroupe g3 ON g3.gunite = 'CORINE_PVF2' AND g3.unite = 'HAB' AND hab.hab1 = g3.mode
	left join metaifn.abmode m3 on m3.unite = g3.gunite and m3.mode = g3.gmode;
-----------------------------------------------------------------------------------------------------------------------------------
SELECT (p1.incref + 2005) as campagne, g5.gmode as niv_par, m4.libelle as lib_par,
	g6.gmode as niv_gpar, m5.libelle as lib_gpar, p1.idp, p1.dep, cp.xl93, cp.yl93
	FROM inv_exp_nm.e1point_coord_l2_l93 AS cp 
	INNER join inv_exp_nm.e1point AS p1  ON cp.npp = p1.npp and p1.dep IN ('79', '86', '17', '16', '24', '47','33', '40', '64', '19', '87', '23')
	INNER JOIN inv_exp_nm.habitats AS hab ON cp.npp = hab.npp and hab.hab2 is null and hab.hab3 is null	 
	left join metaifn.abgroupe g4 on g4.mode = hab.hab1 and g4.gunite='HAB_HIER'
	left join metaifn.abhierarchie h on h.mode = g4.gmode and h.unite='HAB_HIER'
	left join metaifn.abhierarchie h2 on h2.unite='HAB_HIER' and h2.mode = h.pmode 
	left join metaifn.abgroupe g5 ON g5.unite = 'HAB_HIER' AND g5.gunite = 'RANG_HAB' AND h.pmode = g5.mode
	left join metaifn.abmode m4 ON m4.unite = 'HAB_HIER' AND m4.mode = h.pmode
	left join metaifn.abgroupe g6 ON g6.unite = 'HAB_HIER' AND g6.gunite = 'RANG_HAB' AND h2.pmode = g6.mode
	left join metaifn.abmode m5 ON m5.unite = 'HAB_HIER' AND m5.mode = h2.pmode;
--------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- Version Cédric -----------------------------------------------------------------
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
, ghic.gmode AS hic_hab1, mhic.libelle AS lib_hic
, gcoi.gmode AS corine_ifn, mcoi.libelle AS lib_corine_ifn
, gcop.gmode AS corine_pvf2, mcop.libelle AS lib_corine_pvf2
FROM inv_exp_nm.e1point p1
INNER JOIN inv_exp_nm.g3habitat h USING (npp)
INNER JOIN metaifn.abgroupe ghic ON ghic.unite = 'HAB' AND ghic.gunite = 'HIC' AND ghic."mode" = h.hab
INNER JOIN metaifn.abmode mhic ON ghic.gunite = mhic.unite AND ghic.gmode = mhic."mode"
INNER JOIN metaifn.abgroupe gcoi ON gcoi.unite = 'HAB' AND gcoi.gunite = 'CORINE_IFN' AND gcoi."mode" = h.hab
INNER JOIN metaifn.abmode mcoi ON gcoi.gunite = mcoi.unite AND gcoi.gmode = mcoi."mode"
INNER JOIN metaifn.abgroupe gcop ON gcop.unite = 'HAB' AND gcop.gunite = 'CORINE_PVF2' AND gcop."mode" = h.hab
INNER JOIN metaifn.abmode mcop ON gcop.gunite = mcop.unite AND gcop.gmode = mcop."mode"
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
