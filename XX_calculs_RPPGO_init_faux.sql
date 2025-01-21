-- Création des tables (à faire une seule fois)
CREATE TABLE inv_exp_nm.g3esp_rege (
    npp CHAR(16),
    nsp INT2, 
    espar VARCHAR(4),
    chnr CHAR(1), 
    brou CHAR(1),
    frot CHAR(1),
    nt INT2,
    pds INT2,
    w FLOAT8,
    libnr CHAR(1),
    CONSTRAINT g3esp_rege_pkey PRIMARY KEY (npp, nsp, espar, chnr, brou, frot),
    CONSTRAINT g3esp_rege_g3foret_fkey FOREIGN KEY (npp) REFERENCES inv_exp_nm.g3foret (npp) DEFERRABLE INITIALLY DEFERRED    
);

CREATE TABLE inv_exp_nm.p3esp_rege (
    npp CHAR(16),
    nsp INT2, 
    espar VARCHAR(4),
    chnr CHAR(1), 
    brou CHAR(1),
    frot CHAR(1),
    nt INT2,
    pds INT2,
    w FLOAT8,
    libnr CHAR(1),
    CONSTRAINT p3esp_rege_pkey PRIMARY KEY (npp, nsp, espar, chnr, brou, frot),
    CONSTRAINT p3esp_rege_p3point_fkey FOREIGN KEY (npp) REFERENCES inv_exp_nm.p3point (npp) DEFERRABLE INITIALLY DEFERRED    
);

