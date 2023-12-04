-- CALCULS DE DONNÉES ARBRES
-- calcul du volume des arbres vifs
BEGIN;

CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a
, 13 AS incref
, CASE
    WHEN up.u_pro_psg = '1' THEN '1'
    WHEN up.u_pro_psg = '2' THEN '2'
    ELSE '3'
  END AS pf_maaf
, CASE
    WHEN zp <600 THEN '0'::CHAR(1)
    WHEN zp >= 600 THEN '1'::CHAR(1)
    END AS alt2
, CASE                      --> On attribue la greco I à l'essence 74 qui n'a pas de tarif en greco F
	WHEN ess = '74' THEN 'I' ELSE LEFT(ser_86, 1)	
	END AS greco
--, LEFT(ser_86, 1) AS greco
, g3a.ess, g3a.c13
, SUM(g3a.gtot * g3a.w) OVER (PARTITION BY g3a.npp) AS g
, NULL::FLOAT8 AS vest
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.e1point e1p ON e2p.npp = e1p.npp
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.npp = g3f.npp
INNER JOIN inv_exp_nm.g3arbre g3a ON g3f.npp = g3a.npp
INNER JOIN inv_exp_nm.u_e2point up ON e2p.npp = up.npp
WHERE g3a.npp LIKE '22PBA%'
and g3a.ess in ('49', '74')
ORDER BY npp, a;

ALTER TABLE arbres ADD CONSTRAINT pkarbre PRIMARY KEY (npp, a);
CREATE INDEX arbres_ess_idx ON arbres USING btree (ess);
ANALYZE arbres;

TABLE arbres;

----------------------------------------------------------------------------------------------------
CREATE TEMPORARY TABLE tarifs AS
SELECT DISTINCT TRIM(c.format) AS format, metaifn.mmfclasse(c.format) AS etendue, TRIM(c.ess) AS ess
, COALESCE(TRIM(ch.donnee), 'RIEN') AS donnee, COALESCE(ch.position, 0) AS position
, COALESCE(TRIM(d.unite), 'RIEN') AS unite
FROM prod_exp.c4tarifs t
INNER JOIN prod_exp.c4ctarif c USING (ntarif)
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif
LEFT JOIN metaifn.afchamp ch USING (format)
LEFT JOIN metaifn.addonnee d USING (donnee)
WHERE t.typtarif IN ('U1', 'U2')
AND a.incref = 13
and c.ess in ('49', '74')
ORDER BY TRIM(c.ess);

ALTER TABLE tarifs ADD CONSTRAINT pktarifs PRIMARY KEY (ess, position);
ANALYZE tarifs;

TABLE tarifs;

------------------------------------------------------------------------------
CREATE TEMPORARY TABLE unites AS
SELECT unite, mode, position
FROM metaifn.abmode
WHERE unite IN ('ALT2', 'PF_MAAF', 'GRECO')
ORDER BY unite, position;

ALTER TABLE unites ADD CONSTRAINT pkunites PRIMARY KEY (unite, mode);
ANALYZE unites;

TABLE unites;

----------------------------------------------------------------------------------
CREATE TEMPORARY TABLE regroup AS
SELECT a.npp, a.a, a.incref, a.alt2, a.pf_maaf, a.greco, a.ess, a.c13, a.g
, t0.format AS format, t0.etendue AS etendue
, CASE t0.etendue   WHEN 0 THEN 0 
                    WHEN 1 THEN metaifn.mmfdomaine1(t0.format, u0.position)
                    WHEN 2 THEN metaifn.mmfdomaine2(t0.format, u0.position, u1.position)
                    WHEN 3 THEN metaifn.mmfdomaine3(t0.format, u0.position, u1.position, u2.position)
  END AS domaine
FROM arbres a
INNER JOIN tarifs t0 ON a.ess = t0.ess AND t0.position = 0
LEFT JOIN unites u0 ON t0.unite = u0.unite AND CASE t0.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u0.mode
LEFT JOIN tarifs t1 ON a.ess = t1.ess AND t1.position = 1
LEFT JOIN unites u1 ON t1.unite = u1.unite AND CASE t1.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u1.mode
LEFT JOIN tarifs t2 ON a.ess = t2.ess AND t2.position = 2
LEFT JOIN unites u2 ON t2.unite = u2.unite AND CASE t2.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u2.mode
WHERE a.ess in ('45', '49', '74')
ORDER BY a.npp, a.a;

