BEGIN;

INSERT INTO inv_exp_nm.u_e2point (npp, cyc, incref)
SELECT npp, cyc, incref
FROM inv_exp_nm.e2point
WHERE incref = 19;

INSERT INTO inv_exp_nm.u_g3foret (npp, cyc, incref)
SELECT npp, cyc, incref
FROM inv_exp_nm.g3foret
WHERE incref = 19;

INSERT INTO inv_exp_nm.u_p3point (npp, cyc, incref)
SELECT npp, cyc, incref
FROM inv_exp_nm.p3point
WHERE incref = 19;

INSERT INTO inv_exp_nm.u_g3arbre (npp, a, cyc, incref)
SELECT npp, a, cyc, incref
FROM inv_exp_nm.g3arbre
WHERE incref = 19;

INSERT INTO inv_exp_nm.u_p3arbre (npp, a, cyc, incref)
SELECT npp, a, cyc, incref
FROM inv_exp_nm.p3arbre
WHERE incref = 19;

INSERT INTO inv_exp_nm.u_g3morts (npp, a, cyc, incref)
SELECT npp, a, cyc, incref
FROM inv_exp_nm.g3morts
WHERE incref = 19;

INSERT INTO inv_exp_nm.u_p3morts (npp, a, cyc, incref)
SELECT npp, a, cyc, incref
FROM inv_exp_nm.p3morts
WHERE incref = 19;

COMMIT;

ANALYZE inv_exp_nm.u_e2point;
ANALYZE inv_exp_nm.u_g3foret;
ANALYZE inv_exp_nm.u_p3point;
ANALYZE inv_exp_nm.u_g3arbre;
ANALYZE inv_exp_nm.u_p3arbre;
ANALYZE inv_exp_nm.u_g3morts;
ANALYZE inv_exp_nm.u_p3morts;





