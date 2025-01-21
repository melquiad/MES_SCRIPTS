#!/usr/bin/python
from configparser import ConfigParser
import os
import shutil
import psycopg2
import requests
import pandas as pd

# Nom de la connexion à recherche dans le fichier de configuration (databases.ini sous $HOME)
SECTION = "inventaire-local"
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

def croise_rge_alti(npoints):
    # Récupération sous forme de listes des identifiants, longitudes et latitudes des noeuds
    npp = [npoint[0] for npoint in npoints]
    longitudes = [npoint[1] for npoint in npoints]
    latitudes = [npoint[2] for npoint in npoints]
    # Agrégation des longitudes et latitudes en une seule chaîne de caractères avec "|" comme séparateur
    str_lon = "|".join(map(str, longitudes))
    str_lat = "|".join(map(str, latitudes))
    # Génération du JSON à passer par la méthode POST
    pts = {}
    pts["lon"] = str_lon
    pts["lat"] = str_lat
    pts["resource"] = "ign_rge_alti_wld"
    pts["delimiter"] = "|"
    pts["indent"] = "false"
    pts["measures"] = "false"
    pts["zonly"] = "false"
    # Génération de la requête POST vers l'API REST du RGE ALTI (GEOPLATEFORME)
    headers = {'accept': 'application/json', 'Content-Type': 'application/json'}
    url = "https://data.geopf.fr/altimetrie/1.0/calcul/alti/rest/elevation.json"
    # print(pts)
    altitudes = requests.post(url=url, json=pts, headers=headers)
    # print(altitudes.reason)
    alts = altitudes.json().get('elevations')
    z = [alt.get('z') for alt in alts]
    
    pt_fin = [n + (z[i],) for i, n in enumerate(npoints)]
    
    df = pd.DataFrame(pt_fin, columns = ['npp', 'xgps', 'ygps', 'zp'])
    hd = True if i == 1 else False
    md = "w" if i == 1 else "a"
    csv_filename = "altitude_points_2026.csv"
    df[['npp', 'zp']].to_csv(csv_filename, header=hd, index=False, sep=";", mode = md)
    return True

# Récupération des données en base
with conn as conn:
    with conn.cursor() as cur:
        # Informations sur les points nouveaux dont on veut l'altitude
        cur.execute(f"""SELECT npp, st_x(st_transform(geom, 4326)) AS xgps, st_y(st_transform(geom, 4326)) AS ygps
FROM public.pts_new
ORDER BY ygps, xgps;""")
        points = cur.fetchall()
        
        # Découpage de la liste des noeuds en liste de 250 points chacune
        n = 250
        points_chunks = [points[i:i + n] for i in range(0, len(points), n)]
        
        # On boucle sur chaque groupe de 250 points et on agrège les résultats
        points_alt = []
        
        i = 1
        
        for pt in points_chunks[i-1:]:
            print(str(i) + ' / ' + str(len(points_chunks)))
            successes = False
            while not successes :
                try:
                    successes = croise_rge_alti(pt)
                except Exception as e:
                    # print(e)
                    successes = False
            i += 1

        # Persistance des modifications
        conn.commit()

# Déconnexion de la base de données
if conn is not None:
    conn.close()
