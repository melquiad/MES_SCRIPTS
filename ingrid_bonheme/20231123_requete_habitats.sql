--0/ Sortie des points habitats HIC pour les occurrences par HIC pour la carte par maille pour INPN
-- Toutes campagnes disponibles au 23/11/2023
-- Selection sur la vue habitats
SELECT p1.npp, p1.idp, p2.ser_86, uep.u_biogeo2002, p1.incref + 2005 as campagne, g1.gmode AS hic_1, hab.hab1,  g2.gmode AS hic_2, hab.hab2, g3.gmode AS hic_3, hab.hab3, cp.xl93, cp.yl93
FROM inv_exp_nm.e1point AS p1 
INNER JOIN inv_exp_nm.habitats AS hab ON p1.npp = hab.npp --sélection sur la vue habitats
left JOIN inv_exp_nm.e1point_coord_l2_l93 AS cp ON p1.npp = cp.npp
left join inv_exp_nm.u_e2point uep on uep.npp = p1.npp
left join inv_exp_nm.e2point p2 on p2.npp = p1.npp 
left JOIN metaifn.abgroupe g1 ON g1.gunite = 'HIC' AND g1.unite = 'HAB' AND hab.hab1 = g1.mode
left JOIN metaifn.abgroupe g2 ON g2.gunite = 'HIC' AND g2.unite = 'HAB' AND hab.hab2 = g2.mode
left JOIN metaifn.abgroupe g3 ON g3.gunite = 'HIC' AND g3.unite = 'HAB' AND hab.hab3 = g3.mode;

-- selection depuis la table g3habitat
SELECT p1.npp, p1.idp, p2.ser_86, uep.u_biogeo2002, p1.incref + 2005 as campagne, g1.gmode AS hic_1, g1.mode as hab1,  g2.gmode AS hic_2, g2.mode as hab2, g3.gmode AS hic_3, g3.mode as hab3, cp.xl93, cp.yl93
FROM inv_exp_nm.e1point AS p1 
INNER JOIN inv_exp_nm.g3habitat AS hab ON p1.npp = hab.npp --sélection sur la table g3habitat
left JOIN inv_exp_nm.e1point_coord_l2_l93 AS cp ON p1.npp = cp.npp
left join inv_exp_nm.u_e2point uep on uep.npp = p1.npp
left join inv_exp_nm.e2point p2 on p2.npp = p1.npp 
left JOIN metaifn.abgroupe g1 ON g1.gunite = 'HIC' AND g1.unite = 'HAB' and num_hab = 1 AND hab.hab = g1.mode
left JOIN metaifn.abgroupe g2 ON g2.gunite = 'HIC' AND g2.unite = 'HAB' and num_hab = 2 AND hab.hab = g2.mode
left JOIN metaifn.abgroupe g3 ON g3.gunite = 'HIC' AND g3.unite = 'HAB' and num_hab = 3 AND hab.hab = g3.mode;


     
    
    
    
    
    
    