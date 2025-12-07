
ALTER TABLE inv_exp_nm.u_e2point ADD COLUMN u_apb bpchar(1);
ALTER TABLE inv_exp_nm.u_e2point ADD COLUMN u_biogeo2002 bpchar(1);
ALTER TABLE inv_exp_nm.u_e2point ADD COLUMN u_res_bio bpchar(1);
ALTER TABLE inv_exp_nm.u_e2point ADD COLUMN u_zico bpchar(1);
ALTER TABLE inv_exp_nm.u_e2point ADD COLUMN u_quad16_dsf bpchar(9);

------------------------------------------------------------------------------------------
-- via DuckDB
LOAD postgres;

ATTACH 'host=restaure-prod.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg1 (TYPE postgres);
--ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg1 (TYPE postgres);
ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg1 (TYPE postgres);

SELECT npp, u_apb, u_biogeo2002, u_res_bio, u_zico, u_quad16_dsf
FROM pg.inv_exp_nm.u_e2point;

UPDATE pg1.inv_exp_nm.u_e2point r
SET u_apb = rp.u_apb, u_biogeo2002 = rp.u_biogeo2002, u_res_bio = rp.u_res_bio, u_zico = rp.u_zico, u_quad16_dsf = rp.u_quad16_dsf
FROM pg.inv_exp_nm.u_e2point rp
WHERE rp.npp = r.npp;
/**********/
SELECT npp, u_pv0pr
FROM pg.inv_exp_nm.u_g3arbre
WHERE incref = 19;

SELECT npp, u_pv0pr
FROM pg.inv_exp_nm.u_p3arbre;

UPDATE pg1.inv_exp_nm.u_g3arbre r
SET u_pv0pr = rp.u_pv0pr
FROM pg.inv_exp_nm.u_g3arbre rp
WHERE rp.npp = r.npp
AND rp.a = r.a;

UPDATE pg1.inv_exp_nm.u_p3arbre r
SET u_pv0pr = rp.u_pv0pr
FROM pg.inv_exp_nm.u_p3arbre rp
WHERE rp.npp = r.npp
AND rp.a = r.a;

--------------------------------------------------------------------------------------
-- contrôles
SELECT incref, u_apb, count(u_apb)
FROM inv_exp_nm.u_e2point
GROUP BY incref, u_apb
ORDER BY incref DESC;

SELECT incref, u_biogeo2002, count(u_biogeo2002)
FROM inv_exp_nm.u_e2point
GROUP BY incref, u_biogeo2002
ORDER BY incref DESC;

SELECT incref, u_res_bio, count(u_res_bio)
FROM inv_exp_nm.u_e2point
GROUP BY incref, u_res_bio
ORDER BY incref DESC;

SELECT incref, u_zico, count(u_zico)
FROM inv_exp_nm.u_e2point
GROUP BY incref, u_zico
ORDER BY incref DESC;

SELECT incref, count(u_quad16_dsf)
FROM inv_exp_nm.u_e2point
GROUP BY incref
ORDER BY incref DESC;
/***********/
SELECT incref, npp, count(u_pv0pr), sum(u_pv0pr)
FROM inv_exp_nm.u_g3arbre
WHERE incref = 14
GROUP BY npp, incref
ORDER BY npp DESC;

SELECT incref, npp, count(u_pv0pr), sum(u_pv0pr)
FROM inv_exp_nm.u_p3arbre
WHERE incref = 14
GROUP BY npp, incref
ORDER BY npp DESC;





