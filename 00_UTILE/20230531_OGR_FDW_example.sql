-- CONNEXION AU FLUX WFS DE L'INPN

DROP SERVER IF EXISTS fdw_ogr_inpn_metropole;

CREATE SERVER fdw_ogr_inpn_metropole FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource 'WFS:http://ws.carmencarto.fr/WFS/119/fxx_inpn?',format 'WFS');

CREATE SCHEMA IF NOT EXISTS inpn_metropole;

IMPORT FOREIGN SCHEMA ogr_all
--LIMIT TO "Sites Ramsar"
FROM SERVER fdw_ogr_inpn_metropole
INTO inpn_metropole
OPTIONS (
    -- mettre le nom des tables en minuscule et sans caractères bizares
    launder_table_names 'true',
    -- mettre le nom des champs en minuscule
    launder_column_names 'true'
		);

SELECT foreign_table_schema, foreign_table_name
FROM information_schema.foreign_tables
WHERE foreign_table_schema = 'inpn_metropole'
ORDER BY foreign_table_schema, foreign_table_name;

-------------------------------------------------------------------------------------------------------

-- CONNEXION AU FLUX WFS DU SHOM

DROP SERVER IF EXISTS fdw_ogr_shom;

CREATE SERVER fdw_ogr_shom FOREIGN DATA WRAPPER ogr_fdw
OPTIONS (datasource 'WFS:http://services.data.shom.fr/DELMAR/wfs',format 'WFS');

CREATE SCHEMA IF NOT EXISTS shom;

IMPORT FOREIGN SCHEMA ogr_all
--LIMIT TO "Sites Ramsar"
FROM SERVER fdw_ogr_shom
INTO shom
OPTIONS (
    -- mettre le nom des tables en minuscule et sans caractères bizares
    launder_table_names 'true',
    -- mettre le nom des champs en minuscule
    launder_column_names 'true'
		);

SELECT foreign_table_schema, foreign_table_name
FROM information_schema.foreign_tables
WHERE foreign_table_schema = 'shom'
ORDER BY foreign_table_schema, foreign_table_name;

------------------------------------------------------------------------------
------------------------------------------------------------------------------
CREATE EXTENSION postgres_fdw;

CREATE SERVER foreign_server
        FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (host '192.83.123.89', port '5432', dbname 'foreign_db');

CREATE USER MAPPING FOR local_user
        SERVER foreign_server
        OPTIONS (user 'foreign_user', password 'password');

CREATE FOREIGN TABLE foreign_table (
        id integer NOT NULL,
        data text
)
        SERVER foreign_server
        OPTIONS (schema_name 'some_schema', table_name 'some_table');








