LOAD postgres;

ATTACH 'host=localhost port=5433 user=lhaugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=inv-bdd-dev.ign.fr port=5432 user=haugomat dbname=inventaire' AS pg (TYPE postgres);
--ATTACH 'host=test-inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);
--ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg (TYPE postgres);

-- Liste des tables à exclure des contrôles
CREATE TABLE liste_exclusions AS 
SELECT UNNEST([
    'e1coord', 'e1noeud', 'e1point', 'echantillon', 'famille_echantillon', 'famille_stratification'
--    , 'g3arbre_coord', 'g3bille', 'g3complete', 'g3essence', 'g3flore', 'g3habitat', 'g3plant', 'g3schmitt', 'g3souche', 'g3strate'
    , 'l1intersect', 'l1transect', 'l2segment', 'l3arbre', 'l3bille', 'l3complete', 'l3etage', 'l3flore', 'l3niveau', 'l3pressler', 'l3schmitt', 'l3segment'
--    , 'p3agedom', 'p3bille', 'p3complete', 'p3ecologie', 'p3essence', 'p3flore', 'p3plant', 'p3pressler', 'p3schmitt', 'p3strate'
    , 'point_aurelhy', 's5strate', 's5stratech', 's5stratif', 's5var', 'unite_ech'
--    , 'u_e2point', 'u_g3foret', 'u_p3point', 'u_g3arbre', 'u_p3arbre', 'u_g3morts', 'u_p3morts'
]) AS nom_table;


-- Liste des tables par interrogation du catalogue PostgreSQL
CREATE TABLE liste_tables AS 
SELECT c.relname AS nom_table
FROM pg.pg_catalog.pg_class c
INNER JOIN pg.pg_catalog.pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN liste_exclusions e ON c.relname = e.nom_table
WHERE n.nspname = 'inv_exp_nm'
    AND c.relkind = 'r'
    AND e.nom_table IS NULL
ORDER BY nom_table;

-- Liste des colonnes par interrogation du catalogue PostgreSQL
CREATE TABLE liste_colonnes AS 
SELECT t.nom_table, a.attname AS colonne
FROM pg.pg_catalog.pg_attribute a
INNER JOIN pg.pg_catalog.pg_class c ON a.attrelid = c.oid
INNER JOIN pg.pg_catalog.pg_namespace n ON n.oid = c.relnamespace
INNER JOIN liste_tables t ON c.relname = t.nom_table
WHERE n.nspname = 'inv_exp_nm'
    AND c.relkind = 'r'
    AND a.attnum >= 1
    AND a.attisdropped IS FALSE
ORDER BY nom_table, colonne;

