

-- via DuckDB
LOAD postgres;


ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg1 (TYPE postgres);

SELECT npp, u_apb
FROM pg.inv_exp_nm.u_e2point
EXCEPT
SELECT npp, u_apb
FROM pg1.inv_exp_nm.u_e2point; --> pas de différences

SELECT npp, u_biogeo2002
FROM pg.inv_exp_nm.u_e2point
EXCEPT
SELECT npp, u_biogeo2002
FROM pg1.inv_exp_nm.u_e2point; --> pas de différences

SELECT npp, u_res_bio
FROM pg.inv_exp_nm.u_e2point
EXCEPT
SELECT npp, u_res_bio
FROM pg1.inv_exp_nm.u_e2point; --> pas de différences

SELECT npp, u_zico
FROM pg.inv_exp_nm.u_e2point
EXCEPT
SELECT npp, u_zico
FROM pg1.inv_exp_nm.u_e2point; --> pas de différences

SELECT npp, u_quad16_dsf
FROM pg.inv_exp_nm.u_e2point
EXCEPT
SELECT npp, u_quad16_dsf
FROM pg1.inv_exp_nm.u_e2point; --> pas de différences
---------------------------------------------------------

SELECT npp, u_comp_idreg
FROM pg.inv_exp_nm.u_g3foret
EXCEPT
SELECT npp, u_comp_idreg
FROM pg1.inv_exp_nm.u_g3foret; --> pas de différences

SELECT npp, u_comp_idreg
FROM pg.inv_exp_nm.u_p3point
EXCEPT
SELECT npp, u_comp_idreg
FROM pg1.inv_exp_nm.u_p3point; --> pas de différences
-----------------------------------------------------------

SELECT npp, u_rut_af
FROM pg.inv_exp_nm.u_g3foret
EXCEPT
SELECT npp, u_rut_af
FROM pg1.inv_exp_nm.u_g3foret; --> pas de différences

SELECT npp, u_rut_af
FROM pg.inv_exp_nm.u_p3point
EXCEPT
SELECT npp, u_rut_af
FROM pg1.inv_exp_nm.u_p3point; --> pas de différences
------------------------------------------------------

SELECT npp, count(u_ru_af)
FROM pg.inv_exp_nm.u_g3foret
GROUP BY npp
EXCEPT
SELECT npp, count(u_ru_af)
FROM pg1.inv_exp_nm.u_g3foret
GROUP BY npp; 					--> pas de différences en nb

SELECT npp, count(u_ru_af)
FROM pg.inv_exp_nm.u_p3point
GROUP BY npp
EXCEPT
SELECT npp, count(u_ru_af)
FROM pg1.inv_exp_nm.u_p3point
GROUP BY npp; 					--> pas de différences en nb

WITH sel1 AS (
SELECT npp, u_ru_af
FROM pg.inv_exp_nm.u_g3foret
--WHERE incref=19
)
, sel2 AS (
SELECT npp, u_ru_af
FROM pg1.inv_exp_nm.u_g3foret
--WHERE incref=19
)
SELECT abs(sel1.u_ru_af-sel2.u_ru_af)
FROM sel1
INNER JOIN sel2 USING (npp)
WHERE abs(sel1.u_ru_af-sel2.u_ru_af) > power(10,-5);
----------------------------------------------------------

SELECT npp, u_tgb_onb
FROM pg.inv_exp_nm.u_g3arbre
EXCEPT
SELECT npp, u_tgb_onb
FROM pg1.inv_exp_nm.u_g3arbre; --> pas de différences
-------------------------------------

SELECT npp, abs(sum(u_carb_ar))
FROM pg.inv_exp_nm.u_g3arbre
GROUP BY npp
EXCEPT
SELECT npp, abs(sum(u_carb_ar))
FROM pg1.inv_exp_nm.u_g3arbre --> pas de différences en nb
GROUP BY npp;

SELECT npp, abs(sum(u_carb_ar))
FROM pg.inv_exp_nm.u_p3arbre
GROUP BY npp
EXCEPT
SELECT npp, abs(sum(u_carb_ar))
FROM pg1.inv_exp_nm.u_p3arbre --> pas de différences en nb
GROUP BY npp;

WITH sel1 AS (
SELECT npp, a, u_carb_ar
FROM pg.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
, sel2 AS (
SELECT npp, a, u_carb_ar
FROM pg1.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
SELECT abs(sel1.u_carb_ar-sel2.u_carb_ar)
FROM sel1
INNER JOIN sel2 USING (npp, a)
WHERE abs(sel1.u_carb_ar-sel2.u_carb_ar) > power(10,-5);

-----------------------------------------------------------
SELECT npp, count(u_biom_ar)
FROM pg.inv_exp_nm.u_g3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_biom_ar)
FROM pg1.inv_exp_nm.u_g3arbre --> pas de différences en nb
GROUP BY npp;

SELECT npp, count(u_biom_ar)
FROM pg.inv_exp_nm.u_p3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_biom_ar)
FROM pg1.inv_exp_nm.u_p3arbre --> pas de différences en nb
GROUP BY npp;

