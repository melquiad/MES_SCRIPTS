#!/usr/bin/python
import psycopg
import time
from config import config

conn = None
schema = 'inv_exp_nm'
environnement = 'exploitation'

# constantes booléennes pour indiquer si la mise à jour concerne CALCOUT et / ou VALIDOUT
maj_calcout = True
maj_validout = False


try:
    # récupération des paramètres de connexion dans le fichier databases.ini pour le nom de connexion passé en paramètre
    params = config(environnement)
    #params = config('exploitation-test')
    #params = config('inventaire-local')

    # connexion au serveur PostgreSQL
    print('Connecting to the PostgreSQL database...')
    conn = psycopg.connect(**params)

    # création d'un curseur
    cur = conn.cursor()

    # récupération de la liste des tables par interrogation du catalogue PostgreSQL
    sql = """SELECT c.relname AS nom_table
    FROM pg_catalog.pg_class c
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = '{}'
    AND c.relkind = 'r'
    ORDER BY nom_table""".format(schema)
    cur.execute(sql)

    tables = cur.fetchall()

    tabs = []
    for t in tables:
        tabs.append(t[0])

    # on élimine les tables qu'on ne souhaite pas contrôler
    inutiles = ['e1coord', 'e1noeud', 'e1point', 'echantillon', 'famille_echantillon', 'famille_stratification', 'g3arbre_coord', 'g3bille', 'g3complete', 'g3essence', 'g3flore', 'g3habitat', 'g3plant', 'g3schmitt', 'g3souche', 'g3strate', 'l1intersect', 'l1transect', 'l2segment', 'l3arbre', 'l3bille', 'l3complete', 'l3etage', 'l3flore', 'l3niveau', 'l3pressler', 'l3schmitt', 'l3segment', 'p3agedom', 'p3bille', 'p3complete', 'p3ecologie', 'p3essence', 'p3flore', 'p3plant', 'p3pressler', 'p3schmitt', 'p3strate', 'point_aurelhy', 's5strate', 's5stratech', 's5stratif', 's5var', 'unite_ech'
        # , 'u_e2point', 'u_g3foret', 'u_p3point', 'u_g3arbre', 'u_p3arbre', 'u_g3morts', 'u_p3morts'
    ]
    for i in inutiles:
        tabs.remove(i)

    print(tabs)

    # tabs = ['e2point']

    timestr = time.strftime("%Y%m%d_%H%M")
    script = open(environnement + "_" + timestr + "_mise_a_jour_calc_valid.sql", "w")

    # on boucle sur chaque table à analyser
    for tab in tabs:

        # on récupère la liste des colonnes dans la table
        sql = """SELECT a.attname AS colonne, pg_get_expr(d.adbin, d.adrelid) AS default_value
            FROM   pg_attribute a
            LEFT   JOIN pg_catalog.pg_attrdef d ON (a.attrelid, a.attnum) = (d.adrelid, d.adnum)
            WHERE  attrelid = '{}.{}'::regclass
            AND    attnum  >= 1
            AND    attisdropped is FALSE
            ORDER BY attname""".format(schema, tab)
        cur.execute(sql)
        colonnes = cur.fetchall()

        # print(colonnes)

        cols=[]
        cols_pb = []
        for c in colonnes:
            if c[1] is None:
                sql_data = f"""SELECT '{c[0]}' AS donnee, MIN(incref) AS inc_min, MAX(incref) AS inc_max
                FROM {schema}.{tab}
                WHERE {c[0]} IS NOT NULL"""
            else:
                sql_data = f"""SELECT '{c[0]}' AS donnee, MIN(incref) AS inc_min, MAX(incref) AS inc_max
                FROM {schema}.{tab}
                WHERE coalesce({c[0]}, {c[1]}) IS DISTINCT FROM """ + c[1]
                # print(sql_data)
            cur.execute(sql_data)
            cd = cur.fetchone()
            sql_meta = f"""SELECT LOWER(donnee) AS donnee, calcin AS inc_calc_min, validin AS inc_valid_min, calcout AS inc_calc_max, validout AS inc_valid_max
            FROM metaifn.afchamp c
            INNER JOIN metaifn.afformat f USING (famille, format)
            WHERE famille = '{schema.upper()}'
            AND pformat = '{tab.upper()}'
            AND donnee = '{c[0].upper()}'"""
            # print(sql_meta)
            cur.execute(sql_meta)
            cm = cur.fetchone()
            nuller = lambda x: "NULL" if x == None else x
            if cm is None:
                print(f"Donnée {c[0]} non documentée")
            elif maj_validout and not (cd[1] == cm[2] and cd[2] == cm[4]):
                # print(f"Problème sur {c[0]} : Incref min = {cd[1]}, validin = {cm[1]}, Incref max = {cd[2]}, validout = {cm[2]}")
                print(f"UPDATE metaifn.afchamp c SET calcin = {nuller(cd[1])}, validin = {nuller(cd[1])}, calcout = {nuller(cd[2])}, validout = {nuller(cd[2])} FROM metaifn.afformat f WHERE c.famille = f.famille AND c.format = f.format AND c.famille = 'INV_EXP_NM' AND f.pformat = '{tab.upper()}' AND donnee = '{c[0].upper()}';", file = script)
            elif maj_calcout and not (cd[1] == cm[1] and cd[2] == cm[3]):
                print(f"UPDATE metaifn.afchamp c SET calcin = {nuller(cd[1])}, calcout = {nuller(cd[2])} FROM metaifn.afformat f WHERE c.famille = f.famille AND c.format = f.format AND c.famille = 'INV_EXP_NM' AND f.pformat = '{tab.upper()}' AND donnee = '{c[0].upper()}';", file = script)

    # print(tabs)

    cur.close()
    script.close()

except (Exception, psycopg.DatabaseError) as error:
    print(error)
finally:
    if conn is not None:
        conn.close()
