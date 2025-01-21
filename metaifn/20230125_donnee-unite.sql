SELECT d.donnee, d.unite, i.incref, i.dcunite, d.libelle
FROM metaifn.addonnee d
LEFT JOIN metaifn.aiunite i ON d.unite = i.unite AND i.usite = 'P'
WHERE d.donnee = 'ESPARPRE'
ORDER BY incref;