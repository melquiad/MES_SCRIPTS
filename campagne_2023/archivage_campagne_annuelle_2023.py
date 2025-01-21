#!/usr/bin/python
from configparser import ConfigParser
import os
import shutil
import psycopg
import sys
import datetime
import tarfile
import hashlib

# Nom de la connexion à recherche dans le fichier de configuration (databases.ini sous $HOME)
SECTION = "exploitation"
# Nom du schéma à sauvegarder
SCHEMA = "inv_exp_nm"
# Nom du schéma de sauvegarde
SCHEMA_SV = "archive_inv_exp_nm"
# Année de campagne à archiver
CAMPAGNE = 2023

def config(section = 'inventaire-local', filename = os.path.expanduser("~") + '/databases.ini'):
    """Fonction retournant les informations de chaîne de connexion à une base de données PostgreSQL à partir d'un fichier de configuration.
    Les paramètres sont :
        * section : nom de la section (entre crochets) à lire dans le fichier databases.ini. Par défaut, la connexion se nomme inventaire-local.
        * filename : chemin complet vers le fichier de configuration. Par défaut, le fichier se nomme databases.ini dans le répertoire home de l'utilisateur"""
    # Création d'un parseur
    parser = ConfigParser()
    # Lecture du fichier de configuration
    parser.read(filename)

    # Récupération de la section passée en paramètre ("confinement" par défaut)
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception(f'Section {section} absente du fichier {filename}')

    return db

# Récupération des paramètres de connexion
params = config(SECTION)

# Connexion à la base de données (sortie du programme en cas d'échec)
conn = None
try:
    conn = psycopg.connect(**params)
except Exception as e:
    print(f"Impossible de se connecter à {params['dbname']}, {e}")
if conn is None:
    sys.exit("Pas de connexion à la base de données, programme interrompu.")

# Serveur de bases de données
SERVEUR = params['host']
# Nom de la base de données
DATABASE = params['dbname']
# Nom de compte connecté à la base de données
USER = params['user']

# Traduction de la campagne en INCREF de début et fin
increfs = [CAMPAGNE - 2014, CAMPAGNE - 2005]

