LOAD postgres;
ATTACH 'host=restaure-prod.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg1 (TYPE postgres);
ATTACH 'host=inv-exp.ign.fr port=5432 user=LHaugomat dbname=exploitation' AS pg2 (TYPE postgres);

-- Écarts sur les schémas
FROM postgres_query('pg1', "
SELECT schema_name, schema_owner
FROM information_schema.schemata
WHERE schema_name NOT LIKE 'pg\_%'
AND schema_name NOT IN ('information_schema')
ORDER BY schema_name
")
EXCEPT 
FROM postgres_query('pg2', "
SELECT schema_name, schema_owner
FROM information_schema.schemata
WHERE schema_name NOT LIKE 'pg\_%'
AND schema_name NOT IN ('information_schema')
ORDER BY schema_name
");

-- Écarts sur les tables
FROM postgres_query('pg1', "
SELECT t.table_schema, t.table_name, t.table_type, r.rolname AS proprio
        , (XPATH('/row/cnt/text()', t.xml_count))[1]::TEXT::INT AS nb_lignes
FROM (
    SELECT  table_name, table_schema, table_type 
        , CASE WHEN table_type = 'BASE TABLE' THEN QUERY_TO_XML(FORMAT('SELECT COUNT(*) AS cnt FROM %I.%I', table_schema, table_name), FALSE, true, '') ELSE NULL END AS xml_count
    FROM information_schema.tables
    WHERE table_schema NOT LIKE 'pg\_%'
    AND table_schema NOT IN ('information_schema')
    AND table_type != 'FOREIGN'
) t
INNER JOIN pg_catalog.pg_namespace n ON t.table_schema = n.nspname
INNER JOIN pg_catalog.pg_class c ON n.oid = c.relnamespace AND t.table_name = c.relname
LEFT JOIN pg_catalog.pg_roles r ON c.relowner = r.oid
ORDER BY table_schema, table_type, table_name
")
EXCEPT 
FROM postgres_query('pg2', "
SELECT t.table_schema, t.table_name, t.table_type, r.rolname AS proprio
        , (XPATH('/row/cnt/text()', t.xml_count))[1]::TEXT::INT AS nb_lignes
FROM (
    SELECT  table_name, table_schema, table_type 
        , CASE WHEN table_type = 'BASE TABLE' THEN QUERY_TO_XML(FORMAT('SELECT COUNT(*) AS cnt FROM %I.%I', table_schema, table_name), FALSE, true, '') ELSE NULL END AS xml_count
    FROM information_schema.tables
    WHERE table_schema NOT LIKE 'pg\_%'
    AND table_schema NOT IN ('information_schema')
    AND table_type != 'FOREIGN'
) t
INNER JOIN pg_catalog.pg_namespace n ON t.table_schema = n.nspname
INNER JOIN pg_catalog.pg_class c ON n.oid = c.relnamespace AND t.table_name = c.relname
LEFT JOIN pg_catalog.pg_roles r ON c.relowner = r.oid
ORDER BY table_schema, table_type, table_name
");

-- Écarts sur les colonnes
FROM postgres_query('pg1', "
SELECT table_schema, table_name, column_name, DENSE_RANK() OVER(PARTITION BY table_schema, table_name ORDER BY ordinal_position) AS ordre
    , numeric_precision, numeric_scale
FROM information_schema.columns c
INNER JOIN information_schema.tables USING (table_schema, table_name)
WHERE table_schema NOT LIKE 'pg\_%'
AND table_schema NOT IN ('information_schema')
AND table_type != 'FOREIGN'
ORDER BY table_schema, table_name, ordre
")
EXCEPT 
FROM postgres_query('pg2', "
SELECT table_schema, table_name, column_name, DENSE_RANK() OVER(PARTITION BY table_schema, table_name ORDER BY ordinal_position) AS ordre
    , numeric_precision, numeric_scale
FROM information_schema.columns c
INNER JOIN information_schema.tables USING (table_schema, table_name)
WHERE table_schema NOT LIKE 'pg\_%'
AND table_schema NOT IN ('information_schema')
AND table_type != 'FOREIGN'
ORDER BY table_schema, table_name, ordre
");

-- Écarts sur les contraintes
FROM postgres_query('pg1', "
SELECT constraint_schema, constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema NOT LIKE 'pg\_%'
AND constraint_schema NOT IN ('information_schema')
AND constraint_name NOT LIKE ('%not\_null')
ORDER BY constraint_schema, check_clause
")
EXCEPT 
FROM postgres_query('pg2', "
SELECT constraint_schema, constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema NOT LIKE 'pg\_%'
AND constraint_schema NOT IN ('information_schema')
AND constraint_name NOT LIKE ('%not\_null')
ORDER BY constraint_schema, check_clause
");

-- Écarts sur les fonctions
FROM postgres_query('pg1', "
SELECT routine_schema, routine_name, routine_type, type_udt_name, external_language
FROM information_schema.routines
WHERE routine_schema NOT LIKE 'pg\_%'
AND routine_schema NOT IN ('information_schema')
ORDER BY routine_schema, routine_name, type_udt_name, external_language")
EXCEPT 
FROM postgres_query('pg2', "
SELECT routine_schema, routine_name, routine_type, type_udt_name, external_language
FROM information_schema.routines
WHERE routine_schema NOT LIKE 'pg\_%'
AND routine_schema NOT IN ('information_schema')
ORDER BY routine_schema, routine_name, type_udt_name, external_language");

-- Écarts sur les triggers
FROM postgres_query('pg1', "
SELECT trigger_schema, trigger_name, event_manipulation, event_object_schema, event_object_table
    , action_statement, action_orientation, action_timing
FROM information_schema.triggers
ORDER BY trigger_schema, trigger_name, event_object_table
")
EXCEPT 
FROM postgres_query('pg2', "
SELECT trigger_schema, trigger_name, event_manipulation, event_object_schema, event_object_table
    , action_statement, action_orientation, action_timing
FROM information_schema.triggers
ORDER BY trigger_schema, trigger_name, event_object_table
");
