#!/usr/bin/python
from configparser import ConfigParser
import os
import shutil
import psycopg
import requests
import pandas as pd

# Nom de la connexion à recherche dans le fichier de configuration (databases.ini sous $HOME)
SECTION = "production"
# Nom du schéma à interroger
SCHEMA = "inv_prod_new"

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

def croise_rge_alti(nodes):
    # Récupération sous forme de listes des identifiants, longitudes et latitudes des noeuds
    id_noeuds = [noeud[1] for noeud in nodes]
    longitudes = [noeud[5] for noeud in nodes]
    latitudes = [noeud[6] for noeud in nodes]
    # Agrégation des longitudes et latitudes en une seule chaîne de caractères avec "|" comme séparateur
    str_lon = "|".join(map(str, longitudes))
    str_lat = "|".join(map(str, latitudes))
    # Génération du JSON à passer par la méthode POST
    nds = {}
    nds["lon"] = str_lon
    nds["lat"] = str_lat
    nds["resource"] = "ign_rge_alti_wld"
    nds["delimiter"] = "|"
    nds["indent"] = "false"
    nds["measures"] = "false"
    nds["zonly"] = "false"
    # Génération de la requête POST vers l'API REST du RGE ALTI (GEOPLATEFORME)
    headers = {'accept': 'application/json', 'Content-Type': 'application/json'}
    url = "https://data.geopf.fr/altimetrie/1.0/calcul/alti/rest/elevation.json"
    # print(nds)
    altitudes = requests.post(url=url, json=nds, headers=headers)
    # print(altitudes.reason)
    alts = altitudes.json().get('elevations')
    z = [alt.get('z') for alt in alts]
    
    nd_fin = [n + (z[i],) for i, n in enumerate(nodes)]
    
    df = pd.DataFrame(nd_fin, columns = ['id_grille', 'id_noeud', 'nppg', 'incref', 'tirmax', 'xgps', 'ygps', 'zp'])
    hd = True if i == 1 else False
    csv_filename = "altitude_noeud_grille1_incref0.csv"
    df[['id_grille', 'id_noeud', 'zp']].to_csv(csv_filename, header=hd, index=False, sep=";", mode = "a")
    return True

# Récupération des données en base
with conn as conn:
    with conn.cursor() as cur:
        # Informations sur les noeuds de l'incref 0 dont on veut l'altitude
        cur.execute(f"""SELECT id_grille, id_noeud, nppg, incref, tirmax, st_x(st_transform(geom, 4326)) AS xgps, st_y(st_transform(geom, 4326)) AS ygps
FROM noeud
WHERE id_grille = 1
AND incref = 0
ORDER BY id_noeud;""")
        noeuds = cur.fetchall()
        
        # Découpage de la liste des noeuds en liste de 250 noeuds chacune
        n = 250
        noeuds_chunks = [noeuds[i:i + n] for i in range(0, len(noeuds), n)]
        
        # On boucle sur chaque groupe de 250 noeuds et on agrège les résultats
        noeuds_alt = []
        
        i = 1
        
        for nd in noeuds_chunks[i-1:]:
            print(str(i) + ' / ' + str(len(noeuds_chunks)))
            successes = False
            while not successes :
                try:
                    successes = croise_rge_alti(nd)
                except Exception as e:
                    # print(e)
                    successes = False
            i += 1

        # Persistance des modifications
        conn.commit()

# Déconnexion de la base de données
if conn is not None:
    conn.close()