ALTER TABLE regroup ADD CONSTRAINT pkregroup PRIMARY KEY (npp, a);
ANALYZE regroup;

TABLE regroup;

-------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TEMP TABLE coefs AS
SELECT c1.ess, c1.format, c1.domaine, t.ntarif, t.typtarif
, COALESCE(c1.coeftarif, 0::FLOAT) AS alpha
, COALESCE(c2.coeftarif, 0::FLOAT) AS beta
, COALESCE(c3.coeftarif, 0::FLOAT) AS gamma
, COALESCE(c4.coeftarif, 0::FLOAT) AS delta
, COALESCE(c5.coeftarif, 0::FLOAT) AS zeta
, COALESCE(c6.coeftarif, 0::FLOAT) AS eta
, COALESCE(c7.coeftarif, 0::FLOAT) AS sigma
FROM prod_exp.c4tarifs t
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif
LEFT JOIN prod_exp.c4ctarif c1 ON t.ntarif = c1.ntarif AND c1.nctarif = 1
LEFT JOIN prod_exp.c4ctarif c2 ON t.ntarif = c2.ntarif AND c2.nctarif = 2
LEFT JOIN prod_exp.c4ctarif c3 ON t.ntarif = c3.ntarif AND c3.nctarif = 3
LEFT JOIN prod_exp.c4ctarif c4 ON t.ntarif = c4.ntarif AND c4.nctarif = 4
LEFT JOIN prod_exp.c4ctarif c5 ON t.ntarif = c5.ntarif AND c5.nctarif = 5
LEFT JOIN prod_exp.c4ctarif c6 ON t.ntarif = c6.ntarif AND c6.nctarif = 6
LEFT JOIN prod_exp.c4ctarif c7 ON t.ntarif = c7.ntarif AND c7.nctarif = 7
WHERE t.typtarif IN ('U1', 'U2')
AND c1.ess IN ('49', '74')
AND a.incref = 13
ORDER BY c1.ess, c1.format, c1.domaine, t.ntarif;

ALTER TABLE coefs ADD CONSTRAINT pkcoefs PRIMARY KEY (ntarif);
ANALYZE coefs;

TABLE coefs;

--------------------------------------------------------------------------------------------------------------------------------------
CREATE TEMPORARY TABLE vols AS
SELECT g.npp, g.a, g.incref, g.ess, g.alt2, g.pf_maaf, g.greco
, EXP(
    c.alpha
    + c.beta * LN(g.c13)
    + c.gamma * (LN(g.c13))^2
    + c.delta * (LN(g.c13))^3
    + c.zeta * (LN(g.c13))^4
    + c.eta * LN(g.g)
    + c.sigma^2 / 2
) AS v13
FROM regroup g
INNER JOIN coefs c ON g.ess = c.ess AND g.format = c.format AND g.domaine = c.domaine
WHERE c.typtarif = 'U1'
--and g.ess in ('45', '49', '74')
UNION ALL
SELECT g.npp, g.a, g.incref, g.ess, g.alt2, g.pf_maaf, g.greco
, EXP(
    c.alpha
    + c.beta * LN(g.c13)
    + c.gamma * (LN(g.c13))^2
    + c.delta * (LN(g.c13))^3
    + c.zeta * (LN(g.c13))^4
    + c.eta * g.g
    + c.sigma^2 / 2
) AS v13
FROM regroup g
INNER JOIN coefs c ON g.ess = c.ess AND g.format = c.format AND g.domaine = c.domaine
WHERE c.typtarif = 'U2'
--and g.ess in ('45', '49', '74')
;

ALTER TABLE vols ADD CONSTRAINT pkvols PRIMARY KEY (npp, a);
ANALYZE vols;

TABLE vols;

----------------------------------------------------------------------------------------------------
UPDATE arbres a
SET vest = v.v13
FROM vols v
WHERE a.npp = v.npp AND a.a = v.a;

SELECT  *
FROM arbres;

COMMIT;

DROP TABLE arbres;
DROP TABLE tarifs;
DROP TABLE unites;
DROP TABLE regroup;
DROP TABLE coefs;
DROP TABLE vols;