with conn as conn:
    with conn.cursor() as cur:
        # Création d'un schéma dédié à l'export
        cur.execute(f"""DROP SCHEMA IF EXISTS {SCHEMA_SV} CASCADE;
CREATE SCHEMA {SCHEMA_SV};""")

        # Liste des tables susceptibles d'être sauvegardées
        cur.execute("""SELECT DISTINCT pformat
, COUNT(*) FILTER (WHERE donnee = 'INCREF') AS incref
FROM metaifn.afformat f
INNER JOIN metaifn.afchamp c USING (famille, format)
WHERE famille = %s
AND pformat ~ '^(E|G|P|S|L|FAM|UNI)'
AND pformat !~ 'E1COORD'
GROUP BY pformat
ORDER BY pformat;""", (SCHEMA.upper(),))
        tables = cur.fetchall()
        
        # Liste de tables avec une colonne INCREF
        tables_incref = [x[0].lower() for x in tables if x[1] == 1]

        # Liste des tables avec colonne INCREF ayant au moins une ligne dans l'intervalle des increfs à archiver
        tables_incref_ok = []
        for tab in tables_incref:
            cur.execute(f"""SELECT EXISTS(SELECT 1 FROM {SCHEMA}.{tab} WHERE incref BETWEEN %s AND %s);""", (increfs[0], increfs[1]))
            resultat = cur.fetchone()
            if resultat[0]:
                tables_incref_ok.append(tab)
        
        # Liste des tables sans colonne INCREF
        tables_archives = [x[0].lower() for x in tables if x[1] == 0]

        # Le schéma de sauvegarde devient le schéma par défaut
        cur.execute(f"SET search_path = {SCHEMA_SV};")

        # Traitement à part de la table E1NOEUD (on se raccroche à l'INCREF de E1POINT)
        tables_incref_ok.remove('e1noeud')
        tables_archives.append('e1noeud')
        cur.execute(f"""CREATE TABLE e1noeud AS SELECT DISTINCT n.* FROM {SCHEMA}.e1noeud n INNER JOIN inv_exp_nm.e1point p USING (nppg) WHERE p.incref BETWEEN %s AND %s;""", (increfs[0], increfs[1]))

        # Création des tables conservées par recopie des tables correspondantes dans le schéma initial, pour les tables avec INCREF
        for tab in tables_incref_ok:
            cur.execute(f"""CREATE TABLE {tab} AS SELECT * FROM {SCHEMA}.{tab} WHERE incref BETWEEN %s AND %s;""", (increfs[0], increfs[1]))
        
        # Création des tables conservées entièrement
        for tab in ['famille_echantillon', 'famille_stratification']:
            cur.execute(f"""CREATE TABLE {tab} AS SELECT * FROM {SCHEMA}.{tab};""")
        
        # Création des tables avec lien vers ECHANTILLON
        for tab in ['unite_ech', 's5stratif']:
            cur.execute(f"""CREATE TABLE {tab} AS SELECT t.* FROM {SCHEMA}.{tab} AS t INNER JOIN {SCHEMA_SV}.echantillon USING (id_ech);""")

        # Création des tables avec lien vers S5STRATIF
        for tab in ['s5strate', 's5var', 's5stratech']:
            cur.execute(f"""CREATE TABLE {tab} AS SELECT t.* FROM {SCHEMA}.{tab} AS t INNER JOIN {SCHEMA_SV}.s5stratif USING (stratif);""")

        # Création des tables avec lien vers E1POINT
        for tab in ['g3arbre_coord', 'g3habitat', 'g3plant', 'g3esp_rege', 'p3esp_rege']:
            cur.execute(f"""CREATE TABLE {tab} AS SELECT t.* FROM {SCHEMA}.{tab} AS t INNER JOIN {SCHEMA_SV}.e1point USING (npp);""")
        
        # Récupération des contraintes sur les tables
        liste_sql = ", ".join(['%s'] * len(tables_incref_ok + tables_archives))
        cur.execute(f"""SELECT c.relname AS nom_table, r.conname AS nom_contrainte, pg_catalog.pg_get_constraintdef(r.oid, TRUE) AS def_contrainte, r.contype as type_contrainte
FROM pg_catalog.pg_constraint r
INNER JOIN pg_catalog.pg_class c ON r.conrelid = c.oid
INNER JOIN pg_catalog.pg_namespace n on c.relnamespace = n.oid
WHERE n.nspname = '{SCHEMA}' AND c.relname IN ({liste_sql});""", (tables_incref_ok + tables_archives))
        resultat = cur.fetchall()
        
        # On remplace "inv_exp_nm" par "archive_inv_exp_nm" dans chaque définition de clé étrangère
        contraintes = [tuple(map(lambda i: str.replace(i, f"{SCHEMA}", f"{SCHEMA_SV}"), tup)) for tup in resultat]

        # Distinction des différents types de contraintes
        primaires = []
        verifs = []
        etrangeres = []
        for contrainte in contraintes:
            if contrainte[3] == 'p':
                primaires.append(contrainte)
            elif contrainte[3] == 'f':
                etrangeres.append(contrainte)
            elif contrainte[3] == 'c':
                verifs.append(contrainte)
        
        # Création des contraintes de clés primaires sur les tables d'archivage
        for primaire in primaires:
            cur.execute(f"""ALTER TABLE {primaire[0]} ADD CONSTRAINT {primaire[1]} {primaire[2]}""")
        
        # Création des contraintes de vérification sur les tables d'archivage
        for verif in verifs:
            cur.execute(f"""ALTER TABLE {verif[0]} ADD CONSTRAINT {verif[1]} {verif[2]}""")

        # Création des contraintes de clés étrangères sur les tables d'archivage
        for etrangere in etrangeres:
            cur.execute(f"""ALTER TABLE {etrangere[0]} ADD CONSTRAINT {etrangere[1]} {etrangere[2]}""")
        
        conn.commit()

        # Création du répertoire stockant les fichiers de sauvegarde (suppression préalable s'il existe déjà)
        if os.path.exists(str(CAMPAGNE)):
            shutil.rmtree(str(CAMPAGNE))
        os.mkdir(str(CAMPAGNE))
        os.chdir(f"./{CAMPAGNE}")

        # Export de la structure
        dt = datetime.date.today()

        cmd_dump = f"pg_dump -Fc -n {SCHEMA_SV} -s -O -x --no-tablespaces -f export_init.sql -h {SERVEUR} -U {USER} -d {DATABASE}"
        os.system(cmd_dump)
        cmd_dump = f"pg_restore -l export_init.sql | grep -v FUNCTION | grep -v TYPE | grep -v VIEW > list.txt"
        os.system(cmd_dump)
        cmd_dump = f"pg_restore -O -x -L list.txt export_init.sql -f inventaire-forestier_{SCHEMA}_{dt.year}_{dt.month:02}_structure.sql"
        os.system(cmd_dump)
        cmd_dump = f"rm export_init.sql list.txt"
        os.system(cmd_dump)

        # Export des données
        cmd_dump = f"pg_dump -Fp -n {SCHEMA_SV} -a -O -x -f inventaire-forestier_{SCHEMA}_{dt.year}_{dt.month:02}_donnees.sql -h {SERVEUR} -U {USER} -d {DATABASE}"
        os.system(cmd_dump)

        # Génération du compte rendu d'export
        start = "COPY "
        end = " ("
        infos_tables = []
        nb_lignes = 0
        for line in open(f"inventaire-forestier_{SCHEMA}_{dt.year}_{dt.month:02}_donnees.sql"):
            if start in line:
                table = line[line.find(start)+len(start):line.rfind(end)]
                nb_lignes = 0
            elif line[0:2] == "\.":
                infos_tables.append((table, nb_lignes))
            else:
                nb_lignes += 1
        
        f = open("compte_rendu.txt", "w")
        for tup in infos_tables:
            f.write(f"{tup[0]}={tup[1]}\n")
        f.close()

        # Export des métadonnées sur les données
        cur.execute(f"""CREATE TEMPORARY VIEW donnees AS
WITH str AS (
	SELECT DISTINCT a.attname,
	  pg_catalog.format_type(a.atttypid, a.atttypmod),
	  a.attnotnull
	FROM pg_catalog.pg_attribute a
		INNER JOIN pg_catalog.pg_class c ON a.attrelid = c.oid
		LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	WHERE n.nspname = '{SCHEMA_SV}'
		AND c.relkind = 'r'
		AND a.attnum > 0 AND NOT a.attisdropped
	ORDER BY a.attname
)
SELECT d.donnee, d.unite, d.codage, d.libelle, d.definition
FROM str s
INNER JOIN metaifn.addonnee d ON s.attname = LOWER(d.donnee)
INNER JOIN metaifn.abunite u ON d.unite = u.unite
WHERE d.donnee IS NOT NULL
UNION 
SELECT 'CODE_FAMILLE_ECHANTILLON', 'CODE', '1', $$Code de la famille d'échantillon$$, $$Code de la famille d'échantillon$$
UNION 
SELECT 'CODE_FAMILLE_STRATIFICATION', 'CODE', '1', $$Code de la famille de stratification$$, $$Code de la famille de stratification$$
ORDER BY donnee;""")
        with open(f"inventaire-forestier_{SCHEMA}_{dt.year}_{dt.month:02}_metadonnees_donnees.csv", "wb") as f:
            with cur.copy("COPY (SELECT * FROM donnees) TO STDOUT WITH CSV DELIMITER '|' NULL '' HEADER") as copy:
                for data in copy:
                    f.write(data)

        cur.execute("DROP VIEW donnees;")


        # Export des métadonnées sur les modalités
        cur.execute(f"""CREATE TEMPORARY VIEW modalites AS
WITH str AS (
	SELECT DISTINCT a.attname,
	  pg_catalog.format_type(a.atttypid, a.atttypmod),
	  a.attnotnull, a.attnum
	FROM pg_catalog.pg_attribute a
		INNER JOIN pg_catalog.pg_class c ON a.attrelid = c.oid
		LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
	WHERE n.nspname = '{SCHEMA_SV}'
		AND c.relkind = 'r'
		AND a.attnum > 0 AND NOT a.attisdropped
	ORDER BY a.attnum
)
, croise AS (
	SELECT s.attname AS colonne, d.donnee, d.unite, d.codage, d.libelle, d.definition, u.utype, s.attnum
	FROM str s
	INNER JOIN metaifn.addonnee d ON s.attname = LOWER(d.donnee)
	INNER JOIN metaifn.abunite u ON d.unite = u.unite
	ORDER BY s.attnum
)
SELECT donnee
, NULL AS incref
, m.mode, m.libelle, m.definition
FROM metaifn.abmode m
INNER JOIN croise c ON c.utype IN ('DISCRETISE', 'NOMINAL', 'ORDINAL') AND c.codage = 1::BIT AND m.unite = c.unite
UNION
SELECT donnee
, i.incref
, m.mode, m.libelle, m.definition
FROM croise c
INNER JOIN metaifn.abunite u ON c.utype IN ('DISCRETISE', 'NOMINAL', 'ORDINAL') AND c.codage = 0::BIT AND u.unite = c.unite
INNER JOIN metaifn.aiunite i ON i.unite = u.unite AND i.inv = 'T' AND i.usite = 'P' AND site = 'F' 
    AND i.incref BETWEEN {increfs[0]} AND {increfs[1]}
INNER JOIN metaifn.abmode m ON i.dcunite = m.unite
ORDER BY donnee, incref, mode;""")
        with open(f"inventaire-forestier_{SCHEMA}_{dt.year}_{dt.month:02}_metadonnees_modalites.csv", "wb") as f:
            with cur.copy("COPY (SELECT * FROM modalites) TO STDOUT WITH CSV DELIMITER '|' NULL '' HEADER") as copy:
                for data in copy:
                    f.write(data)

        cur.execute("DROP VIEW modalites;")

        # Compression des fichiers générés dans une archive tar.gz
        with tarfile.open(f"inventaire-forestier_{SCHEMA}_{dt.year}_{dt.month:02}.tar.gz", "w:gz") as tar:
            tar.add(os.getcwd(), arcname=os.path.sep)
        
        # Somme MD5 du fichier archive
        md5_hash = hashlib.md5()
        with open(f"inventaire-forestier_{SCHEMA}_{dt.year}_{dt.month:02}.tar.gz","rb") as f:
            # Read and update hash in chunks of 4K
            for byte_block in iter(lambda: f.read(4096),b""):
                md5_hash.update(byte_block)
            # print(md5_hash.hexdigest())
            fs = open(f"inventaire-forestier_{SCHEMA}_{dt.year}_{dt.month:02}.tar.gz.md5", "w")
            fs.write(f"{md5_hash.hexdigest()} inventaire-forestier_{SCHEMA}_{dt.year}_{dt.month:02}.tar.gz")
            fs.close()
        
        # Suppression finale du schéma dédié à l'export
        cur.execute(f"""DROP SCHEMA IF EXISTS {SCHEMA_SV} CASCADE;""")

        # Persistance des modifications
        conn.commit()


# Déconnexion de la base de données
if conn is not None:
    conn.close()

