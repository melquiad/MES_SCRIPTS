BEGIN;

UPDATE inv_exp_nm.g3foret
SET tplantr = CASE WHEN tplant = 'Q' THEN 'P' ELSE tplant END
WHERE incref = 19;

UPDATE inv_exp_nm.p3point
SET tplantr = CASE WHEN tplant = 'Q' THEN 'P' ELSE tplant END
WHERE incref = 19;

-- regroupements dans G3ECOLOGIE
UPDATE inv_exp_nm.g3ecologie
SET humusg1 = g1.gmode
FROM metaifn.abgroupe g1
WHERE g1.unite = 'HUMUS22' AND g1.mode = humus AND g1.gunite = 'HUMUSD1'
AND incref = 19;

-- mise à jour préalable de TSOL NULL => 99 (et on rattrape 2016)
UPDATE inv_exp_nm.g3ecologie
SET tsol = '99'
WHERE tsol IS NULL
AND incref = 19;

UPDATE inv_exp_nm.g3ecologie
SET tsolg1 = g2.gmode
FROM metaifn.abgroupe g2
WHERE g2.unite = 'TSOL22' AND g2.mode = tsol AND g2.gunite = 'TSOLD1'
AND incref = 19;

UPDATE inv_exp_nm.g3ecologie
SET rocheg1 = g2.gmode
FROM metaifn.abgroupe g2
WHERE g2.unite = 'ROCHED0' AND g2.mode = roche AND g2.gunite = 'ROCHED1'
AND incref = 19;

UPDATE inv_exp_nm.g3ecologie
SET topog1 = g3.gmode
FROM metaifn.abgroupe g3
WHERE g3.unite = 'TOPO' AND g3.gunite = 'TOPOD1' AND g3.mode = topo
AND incref = 19;

-- classe de pente écologique
UPDATE inv_exp_nm.g3foret
SET clg_nm = 
CASE
	WHEN e.pent2 IS NULL THEN NULL
	WHEN e.pent2 < 5 THEN '1'
	WHEN e.pent2 < 15 THEN '2'
	WHEN e.pent2 < 30 THEN '3'
	WHEN e.pent2 < 50 THEN '4'
	ELSE '5'
END
FROM inv_exp_nm.g3ecologie e
WHERE e.npp = g3foret.npp
AND g3foret.incref = 19;

-- regroupement des départements de noeuds
UPDATE inv_exp_nm.e1noeud
SET depp = g.gmode
FROM metaifn.abgroupe g
WHERE g.unite = 'DP' AND g.gunite = 'DPD4'
AND e1noeud.depp = g.mode
AND e1noeud.incref = 19;

COMMIT;

VACUUM ANALYZE inv_exp_nm.g3foret;
VACUUM ANALYZE inv_exp_nm.p3point;
VACUUM ANALYZE inv_exp_nm.g3ecologie;
VACUUM ANALYZE inv_exp_nm.e1noeud;


-- ajout des regroupements dans P3ECOLOGIE
/*
ALTER TABLE inv_exp_nm.p3ecologie ADD COLUMN humusg1 char(1);
*/
--SELECT * FROM metaifn.ajoutchamp('humusg1', 'p3ecologie', 'inv_exp_nm', false, 11, null, 'bpchar', 1);

-- regroupements dans P3ECOLOGIE
UPDATE inv_exp_nm.p3ecologie
SET humusg1 = g1.gmode
FROM metaifn.abgroupe g1
WHERE g1.unite = 'HUMUS22' AND g1.mode = humus AND g1.gunite = 'HUMUSD1'
AND incref = 19;

-- mise à jour préalable de TSOL NULL => 99 (et on rattrape 2016)
UPDATE inv_exp_nm.p3ecologie
SET tsol = '99'
WHERE tsol IS NULL
AND incref = 19;

UPDATE inv_exp_nm.p3ecologie
SET tsolg1 = g2.gmode
FROM metaifn.abgroupe g2
WHERE g2.unite = 'TSOL22' AND g2.mode = tsol AND g2.gunite = 'TSOLD1'
AND incref = 19;

UPDATE inv_exp_nm.p3ecologie
SET rocheg1 = g2.gmode
FROM metaifn.abgroupe g2
WHERE g2.unite = 'ROCHED0' AND g2.mode = roche AND g2.gunite = 'ROCHED1'
AND incref = 19;

UPDATE inv_exp_nm.p3ecologie
SET topog1 = g3.gmode
FROM metaifn.abgroupe g3
WHERE g3.unite = 'TOPO' AND g3.gunite = 'TOPOD1' AND g3.mode = topo
AND incref = 19;


VACUUM ANALYZE inv_exp_nm.p3ecologie;

