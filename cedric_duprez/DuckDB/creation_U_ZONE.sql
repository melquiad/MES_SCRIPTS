-- Dans PostgreSQL
ALTER TABLE inv_exp_nm.u_e2point
    ADD COLUMN u_haie CHAR(1);

-- via DuckDB
LOAD postgres;

ATTACH 'host=test-inv-exp.ign.fr port=5432 user=CDuprez dbname=exploitation' AS pg (TYPE postgres);

UPDATE pg.inv_exp_nm.u_e2point p2
SET u_haie = h.u_haie::char(1)
FROM read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Gohon/u_haie.csv') h
WHERE p2.npp = h.npp;

SELECT count(*) FROM read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Gohon/u_haie.csv');
SELECT count(*) FROM read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Gohon/u_haie2.csv');

SELECT count(DISTINCT npp) FROM  read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Gohon/u_haie.csv');
SELECT count(DISTINCT npp) FROM  read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Gohon/u_haie2.csv');

-- Dans PostgreSQL
SELECT * FROM metaifn.ajoutdonnee('U_HAIE', NULL, 'U_HAIE', 'AUTRE', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, $$Présence de haie$$, $$Point situé sur une haie$$);
SELECT * FROM metaifn.ajoutchamp('U_HAIE', 'U_E2POINT', 'INV_EXP_NM', FALSE, 9, NULL, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 9, calcout = 18, validin = 9, validout = 18
WHERE famille = 'INV_EXP_NM'
AND donnee = 'U_HAIE';

INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee)
VALUES ('IFN', 'U_HAIE');
