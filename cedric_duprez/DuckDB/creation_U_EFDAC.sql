-- via DuckDB
LOAD postgres;

ATTACH 'host=test-inv-exp.ign.fr port=5432 user=CDuprez dbname=exploitation' AS pg (TYPE postgres);
ATTACH 'host=inv-exp.ign.fr port=5432 user=CDuprez dbname=exploitation' AS pg (TYPE postgres);

--DESC pg.metaifn.abunite;

INSERT INTO pg.metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_EFDAC', 'AUTRE', 'NOMINAL', 'Nomenclature EFDAC des espèces ligneuses', 'Nomenclature EFDAC (European Forest Data Centre) des espèces ligneuses pour le projet européen PathFinder.');

--DESC pg.metaifn.abmode;

INSERT INTO pg.metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
SELECT 'U_EFDAC' AS unite, mode, row_number() over() AS position, row_number() over() AS classe, 1 AS etendue, libelle, definition
FROM read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Gohon/u_efdac.csv');

INSERT INTO pg.metaifn.abgroupe (gunite, gmode, unite, mode)
SELECT 'U_EFDAC', u_efdac, 'CODESP', codesp
FROM read_csv('/home/ign.fr/CDuprez/Documents/DBeaver/workspace/SQL/Utilisateurs/Gohon/codesp_efdac.csv');

UPDATE pg.metaifn.abunite 
SET definition = 'Nomenclature European Forest Data Centre des espèces ligneuses pour le projet PathFinder. Non renseignée pour les espèces non arborées et absentes de https://gitlab.com/nfiesta/pathfinder_demo_study/-/wikis/myuploads/TreeSpecies_EFDAC_2014_09_29.csv'
WHERE unite = 'U_EFDAC';

DETACH pg;