-- Génération et exécution des requêtes dynamiques sur chaque colonne 
.mode list
.header off
.once requetes_remplissage.sql
SELECT 'SELECT ''' || nom_table || ''' AS nom_table, ''' || colonne || ''' AS nom_colonne, min(p.incref) AS inc_min, max(p.incref) AS inc_max FROM pg.inv_exp_nm.' || nom_table || ' t INNER JOIN pg.inv_exp_nm.e2point p USING (npp) WHERE t.' || colonne || ' IS NOT NULL;' AS req
FROM liste_colonnes;
.mode csv
.header off
.output resultats.csv
.read requetes_remplissage.sql
.output

--FROM read_csv('resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'});
--FROM read_csv('/home/ign.fr/CDuprez/Documents/Temp/duckdb/resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'});

-- Récupération des métadonnées MetaIFN de chaque colonne
CREATE TABLE metadonnees AS 
SELECT LOWER(f.pformat) AS nom_table, LOWER(c.donnee) AS nom_colonne, calcin AS inc_calc_min, validin AS inc_valid_min, calcout AS inc_calc_max, validout AS inc_valid_max
FROM pg.metaifn.afchamp c
INNER JOIN pg.metaifn.afformat f USING (famille, format)
INNER JOIN liste_colonnes t ON LOWER(f.pformat) = t.nom_table AND LOWER(c.donnee) = t.colonne
LEFT JOIN liste_exclusions e ON LOWER(f.pformat) = e.nom_table
WHERE famille = 'INV_EXP_NM'
AND e.nom_table IS NULL;

/*
SELECT nom_table, nom_colonne
FROM read_csv('/home/ign.fr/CDuprez/Documents/Temp/duckdb/resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'}) AS t
EXCEPT 
SELECT nom_table, nom_colonne
FROM metadonnees
ORDER BY 1, 2;

SELECT nom_table, nom_colonne
FROM metadonnees
EXCEPT 
SELECT nom_table, nom_colonne
FROM read_csv('/home/ign.fr/CDuprez/Documents/Temp/duckdb/resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'}) AS t
ORDER BY 1, 2;
*/

-- Génération du fichier de requêtes pour les données avec écarts sur CALCIN et/ou CALCOUT
.mode list
.header off
.once requetes_update_calc.sql
SELECT 'UPDATE metaifn.afchamp c SET calcin = ' || r.inc_min || ', calcout = ' || r.inc_max || ' FROM metaifn.afformat f WHERE c.famille = f.famille AND c.format = f.format AND c.famille = ''INV_EXP_NM'' AND f.pformat = ''' || upper(nom_table) || ''' AND c.donnee = ''' || upper(nom_colonne) || ''';' AS req
--FROM read_csv('resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'})
FROM read_csv('resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'}, nullstr='NULL') AS r 
INNER JOIN metadonnees AS m USING (nom_table, nom_colonne)
WHERE (r.inc_min, r.inc_max) IS DISTINCT FROM (m.inc_calc_min, m.inc_calc_max)
ORDER BY nom_table, nom_colonne;

-- Génération du fichier de requêtes pour les données avec écarts sur VALIDIN et/ou VALIDOUT
.mode list
.header off
.once requetes_update_calc_valid.sql
-- Écarts entre remplissage en base et VALIDIN / VALIDOUT
SELECT 'UPDATE metaifn.afchamp c SET calcin = ' || r.inc_min || ', calcout = ' || r.inc_max || ', validin = ' || r.inc_min || ', validout = ' || r.inc_max || ' FROM metaifn.afformat f WHERE c.famille = f.famille AND c.format = f.format AND c.famille = ''INV_EXP_NM'' AND f.pformat = ''' || upper(nom_table) || ''' AND c.donnee = ''' || upper(nom_colonne) || ''';' AS req
--FROM read_csv('resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'});
FROM read_csv('resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'}, nullstr='NULL') AS r 
INNER JOIN metadonnees AS m USING (nom_table, nom_colonne)
WHERE (r.inc_min, r.inc_max) IS DISTINCT FROM (m.inc_valid_min, m.inc_valid_max)
ORDER BY nom_table, nom_colonne;

-- Unités à mettre à jour
.mode list
.header off
.once requetes_insert_dcunite.sql
WITH ecart AS (
    SELECT lc.nom_colonne, max(lc.inc_max) AS inc_max, max(i.incref) AS unite_incref_max
--    FROM read_csv('resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'}) AS lc
    FROM read_csv('resultats.csv', delim = ',', header = FALSE, columns = {'nom_table': 'VARCHAR', 'nom_colonne': 'VARCHAR', 'inc_min': 'INT2', 'inc_max': 'INT2'}, nullstr='NULL') AS lc
    INNER JOIN pg.metaifn.addonnee d ON upper(lc.nom_colonne) = d.donnee AND d.codage = 0
    INNER JOIN pg.metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P' AND i.site = 'F' AND i.inv = 'T'
    GROUP BY nom_colonne
    HAVING max(lc.inc_max) > max(i.incref)
)
SELECT 'INSERT INTO metaifn.aiunite (unite, usite, site, cyc, inv, incref, dcunite) VALUES (''' || i.unite || ''', ''' || i.usite || ''', ''' || i.site || ''', ''' || i.cyc || ''', ''' || i.inv || ''', ' || e.inc_max || ', ''' || i.dcunite || ''');' AS req
FROM ecart e
INNER JOIN pg.metaifn.addonnee d ON upper(e.nom_colonne) = d.donnee AND d.codage = 0
INNER JOIN pg.metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P' AND i.site = 'F' AND i.inv = 'T' AND i.incref = e.unite_incref_max
ORDER BY 1;

