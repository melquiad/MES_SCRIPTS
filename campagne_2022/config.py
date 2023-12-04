#!/usr/bin/python
from configparser import ConfigParser
from os.path import expanduser


def config(section='inventaire-local', filename=expanduser("~") + '/databases.ini'):
    #création d'un parseur
    parser = ConfigParser()
    #lecture du fichier de configuration
    parser.read(filename)

    #récupération de la section passée en paramètre ("confinement" par défaut)
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception(f'Section {section} absente du fichier {filename}')

    return db