-- Documentation dans MetaIFN
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition) VALUES ('BROU', 'IFN', 'NOMINAL', $$Indicateur d'abroutissement$$, $$Indicateur d'abroutissement$$);
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition) VALUES ('FROT', 'IFN', 'NOMINAL', $$Indicateur de frottement$$, $$Indicateur de frottement ou d'écorçage$$);
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition) VALUES ('LIBNR', 'IFN', 'NOMINAL', $$Accès à la lumière$$, $$Indicateur d'accès à la lumière de la sous-placette de décompte des individus non recensables$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('BROU', '0', 0, 0, 1, $$Absence de traces d'abroutissement$$, $$Absence de traces d'abroutissement dans le tiers supérieur des tiges non recensables$$)
, ('BROU', '1', 1, 1, 1, $$Présence de traces d'abroutissement$$, $$Présence de traces d'abroutissement dans le tiers supérieur des tiges non recensables$$)
, ('FROT', '0', 0, 0, 1, $$Absence de frottements ou d'écorçage$$, $$Absence de traces de frottements ou d'écorçage sur les tiges non recensables$$)
, ('FROT', '1', 1, 1, 1, $$Présence de frottements ou d'écorçage$$, $$Présence de traces de frottements ou d'écorçage sur les tiges non recensables$$)
, ('LIBNR', '0', 0, 0, 1, $$Pas d'accès à la lumière$$, $$Le centre de la sous-placette de décompte des tiges non recensables est surcimé par des arbres recensables$$)
, ('LIBNR', '1', 1, 1, 1, $$Accès à la lumière$$, $$Le centre de la sous-placette de décompte des tiges non recensables n'est pas surcimé par des arbres recensables$$);

SELECT * FROM metaifn.ajoutdonnee('BROU', NULL, 'BROU', 'IFN', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, $$Indicateur d'abroutissement$$, $$Indicateur d'abroutissement$$);
SELECT * FROM metaifn.ajoutdonnee('FROT', NULL, 'FROT', 'IFN', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, $$Indicateur de frottement$$, $$Indicateur de frottement ou d'écorçage$$);
SELECT * FROM metaifn.ajoutdonnee('LIBNR', NULL, 'LIBNR', 'IFN', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, $$Accès à la lumière$$, $$Indicateur d'accès à la lumière de la sous-placette de décompte des individus non recensables$$);
SELECT * FROM metaifn.ajoutdonnee('NSP', NULL, '1', 'IFN', NULL, 0, 'smallint', 'CC', TRUE, TRUE, $$Numéro de sous-placette$$, $$Numéro de la sous-placette de décompte des individus non recensables$$);

INSERT INTO metaifn.afformat (format, famille, proprietaire, ftype, libelle, definition, pformat) VALUES ('TG3ESP_REGE', 'INV_EXP_NM', 'IFN', 'TABLE', 'Espèce non recensable de régénération en forêt', 'Espèce non recensable de régénération en forêt', 'G3ESP_REGE');
INSERT INTO metaifn.afformat (format, famille, proprietaire, ftype, libelle, definition, pformat) VALUES ('TP3ESP_REGE', 'INV_EXP_NM', 'IFN', 'TABLE', 'Espèce non recensable de régénération en peupleraie', 'Espèce non recensable de régénération en peupleraie', 'P3ESP_REGE');

SELECT * FROM metaifn.ajoutchamp('npp', 'g3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'bpchar', 16);
SELECT * FROM metaifn.ajoutchamp('nsp', 'g3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'int2', 2);
SELECT * FROM metaifn.ajoutchamp('espar', 'g3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'varchar', 4);
SELECT * FROM metaifn.ajoutchamp('chnr', 'g3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('brou', 'g3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('frot', 'g3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('nt', 'g3esp_rege', 'inv_exp_nm', FALSE, 18, NULL, 'int2', 2);
SELECT * FROM metaifn.ajoutchamp('pds', 'g3esp_rege', 'inv_exp_nm', FALSE, 18, NULL, 'int2', 2);
SELECT * FROM metaifn.ajoutchamp('w', 'g3esp_rege', 'inv_exp_nm', FALSE, 18, NULL, 'float8', 8);
SELECT * FROM metaifn.ajoutchamp('libnr', 'g3esp_rege', 'inv_exp_nm', FALSE, 18, NULL, 'bpchar', 1);

SELECT * FROM metaifn.ajoutchamp('npp', 'p3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'bpchar', 16);
SELECT * FROM metaifn.ajoutchamp('nsp', 'p3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'int2', 2);
SELECT * FROM metaifn.ajoutchamp('espar', 'p3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'varchar', 4);
SELECT * FROM metaifn.ajoutchamp('chnr', 'p3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('brou', 'p3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('frot', 'p3esp_rege', 'inv_exp_nm', TRUE, 18, NULL, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('nt', 'p3esp_rege', 'inv_exp_nm', FALSE, 18, NULL, 'int2', 2);
SELECT * FROM metaifn.ajoutchamp('pds', 'p3esp_rege', 'inv_exp_nm', FALSE, 18, NULL, 'int2', 2);
SELECT * FROM metaifn.ajoutchamp('w', 'p3esp_rege', 'inv_exp_nm', FALSE, 18, NULL, 'float8', 8);
SELECT * FROM metaifn.ajoutchamp('libnr', 'p3esp_rege', 'inv_exp_nm', FALSE, 18, NULL, 'bpchar', 1);

INSERT INTO metaifn.aflot (lot, proprietaire, operation, formation, libelle, definition, lotsup)
VALUES ('EXP_G3ER', 'IFN', 'EX', 14, 'ESPECES DE REGENERATION EN FORET', 'ESPECES NON RECENSABLES DE REGENERATION EN FORET EN BASE D''EXPLOITATION', 'EXP_G3F'),
('EXP_P3ER', 'IFN', 'EX', 14, 'ESPECES DE REGENERATION EN PEUPLERAIE', 'ESPECES NON RECENSABLES DE REGENERATION EN PEUPLERAIE EN BASE D''EXPLOITATION', 'EXP_P3');

INSERT INTO metaifn.afdetaillot (lot, format, famille)
VALUES ('EXP_G3ER', 'TG3ESP_REGE', 'INV_EXP_NM'),
('EXP_P3ER', 'TP3ESP_REGE', 'INV_EXP_NM');


-- chargement des tables d'INV_EXP_NM à partir de PROD_EXP
INSERT INTO inv_exp_nm.g3esp_rege (npp, nsp, espar, chnr, brou, frot, nt, pds, w, libnr)
SELECT er.npp, er.nsnr AS nsp, er.espar, er.chnr
, ((COUNT(*) FILTER (WHERE er.nbrou > 0 OR nmixt > 0)) > 0)::int4::text AS brou
, ((COUNT(*) FILTER (WHERE er.nfrot > 0 OR nmixt > 0)) > 0)::int4::text AS frot
, SUM(nint + nbrou + nfrot + nmixt) AS nt
, CASE  WHEN pf.dispnr = '0' THEN 0 -- ne doit pas se produire
        WHEN pf.dispnr IN ('1', '2') THEN 2
        WHEN pf.dispnr = '3' THEN 1
        ELSE NULL -- ne doit pas se produire non plus
  END AS pds
, (CASE  WHEN pf.dispnr = '0' THEN 0 -- ne doit pas se produire
        WHEN pf.dispnr IN ('1', '2') THEN 2
        WHEN pf.dispnr = '3' THEN 1
        ELSE NULL -- ne doit pas se produire non plus
  END) * 10000 / (2 * 2 * pi()) AS w
, r.libnr_sp AS libnr
FROM prod_exp.g3esp_renouv er
INNER JOIN prod_exp.g3foret pf USING (npp)
INNER JOIN prod_exp.g3renouv r USING (npp, nsnr)
INNER JOIN inv_exp_nm.g3foret f USING (npp)
WHERE f.incref = 18
GROUP BY npp, nsp, espar, chnr, dispnr, libnr_sp;

INSERT INTO inv_exp_nm.p3esp_rege (npp, nsp, espar, chnr, brou, frot, nt, pds, w, libnr)
SELECT er.npp, er.nsnr AS nsp, er.espar, er.chnr
, ((COUNT(*) FILTER (WHERE er.nbrou > 0 OR nmixt > 0)) > 0)::int4::text AS brou
, ((COUNT(*) FILTER (WHERE er.nfrot > 0 OR nmixt > 0)) > 0)::int4::text AS frot
, SUM(nint + nbrou + nfrot + nmixt) AS nt
, CASE  WHEN pf.dispnr = '0' THEN 0 -- ne doit pas se produire
        WHEN pf.dispnr IN ('1', '2') THEN 2
        WHEN pf.dispnr = '3' THEN 1
        ELSE NULL -- ne doit pas se produire non plus
  END AS pds
, (CASE  WHEN pf.dispnr = '0' THEN 0 -- ne doit pas se produire
        WHEN pf.dispnr IN ('1', '2') THEN 2
        WHEN pf.dispnr = '3' THEN 1
        ELSE NULL -- ne doit pas se produire non plus
  END) * 10000 / (2 * 2 * pi()) AS w
, r.libnr_sp AS libnr
FROM prod_exp.p3esp_renouv er
INNER JOIN prod_exp.p3point pf USING (npp)
INNER JOIN prod_exp.p3renouv r USING (npp, nsnr)
INNER JOIN inv_exp_nm.p3point f USING (npp)
WHERE f.incref = 18
GROUP BY npp, nsp, espar, chnr, dispnr, libnr_sp;

-- Ajout de la donnée TCNR dans G3FORET et P3POINT
ALTER TABLE inv_exp_nm.g3foret ADD COLUMN tcnr VARCHAR(2);
ALTER TABLE inv_exp_nm.p3point ADD COLUMN tcnr VARCHAR(2);

UPDATE inv_exp_nm.g3foret f
SET tcnr = pef.tcnr
FROM prod_exp.g3foret pef
WHERE f.npp = pef.npp
AND f.incref = 18
AND pef.tcnr IS NOT NULL;

UPDATE inv_exp_nm.p3point p
SET tcnr = pep.tcnr
FROM prod_exp.p3point pep
WHERE p.npp = pep.npp
AND p.incref = 18
AND pep.tcnr IS NOT NULL;

-- Documentation dans MetaIFN
SELECT * FROM metaifn.ajoutchamp('tcnr', 'g3foret', 'inv_exp_nm', FALSE, 18, NULL, 'varchar', 2);
SELECT * FROM metaifn.ajoutchamp('tcnr', 'p3point', 'inv_exp_nm', FALSE, 18, NULL, 'varchar', 2);