WITH sel1 AS (
SELECT npp, a, u_biom_ar
FROM pg.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
, sel2 AS (
SELECT npp, a, u_biom_ar
FROM pg1.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
SELECT abs(sel1.u_biom_ar-sel2.u_biom_ar)
FROM sel1
INNER JOIN sel2 USING (npp, a)
WHERE abs(sel1.u_biom_ar-sel2.u_biom_ar) > power(10,-5);

-----------------------------------------------------------------
SELECT npp, count(u_pv0pr)
FROM pg.inv_exp_nm.u_g3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_pv0pr)
FROM pg1.inv_exp_nm.u_g3arbre --> pas de différences en nb
GROUP BY npp;

SELECT npp, count(u_pv0pr)
FROM pg.inv_exp_nm.u_p3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_pv0pr)
FROM pg1.inv_exp_nm.u_p3arbre --> pas de différences en nb
GROUP BY npp;

WITH sel1 AS (
SELECT npp, a, u_pv0pr
FROM pg.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
, sel2 AS (
SELECT npp, a, u_pv0pr
FROM pg1.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
SELECT abs(sel1.u_pv0pr-sel2.u_pv0pr)
FROM sel1
INNER JOIN sel2 USING (npp, a)
WHERE abs(sel1.u_pv0pr-sel2.u_pv0pr) > power(10,-5);

-----------------------------------------------------------------
SELECT npp, count(u_pv0)
FROM pg.inv_exp_nm.u_g3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_pv0)
FROM pg1.inv_exp_nm.u_g3arbre --> pas de différences en nb
GROUP BY npp;

SELECT npp, count(u_pv0)
FROM pg.inv_exp_nm.u_p3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_pv0)
FROM pg1.inv_exp_nm.u_p3arbre --> pas de différences en nb
GROUP BY npp;

WITH sel1 AS (
SELECT npp, a, u_pv0
FROM pg.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
, sel2 AS (
SELECT npp, a, u_pv0
FROM pg1.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
SELECT abs(sel1.u_pv0-sel2.u_pv0)
FROM sel1
INNER JOIN sel2 USING (npp, a)
WHERE abs(sel1.u_pv0-sel2.u_pv0) > power(10,-5);

--------------------------------------------------------
SELECT npp, count(u_v0)
FROM pg.inv_exp_nm.u_g3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_v0)
FROM pg1.inv_exp_nm.u_g3arbre --> pas de différences en nb
GROUP BY npp;

SELECT npp, count(u_v0)
FROM pg.inv_exp_nm.u_p3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_v0)
FROM pg1.inv_exp_nm.u_p3arbre --> pas de différences en nb
GROUP BY npp;

WITH sel1 AS (
SELECT npp, a, u_v0
FROM pg.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
, sel2 AS (
SELECT npp, a, u_v0
FROM pg1.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
SELECT abs(sel1.u_v0-sel2.u_v0)
FROM sel1
INNER JOIN sel2 USING (npp, a)
WHERE abs(sel1.u_v0-sel2.u_v0) > power(10,-5);
-------------------------------------------------------------------------

SELECT npp, u_diam_moy, count(u_diam_moy)
FROM pg.inv_exp_nm.u_g3foret
GROUP BY npp, u_diam_moy
EXCEPT
SELECT npp, u_diam_moy, count(u_diam_moy)
FROM pg1.inv_exp_nm.u_g3foret
GROUP BY npp, u_diam_moy; 					--> pas de différences

--------------------------------------------------------------------------
SELECT npp, count(u_v0pr_an_ac)
FROM pg.inv_exp_nm.u_g3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_v0pr_an_ac)
FROM pg1.inv_exp_nm.u_g3arbre --> pas de différences en nb
GROUP BY npp;

SELECT npp, count(u_v0pr_an_ac)
FROM pg.inv_exp_nm.u_p3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_v0pr_an_ac)
FROM pg1.inv_exp_nm.u_p3arbre --> pas de différences en nb
GROUP BY npp;

WITH sel1 AS (
SELECT npp, a, u_v0pr_an_ac
FROM pg.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
, sel2 AS (
SELECT npp, a, u_v0pr_an_ac
FROM pg1.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
SELECT abs(sel1.u_v0pr_an_ac-sel2.u_v0pr_an_ac)
FROM sel1
INNER JOIN sel2 USING (npp, a)
WHERE abs(sel1.u_v0pr_an_ac-sel2.u_v0pr_an_ac) > power(10,-5);
-------------------------------------------------------------------------

SELECT npp, count(u_v0pr_an)
FROM pg.inv_exp_nm.u_g3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_v0pr_an)
FROM pg1.inv_exp_nm.u_g3arbre --> pas de différences en nb
GROUP BY npp;

SELECT npp, count(u_v0pr_an)
FROM pg.inv_exp_nm.u_p3arbre
GROUP BY npp
EXCEPT
SELECT npp, count(u_v0pr_an)
FROM pg1.inv_exp_nm.u_p3arbre --> pas de différences en nb
GROUP BY npp;

WITH sel1 AS (
SELECT npp, a, u_v0pr_an
FROM pg.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
, sel2 AS (
SELECT npp, a, u_v0pr_an
FROM pg1.inv_exp_nm.u_g3arbre
--WHERE incref=19
)
SELECT abs(sel1.u_v0pr_an-sel2.u_v0pr_an)
FROM sel1
INNER JOIN sel2 USING (npp, a)
WHERE abs(sel1.u_v0pr_an-sel2.u_v0pr_an) > power(10,-5);
-------------------------------------------------------------------------

























