
-- via DuckDB
LOAD postgres;

ATTACH 'host=restaure-prod.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg1 (TYPE postgres);
ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg1 (TYPE postgres);
--ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg1 (TYPE postgres);

INSERT INTO pg1.metaifn.abunite
SELECT * 
FROM pg.metaifn.abunite u
WHERE unite IN ('U_APB','U_RES_BIO','U_QUAD','U_ZICO')
ORDER BY u.unite;

INSERT INTO pg1.metaifn.abmode
SELECT * 
FROM pg.metaifn.abmode m
WHERE unite IN ('U_APB','U_RES_BIO','U_QUAD','U_ZICO')
ORDER BY m.unite;

INSERT INTO pg1.metaifn.addonnee
SELECT * 
FROM pg.metaifn.addonnee d
WHERE donnee IN ( 'U_APB','U_BIOGEO2002','U_RES_BIO','U_ZICO','U_QUAD16_DSF') 
ORDER BY d.donnee;

INSERT INTO pg1.metaifn.afchamp
SELECT * 
FROM pg.metaifn.afchamp f
WHERE donnee IN ( 'U_APB','U_BIOGEO2002','U_RES_BIO','U_ZICO','U_QUAD16_DSF') 
ORDER BY f.donnee;

----------------------------------------------------------------------------------
-- L'unite de U_PV0PR est le m3/an

INSERT INTO pg1.metaifn.addonnee
SELECT * 
FROM pg.metaifn.addonnee d
WHERE donnee IN ( 'U_PV0PR') 
ORDER BY d.donnee;

INSERT INTO pg1.metaifn.afchamp
SELECT * 
FROM pg.metaifn.afchamp f
WHERE donnee IN ( 'U_PV0PR')
ORDER BY f.donnee;


