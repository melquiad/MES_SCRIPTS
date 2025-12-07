

-- liste des schémas

SELECT schema_name, schema_owner
FROM information_schema.schemata
WHERE schema_name NOT LIKE 'pg\_%'
AND schema_name NOT IN ('information_schema')
ORDER BY schema_name;

-- liste des tables et vues par schéma, avec leur nombre de lignes

SELECT t.table_schema, t.table_name, t.table_type, r.rolname AS proprio,
(XPATH('/row/cnt/text()', t.xml_count))[1]::TEXT::INT AS nb_lignes
FROM (
SELECT table_name, table_schema, table_type
, CASE WHEN table_type = 'BASE TABLE' THEN QUERY_TO_XML(FORMAT('SELECT COUNT(*) AS
cnt FROM %I.%I', table_schema, table_name), FALSE, true, '') ELSE NULL END AS xml_count
FROM information_schema.tables
WHERE table_schema NOT LIKE 'pg\_%'
AND table_schema NOT IN ('information_schema')
AND table_type != 'FOREIGN TABLE'
) t
INNER JOIN pg_catalog.pg_namespace n ON t.table_schema = n.nspname
INNER JOIN pg_catalog.pg_class c ON n.oid = c.relnamespace AND t.table_name = c.relname
LEFT JOIN pg_catalog.pg_roles r ON c.relowner = r.oid
ORDER BY table_schema, table_type, table_name, proprio;

-- liste des colonnes

SELECT table_schema, table_name, column_name, DENSE_RANK() OVER(PARTITION BY table_schema,
table_name ORDER BY ordinal_position) AS ordre, column_default, is_nullable, data_type,
character_maximum_length
, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_schema NOT LIKE 'pg\_%'
AND table_schema NOT IN ('information_schema')
ORDER BY table_schema, table_name, ordre;

-- liste des contraintes de vérification

SELECT constraint_schema, constraint_name, check_clause
FROM information_schema.check_constraints
WHERE constraint_schema NOT LIKE 'pg\_%'
AND constraint_schema NOT IN ('information_schema')
AND constraint_name NOT LIKE ('%not\_null')
ORDER BY constraint_schema, check_clause;

-- liste des fonctions

SELECT routine_schema, routine_name, routine_type, type_udt_name, external_language
FROM information_schema.routines
WHERE routine_schema NOT LIKE 'pg\_%'
AND routine_schema NOT IN ('information_schema')
ORDER BY routine_schema, routine_name, type_udt_name, external_language;

-- liste des déclencheurs

SELECT trigger_schema, trigger_name, event_manipulation, event_object_schema,
event_object_table
, action_statement, action_orientation, action_timing
FROM information_schema.triggers
ORDER BY trigger_schema, trigger_name, event_object_table;

-- liste des privilèges d'usage de schéma

SELECT object_schema, object_name, grantor, grantee, privilege_type, is_grantable
FROM information_schema.usage_privileges
WHERE object_schema NOT LIKE 'pg\_%'
AND object_schema NOT IN ('information_schema')
ORDER BY object_schema, object_name, grantee, privilege_type;

-- liste des privilèges sur les tables

SELECT p.table_schema, p.table_name, p.grantor, p.grantee, p.privilege_type,
p.is_grantable
FROM information_schema.table_privileges p
INNER JOIN information_schema.tables t USING (table_schema, table_name)
WHERE p.table_schema NOT LIKE 'pg\_%'
AND p.table_schema NOT IN ('information_schema')
AND t.table_type != 'FOREIGN TABLE'
ORDER BY table_schema, table_name, grantee, privilege_type;

-- liste des contraintes de table

SELECT table_schema, table_name, constraint_name
FROM information_schema.constraint_table_usage
WHERE table_schema NOT LIKE 'pg\_%'
AND table_schema NOT IN ('information_schema')
ORDER BY table_schema, table_name, constraint_name;

-- liste des serveurs étrangers

SELECT foreign_server_name, foreign_data_wrapper_name, authorization_identifier
FROM information_schema.foreign_servers
ORDER BY foreign_server_name;

-- liste des tables étrangères

SELECT t.foreign_server_name, t.foreign_table_schema, t.foreign_table_name, u.rolname AS
proprio
FROM information_schema.foreign_tables t
INNER JOIN pg_catalog.pg_namespace n ON n.nspname = t.foreign_table_schema
INNER JOIN pg_catalog.pg_class c ON t.foreign_table_name = c.relname AND n.oid =
c.relnamespace
INNER JOIN pg_catalog.pg_roles u ON c.relowner = u.oid
ORDER BY foreign_server_name, foreign_table_schema, foreign_table_name;

-- liste des séquences

SELECT sequence_schema, sequence_name, data_type, numeric_precision,
numeric_precision_radix, numeric_scale, start_value, minimum_value, "increment",
cycle_option
FROM information_schema.sequences
WHERE sequence_schema NOT LIKE 'pg\_%'
AND sequence_schema NOT IN ('information_schema')
ORDER BY sequence_schema, sequence_name;