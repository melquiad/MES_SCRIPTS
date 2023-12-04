-- en forêt
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, pe.dep
, r.csa
, r15.utip, r15.bois, r15.tform
, d1.gest
, d1.dist
, d1.iti
, d1.pentexp
, d1.portance
, d1.asperite
, ue2p.u_pro_psg
, ue2p.u_ex_ap_uicn
, g3f.expl
--, p3p.expl
, st_x(m.geom)
, st_y(m.geom)
, '1' AS visite
, '1' AS passage
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN inv_exp_nm.u_e2point ue2p ON p.npp = ue2p.npp
--INNER JOIN inv_exp_nm.e2point e2p ON p.npp = e2p.npp
INNER JOIN inv_exp_nm.g3foret g3f ON p.npp = g3f.npp
--INNER JOIN inv_exp_nm.p3point p3p ON p.npp = p3p.npp
INNER JOIN maille m USING (id_maille)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN reco_2005 r5 USING (id_ech, id_point)
LEFT JOIN reco_2015 r15 USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
WHERE c.millesime BETWEEN 2018 and 2022
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 1
AND p.idp IS NOT NULL
--ORDER BY 1, 2
UNION
SELECT c.millesime AS campagne
, p.idp::INT4 AS idp
, pe.dep
, r.csa
, r15.utip, r15.bois, r15.tform
, d1.gest
, d1.dist
, d1.iti
, d1.pentexp
, d1.portance
, d1.asperite
, ue2p.u_pro_psg
, ue2p.u_ex_ap_uicn
--, g3f.expl
, p3p.expl
, st_x(m.geom)
, st_y(m.geom)
, '1' AS visite
, '1' AS passage
FROM campagne c
INNER JOIN echantillon e USING (id_campagne)
INNER JOIN point_ech pe USING (id_ech)
INNER JOIN point p USING (id_point)
INNER JOIN inv_exp_nm.u_e2point ue2p ON p.npp = ue2p.npp
--INNER JOIN inv_exp_nm.e2point e2p ON p.npp = e2p.npp
--INNER JOIN inv_exp_nm.g3foret g3f ON p.npp = g3f.npp
INNER JOIN inv_exp_nm.p3point p3p ON p.npp = p3p.npp
INNER JOIN maille m USING (id_maille)
INNER JOIN reconnaissance r USING (id_ech, id_point)
INNER JOIN description d USING (id_ech, id_point)
LEFT JOIN reco_2005 r5 USING (id_ech, id_point)
LEFT JOIN reco_2015 r15 USING (id_ech, id_point)
LEFT JOIN descript_m1 d1 USING (id_ech, id_point)
WHERE c.millesime BETWEEN 2018 and 2022
AND e.type_ech = 'IFN'
AND e.type_ue = 'P'
AND e.phase_stat = 2
AND e.passage = 1
AND p.idp IS NOT NULL
ORDER BY 1, 2;




