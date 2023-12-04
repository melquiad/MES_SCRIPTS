-- inv_prod_new.v_liste_points_lt1 source

CREATE OR REPLACE VIEW inv_prod_new.v_liste_points_lt1
AS SELECT c.millesime AS annee,
    p.npp,
    p.nph,
    pl.id_ech,
    pl.id_point
   FROM campagne c
     JOIN echantillon e USING (id_campagne)
     JOIN point_lt pl USING (id_ech)
     JOIN point p USING (id_point)
  WHERE e.phase_stat = 2 AND e.type_ech::text = 'IFN'::character varying::text AND e.type_ue = 'P'::bpchar AND e.ech_parent IS NULL
   AND NOT (EXISTS ( SELECT p.id_point FROM point_lt pl2 WHERE pl2.id_point = pl.id_point AND pl2.id_ech < pl.id_ech));
-------------------------------------------------------------------------------------------------------------------------------------   
-- inv_prod_new.v_liste_points_lt1_pi2 source

CREATE OR REPLACE VIEW inv_prod_new.v_liste_points_lt1_pi2
AS SELECT c.millesime AS annee,
    p.npp,
    replace(p.npp::text, 'T'::text, 'R'::text) AS nppr,
    p.nph,
    pl.id_ech,
    pl.id_point
   FROM campagne c
     JOIN echantillon e USING (id_campagne)
     JOIN point_lt pl USING (id_ech)
     JOIN point p USING (id_point)
  WHERE e.phase_stat = 2 AND e.type_ech::text = 'IFN'::character varying::text AND e.type_ue = 'P'::bpchar AND e.ech_parent IS NOT NULL
   AND NOT (EXISTS ( SELECT p.id_point FROM point_lt pl2 WHERE pl2.id_point = pl.id_point AND pl2.id_ech < pl.id_ech));
-------------------------------------------------------------------------------------------------------------------------------------
-- inv_prod_new.v_liste_points_lt2 source

CREATE OR REPLACE VIEW inv_prod_new.v_liste_points_lt2
AS SELECT c.millesime AS annee,
    p.npp,
    p.nph,
    pl.id_ech,
    pl.id_point
   FROM campagne c
     JOIN echantillon e USING (id_campagne)
     JOIN point_lt pl USING (id_ech)
     JOIN point p USING (id_point)
  WHERE e.phase_stat = 2 AND e.type_ech::text = 'IFN'::character varying::text AND e.type_ue = 'P'::bpchar AND e.stat = true 
   AND e.ech_parent IS NOT NULL AND (EXISTS ( SELECT p.id_point FROM point_lt pl2 WHERE pl2.id_point = pl.id_point AND pl2.id_ech < pl.id_ech));
-----------------------------------------------------------------------------------------------------------------------------------------
-- inv_prod_new.v_liste_points_pi1 source

CREATE OR REPLACE VIEW inv_prod_new.v_liste_points_pi1
AS SELECT c.millesime AS annee,
    p.npp,
    pe.zp,
    st_x(p.geom) AS xl93,
    st_y(p.geom) AS yl93,
    pp.id_ech,
    pp.id_point,
    t.aztrans,
    round(st_length(t.geom)) AS longueur
   FROM campagne c
     JOIN echantillon e USING (id_campagne)
     JOIN point_ech pe USING (id_ech)
     JOIN point p USING (id_point)
     JOIN point_pi pp USING (id_ech, id_point)
     LEFT JOIN transect t USING (id_transect)
  WHERE e.phase_stat = 1 AND e.type_ech::text = 'IFN'::character varying::text AND e.type_ue = 'P'::bpchar AND e.ech_parent IS NULL;
-----------------------------------------------------------------------------------------------------------------------------------------
-- inv_prod_new.v_liste_points_pi2 source

CREATE OR REPLACE VIEW inv_prod_new.v_liste_points_pi2
AS SELECT c.millesime AS annee,
    replace(p.npp::text, 'T'::text, 'R'::text) AS npp,
    pe.zp,
    st_x(p.geom) AS xl93,
    st_y(p.geom) AS yl93,
    pp.id_ech,
    pp.id_point,
    cp.millesime AS annee_pi1,
    ppp.datephoto AS datephoto1
   FROM campagne c
     JOIN echantillon e USING (id_campagne)
     JOIN point_ech pe USING (id_ech)
     JOIN point p USING (id_point)
     JOIN point_pi pp USING (id_ech, id_point)
     JOIN echantillon ep ON e.ech_parent = ep.id_ech
     JOIN campagne cp ON ep.id_campagne = cp.id_campagne
     JOIN point_ech pep ON ep.id_ech = pep.id_ech AND pp.id_point = pep.id_point
     JOIN point_pi ppp ON pep.id_ech = ppp.id_ech AND pep.id_point = ppp.id_point
  WHERE e.phase_stat = 1 AND e.type_ech::text = 'IFN'::character varying::text AND e.type_ue = 'P'::bpchar;
  
  
  
