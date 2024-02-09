BEGIN;

-- CRÉATION DE L'ÉCHANTILLON ET DE LA STRATIFICATION ASSOCIÉE
INSERT INTO inv_exp_nm.famille_echantillon (code_famille_echantillon, libelle, description) 
VALUES ('INV_CHA', 'Inventaire PAT CHA', 'Inventaire PAT Chambaran');

INSERT INTO inv_exp_nm.famille_stratification (code_famille_stratification, code_famille_echantillon, libelle, description) 
VALUES ('INV_CHA', 'INV_CHA', 'Inventaire PAT CHA', 'Inventaire PAT Chambaran');

WITH new_ech AS (
    INSERT INTO inv_exp_nm.echantillon (nom_ech, type_enquete, type_unites, usite, site, surf_dom, deb_temp, fin_temp, proprietaire, phase_stat, taille_ech, cyc, incref, inv, code_famille_echantillon, famille, format)
    VALUES ('Inventaire PAT CHA', 'S', 'P', 'ZQ', 'X', 432910000, 2018, 2018, 'DIRNE', 2, 151, '5', 13, 'T', 'INV_CHA', 'INV_EXP_NM', 'TE2POINT')
    RETURNING id_ech
)
INSERT INTO inv_exp_nm.s5stratif (stratif, proprietaire, usite, libelle, definition, classe, id_ech, dsite, code_famille_stratification)
SELECT 'INV_CHA', 'AUTRE', 'ZQ', 'Stratification Inventaire PAT CHA', 'Stratification Inventaire PAT CHA', 1, id_ech, 'ZQ', 'INV_CHA'
FROM new_ech;

INSERT INTO utilisateur.autorisation_groupe_stratif (groupe, stratif)
VALUES ('DIRNE', 'INV_CHA');

COMMIT;

BEGIN;
-- CRÉATION DES STRATES ET DES VARIANCES ASSOCIÉES (NULLES)
INSERT INTO inv_exp_nm.s5strate (stratif, site, strate, surface, n_str, sumw, varsk, neqk)
VALUES 
 ('INV_CHA', 'X', 'CHT_TT', 57780000, 	1,	29, 0, 29)
,('INV_CHA', 'X', 'FEU_H1', 70200000, 	2,	24, 0, 24)
,('INV_CHA', 'X', 'FEU_H2', 107760000, 	3,	32, 0, 32)
,('INV_CHA', 'X', 'FEU_H3', 66810000, 	4,	24, 0, 24)
,('INV_CHA', 'X', 'FEU_H4', 95690000, 	5,	25, 0, 25)
,('INV_CHA', 'X', 'MIX_TT', 25430000, 	6,	26, 0, 26)
,('INV_CHA', 'X', 'RES_TT', 9240000, 	7,	38, 0, 38);


INSERT INTO inv_exp_nm.s5var (stratif, site, strate1, strate2, var)
VALUES 
  ('INV_CHA', 'X', 'CHT_TT', 'CHT_TT', 0) 
, ('INV_CHA', 'X', 'FEU_H1', 'FEU_H1', 0)
, ('INV_CHA', 'X', 'FEU_H2', 'FEU_H2', 0) 
, ('INV_CHA', 'X', 'FEU_H3', 'FEU_H3', 0) 
, ('INV_CHA', 'X', 'FEU_H4', 'FEU_H4', 0) 
, ('INV_CHA', 'X', 'MIX_TT', 'MIX_TT', 0) 
, ('INV_CHA', 'X', 'RES_TT', 'RES_TT', 0); 

COMMIT;


BEGIN;
-- IMPORT DES DONNÉES DE POINTS (E1POINT, E2POINT, U_E2POINT)
CREATE UNLOGGED TABLE public.cha_points (
    npp CHAR(9) PRIMARY KEY,
    datepoint DATE,
    leve CHAR(1),
    us_nm CHAR(1),
    csa VARCHAR(2),
    u_cha_dplct CHAR(1),
	u_clh3 VARCHAR(2),
    peupnr CHAR(1),
    comp3_r CHAR(1),
    ser_86 CHAR(3),
    alti NUMERIC,
    clalti VARCHAR(4),
    u_pro_psg CHAR(1),
	dca CHAR(1),
    esspre VARCHAR(2),
	sver CHAR(1),
    xl93 NUMERIC,
    yl93 NUMERIC,
	u_cha_strate VARCHAR(6),
    u_tfv_in VARCHAR(9),
	u_cha_zone CHAR(1)
);

\COPY cha_points FROM '/home/lhaugomat/Documents/MES_SCRIPTS/laura_gay/PAT_CHAMBARAN/donnees_integration_bd_placettes.csv' WITH CSV HEADER QUOTE '"' DELIMITER ',' NULL AS 'NA'  

COMMIT;

BEGIN;
ALTER TABLE cha_points
    ADD COLUMN geom GEOMETRY(POINT, 931007);

UPDATE cha_points
SET geom = ST_SetSRID(ST_MakePoint(xl93, yl93), 931007);

-- CROISEMENT CARTO AVEC carto_refifn.communes2002 POUR RECUPERER num_dep
ALTER TABLE cha_points ADD COLUMN dep CHAR(2);

WITH croise AS (
	SELECT s.npp
	, CASE
		WHEN i.gid IS NULL THEN 'NA' 
		ELSE i.num_dep
	END AS num_dep
	FROM cha_points s
	LEFT JOIN carto_refifn.communes2002 i
		ON ST_Intersects(i.geom, ST_Transform(s.geom, 910002))
)
UPDATE cha_points sp
SET dep = c.num_dep
FROM croise c
WHERE sp.npp = c.npp;

COMMIT;

BEGIN;

-- /!\ Changer le numéro pour id_unite avec le numero max actuellement dans la base /!\
INSERT INTO inv_exp_nm.e1point (npp, cyc, id_unite, dep, zp, incref, geom)
SELECT npp, '5', -1400000 - ROW_NUMBER() OVER(), dep, alti, 13, st_transform(geom, 910001)
FROM cha_points
ORDER BY npp;

-- /!\ Changer le numéro pour id_unite avec le numero max actuellement dans la base /!\
INSERT INTO inv_exp_nm.e2point (npp, dep, ser_86, datepoint, csa, us_nm, incref, cyc, info, leve, clalti, id_unite)
SELECT npp, dep, ser_86, datepoint, csa, us_nm, 13, '5', '3', leve, clalti, -1400000 - ROW_NUMBER() OVER()
FROM cha_points
ORDER BY npp;

SELECT npp, cyc, id_unite, dep, zp, incref, geom
FROM inv_exp_nm.e1point
where npp like '%CHA%';

SELECT npp, dep, ser_86, datepoint, csa, us_nm, incref, cyc, info, leve, clalti, id_unite
FROM inv_exp_nm.e2point
where npp like '%CHA%%';

ALTER TABLE inv_exp_nm.u_e2point
    ADD COLUMN u_cha_dplct CHAR(1), 
    ADD COLUMN u_cha_zone CHAR(1),
	ADD COLUMN u_cha_strate CHAR(6);

INSERT INTO inv_exp_nm.u_e2point (npp, incref, cyc, u_cha_dplct, u_cha_strate, u_cha_zone, u_pro_psg, u_inv_facon)
SELECT npp, 13, '5', u_cha_dplct, u_cha_strate, u_cha_zone, u_pro_psg, '1'
FROM cha_points ep
ORDER BY npp;

SELECT npp, incref, cyc, u_cha_dplct, u_cha_strate, u_cha_zone, u_pro_psg, u_inv_facon
FROM inv_exp_nm.u_e2point
where npp like '%CHA%';

COMMIT;

BEGIN;
-- CRÉATION DES UNITÉS D'ÉCHANTILLONNAGE ET RATTACHEMENT À LA STRATIFICATION
INSERT INTO inv_exp_nm.unite_ech (id_ech, id_unite, poids)
SELECT (SELECT id_ech FROM inv_exp_nm.echantillon WHERE nom_ech = 'Inventaire PAT CHA') AS id_ech
, p2.id_unite, 1 AS poids
FROM inv_exp_nm.e2point p2
INNER JOIN cha_points ap ON p2.npp = ap.npp
ORDER BY p2.id_unite;

INSERT INTO inv_exp_nm.s5stratech (stratif, site, strate, id_ech, id_unite)
SELECT 'INV_CHA', 'X', ap.u_cha_strate
, (SELECT id_ech FROM inv_exp_nm.echantillon WHERE nom_ech = 'Inventaire PAT CHA') AS id_ech
, p2.id_unite
FROM inv_exp_nm.e2point p2
INNER JOIN cha_points ap ON p2.npp = ap.npp
ORDER BY p2.id_unite;

COMMIT;

BEGIN;
-- DOCUMENTATION DES MÉTADONNÉES DE POINTS (U_E2POINT)

-- données à ajouter u_cha_nbm
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('U_CHA_DPLCT', 'AUTRE', 'NOMINAL', $$Déplacement du piquet repère PAT CHA$$, $$Déplacement du piquet repère (PAT Chambaran)$$), 
('U_CHA_STRATE', 'AUTRE', 'NOMINAL', $$Strate cartographique PAT CHA$$, $$Strate cartographique pour le PAT Chambaran$$), 
('U_CHA_ZONE', 'AUTRE', 'NOMINAL', 'Zone d''étude du PAT CHA', 'Zone d''étude du PAT Chambaran');

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('U_CHA_DPLCT','0', 1 , 1 , 1, 'Placette de levers non déplacée et complète', 'Placette de levers non déplacée et complète')
, ('U_CHA_DPLCT','1', 2 , 2 , 1, 'Placette de levers déplacée et complète', 'Placette de levers déplacée et complète')
, ('U_CHA_DPLCT','2', 3 , 3 , 1, 'Placette de levers non déplacée mais incomplète', 'Placette de levers non déplacée mais incomplète (mesure de DLIM en remarque)')
, ('U_CHA_DPLCT','3', 4 , 4 , 1, 'Placette de levers déplacée et incomplète', 'Placette de levers déplacée et incomplète (mesure de DLIM en remarque)')
, ('U_CHA_DPLCT','4', 5 , 5 , 1, 'Placette non réalisée (inaccessible)', 'Placette non réalisée (inaccessible)')
, ('U_CHA_STRATE', 'CHT_TT', 1, 1, 1, 'FEU_CHT_0-Inf_TOT',	'Peuplements de châtaignier, toutes hauteurs')
, ('U_CHA_STRATE', 'FEU_H1', 2, 2, 1, 'FEU_TOT_0-10_TOT',	'Peuplements de feuillus de hauteur faible')
, ('U_CHA_STRATE', 'FEU_H2', 3, 3, 1, 'FEU_TOT_10-13_TOT',	'Peuplements de feuillus de hauteur moyenne')
, ('U_CHA_STRATE', 'FEU_H3', 4, 4, 1, 'FEU_TOT_13-15_TOT',	'Peuplements de feuillus de hauteur forte')
, ('U_CHA_STRATE', 'FEU_H4', 5, 5, 1, 'FEU_TOT_15-Inf_TOT',	'Peuplements de feuillus de hauteur très forte')
, ('U_CHA_STRATE', 'MIX_TT', 6, 6, 1, 'MIX_TOT_0-Inf_TOT',	'Peuplements mélangés')
, ('U_CHA_STRATE', 'RES_TT', 7, 7, 1, 'RES_TOT_0-Inf_TOT',	'Peuplements de résineux')
, ('U_CHA_STRATE', 'F_COUV', 8, 8, 1, 'Foret_ouverte',		'Peuplements à faible couvert arboré')
, ('U_CHA_STRATE', 'PEUPLE', 9, 9, 1, 'Peupleraie', 		'Peupleraie')
, ('U_CHA_STRATE', 'HORPAT', 10, 10, 1, 'Hors_PAT', 		'Forêts exclues du PAT')
, ('U_CHA_ZONE', '0', 1, 1, 1, 'Hors zone PAT', 'Hors zone PAT')
, ('U_CHA_ZONE', '1', 2, 2, 1, 'Dans zone PAT', 'Dans zone PAT');

SELECT * FROM metaifn.ajoutdonnee('U_CHA_DPLCT', NULL, 'U_CHA_DPLCT', 'AUTRE', NULL, 5, 'char(1)', 'CC', TRUE, TRUE, 'Déplacement du piquet repère PAT CHA', 'Déplacement du piquet repère (PAT Chambaran)');
SELECT * FROM metaifn.ajoutdonnee('U_CHA_STRATE', NULL, 'U_CHA_STRATE', 'AUTRE', NULL, 11, 'char(6)', 'CC', TRUE, TRUE, 'Strate cartographique PAT CHA', 'Strate cartographique pour le PAT Chambaran');
SELECT * FROM metaifn.ajoutdonnee('U_CHA_ZONE', NULL, 'U_CHA_ZONE', 'AUTRE', NULL, 2, 'char(1)', 'CC', TRUE, TRUE, 'Zone d''étude du PAT CHA', 'Zone d''étude du PAT Chambaran');

SELECT * FROM metaifn.ajoutchamp('U_CHA_DPLCT', 'U_E2POINT', 'INV_EXP_NM', FALSE, 13, 13, 'bpchar', 1);
SELECT * FROM metaifn.ajoutchamp('U_CHA_STRATE', 'U_E2POINT', 'INV_EXP_NM', FALSE, 13, 13, 'bpchar', 6);
SELECT * FROM metaifn.ajoutchamp('U_CHA_ZONE', 'U_E2POINT', 'INV_EXP_NM', FALSE, 13, 13, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 13, calcout = 13, validin = 13, validout = 13
WHERE famille ~~* 'inv_exp_nm'
AND donnee ~* 'U_CHA_DPLCT|U_CHA_STRATE|U_CHA_ZONE';

INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('DIRNE', 'U_CHA_DPLCT')
, ('DIRNE', 'U_CHA_STRATE')
, ('DIRNE', 'U_CHA_ZONE');

COMMIT;


BEGIN;

-- IMPORT DES DONNÉES DE NIVEAU PEUPLEMENT (G3FORET ET U_G3FORET)
INSERT INTO inv_exp_nm.g3foret (npp, incref, cyc, peupnr, comp3_r, dca, esspre, sver)
SELECT npp, 13, '5', peupnr, comp3_r, dca, esspre, sver
FROM CHA_points
WHERE us_nm IN ('1', '2')
AND leve = '1'
ORDER BY npp;

-- ALTER TABLE inv_exp_nm.u_g3foret
    -- ADD COLUMN u_cha_nbm SMALLINT;

INSERT INTO inv_exp_nm.u_g3foret (npp, incref, cyc, u_clh3, u_tfv_in)
SELECT npp, 13, '5', u_clh3, u_tfv_in
FROM cha_points
WHERE us_nm IN ('1', '2')
AND leve = '1'
ORDER BY npp;

SELECT npp, incref, cyc, peupnr, comp3_r, dca, esspre, sver
FROM inv_exp_nm.g3foret
WHERE npp like '%CHA%';

SELECT npp, incref, cyc, u_clh3, u_tfv_in
FROM inv_exp_nm.u_g3foret
WHERE npp like '%CHA%';

DROP TABLE public.cha_points; 

COMMIT;
ROLLBACK;

-- Calcul de la donnée EXPL
BEGIN;

UPDATE inv_exp_nm.g3foret
SET dist = '0'
WHERE npp LIKE '23CHA%'
AND iti = '0';

UPDATE inv_exp_nm.g3foret
SET pentexp_0x =
CASE
	WHEN pentexp = 'X' THEN '0'
	ELSE pentexp
END
WHERE npp LIKE '23CHA%';

UPDATE inv_exp_nm.p3point
SET pentexp_0x =
CASE
	WHEN pentexp = 'X' THEN '0'
	ELSE pentexp
END
WHERE npp LIKE '23CHA%';

UPDATE inv_exp_nm.g3foret
SET portance_2x =
CASE
	WHEN portance = 'X' THEN '2'
	ELSE portance
END
, asperite_0x =
CASE
	WHEN asperite = 'X' THEN '0'
	ELSE asperite
END
WHERE npp LIKE '23CHA%';

UPDATE inv_exp_nm.p3point
SET portance_2x =
CASE
	WHEN portance = 'X' THEN '2'
	ELSE portance
END
, asperite_0x =
CASE
	WHEN asperite = 'X' THEN '0'
	ELSE asperite
END
WHERE npp LIKE '23CHA%';

UPDATE inv_exp_nm.g3foret
SET expl = 
CASE 
	WHEN iti IN ('2', '3') THEN '3'
	WHEN dist = '4' THEN '3'
	WHEN dist = '3' THEN 
CASE
	WHEN portance IN ('1', '2', 'X') AND asperite IN ('0', '1', 'X') AND pentexp IN ('0', 'X') THEN '2'
	ELSE '3'
	END
	WHEN dist IN ('1', '2') THEN
	CASE
		WHEN pentexp NOT IN ('0', '1', 'X') THEN '3'
		WHEN (portance = '0' OR asperite = '2') AND pentexp = '1' THEN '3'
		WHEN (portance = '0' OR asperite = '2') AND pentexp IN ('0', 'X') THEN '2'
		ELSE
		CASE
			WHEN pentexp = '1' THEN '2'
			ELSE '1'
		END
	END
	ELSE -- DIST = '0'
	CASE
		WHEN pentexp NOT IN ('0', '1', 'X') THEN '3'
		WHEN (portance = '0' OR asperite = '2') THEN '2'
		WHEN pentexp IN ('0', 'X') THEN '0'
		ELSE '1'
	END
END	
WHERE npp LIKE '23CHA%';


BEGIN;
-- DOCUMENTATION DES MÉTADONNÉES D'ARBRES (U_G3ARBRE)

SELECT * FROM metaifn.ajoutdonnee('U_CHA_Q1', NULL, '1', 'DIRNE', NULL, 0, 'real', 'LT', TRUE, FALSE, $$Taux de qualite 1$$, $$Taux de qualité 1 (PAT CHA)$$);
SELECT * FROM metaifn.ajoutdonnee('U_CHA_Q2', NULL, '1', 'DIRNE', NULL, 0, 'real', 'LT', TRUE, FALSE, $$Taux de qualite 2$$, $$Taux de qualité 2 (PAT CHA)$$);
SELECT * FROM metaifn.ajoutdonnee('U_CHA_Q3', NULL, '1', 'DIRNE', NULL, 0, 'real', 'LT', TRUE, FALSE, $$Taux de qualite 3$$, $$Taux de qualité 3 (PAT CHA)$$);
SELECT * FROM metaifn.ajoutdonnee('U_CHA_VR', NULL, 'm3', 'DIRNE', NULL, 0, 'float', 'LT', TRUE, FALSE, $$Volume de qualite 2$$, $$Volume de qualité 2 (PAT CHA)$$);
SELECT * FROM metaifn.ajoutdonnee('U_CHA_VBO', NULL, 'm3', 'DIRNE', NULL, 0, 'float', 'LT', TRUE, FALSE, $$Volume de bois d'œuvre$$, $$Volume de bois d'œuvre (PAT CHA)$$);

SELECT * FROM metaifn.ajoutchamp('U_CHA_Q1', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 13, 13, 'float4', 4);
SELECT * FROM metaifn.ajoutchamp('U_CHA_Q2', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 13, 13, 'float4', 4);
SELECT * FROM metaifn.ajoutchamp('U_CHA_Q3', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 13, 13, 'float4', 4);
SELECT * FROM metaifn.ajoutchamp('U_CHA_VR', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 13, 13, 'float8', 8);
SELECT * FROM metaifn.ajoutchamp('U_CHA_VBO', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 13, 13, 'float8', 8);

UPDATE metaifn.afchamp 
SET defin = 13, defout = 13, calcin = 13, calcout = 13, validin = 13, validout = 13 
WHERE donnee ~* 'U_CHA_Q1|U_CHA_Q2|U_CHA_Q3|U_CHA_VR|U_CHA_VBO';

INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('DIRNE', 'U_CHA_Q1')
     , ('DIRNE', 'U_CHA_Q2')
     , ('DIRNE', 'U_CHA_Q3')
     , ('DIRNE', 'U_CHA_VR')
     , ('DIRNE', 'U_CHA_VBO');

COMMIT;

-- IMPORT DES DONNÉES ARBRES (G3ARBRE ET U_G3ARBRE, G3MORTS ET U_G3MORTS)
BEGIN;

CREATE TABLE cha_arbres (
    npp CHAR(9),
    a SMALLINT,
    espar VARCHAR(4),
    c13 FLOAT8,
    veget CHAR(1),
    datemort CHAR(1),
    acci CHAR(1),
    ori CHAR(1),
    lib CHAR(1),
	q1 FLOAT4,
    q2 FLOAT4,
    q3 FLOAT4,
    r FLOAT4,
    ess CHAR(2),
    d13 FLOAT8,
    clad VARCHAR(3),
    clac VARCHAR(3),
    cld CHAR(2),
    clcir CHAR(2),
    w FLOAT8,
    wac FLOAT8,
    ir5 FLOAT8,
	gtot FLOAT8,
	fr CHAR(1),
    CONSTRAINT cha_arbres_pkey PRIMARY KEY (npp, a)
) ;

\COPY cha_arbres FROM '/home/lhaugomat/Documents/MES_SCRIPTS/laura_gay/PAT_CHAMBARAN/donnees_integration_bd_arbres.csv' WITH CSV HEADER QUOTE '"' DELIMITER ',' NULL AS 'NA' 

--DROP TABLE public.cha_arbres;

COMMIT;

BEGIN;

ALTER TABLE inv_exp_nm.u_g3arbre 
    ADD COLUMN u_cha_q1 FLOAT4, 
    ADD COLUMN u_cha_q2 FLOAT4, 
    ADD COLUMN u_cha_q3 FLOAT4,
    ADD COLUMN u_cha_vbo FLOAT8;


INSERT INTO inv_exp_nm.g3arbre (npp, incref, cyc, a, espar, c13, veget, acci, ori, lib, r, ess, d13, clad, clac, cld, clcir, w, wac, q1, q2, q3, gtot, ir5, fr)
SELECT npp, 13, '5', a, espar, c13, veget, acci, ori, lib, r, ess, d13, clad, clac, cld, clcir, w, wac, q1, q2, q3, gtot, ir5, fr
FROM cha_arbres
WHERE veget = '0'
ORDER BY npp, a;

INSERT INTO inv_exp_nm.u_g3arbre (npp, incref, cyc, a, u_cha_q1, u_cha_q2, u_cha_q3)
SELECT npp, 13, '5', a, q1, q2, q3
FROM cha_arbres
WHERE veget = '0'
ORDER BY npp, a;

INSERT INTO inv_exp_nm.g3morts (npp, incref, cyc, a, espar, c13, veget, datemort, ess, clad, clac, cld, w, wac, gtot, fr)
SELECT npp, 13, '5', a, espar, c13, veget, datemort, ess, clad, clac, cld, w, wac, gtot, fr
FROM cha_arbres
WHERE veget != '0'
ORDER BY npp, a;

INSERT INTO inv_exp_nm.u_g3morts (npp, incref, cyc, a)
SELECT npp, 13, '5', a
FROM cha_arbres
WHERE veget != '0'
ORDER BY npp, a;

DROP TABLE cha_arbres;

SELECT npp, incref, cyc, a, espar, c13, veget, acci, ori, lib, r, ess, d13, clad, clac, cld, clcir, w, wac, q1, q2, q3, gtot, ir5, fr
FROM inv_exp_nm.g3arbre
WHERE npp like '%CHA%'
ORDER BY npp, a;

SELECT npp, incref, cyc, a, u_cha_q1, u_cha_q2, u_cha_q3
FROM inv_exp_nm.u_g3arbre
WHERE npp like '%CHA%'
ORDER BY npp, a;

SELECT npp, incref, cyc, a, espar, c13, veget, datemort, ess, clad, clac, cld, w, wac, gtot, fr
FROM inv_exp_nm.g3morts
WHERE npp like '%CHA%'
ORDER BY npp, a;

SELECT npp, incref, cyc, a
FROM inv_exp_nm.u_g3morts
WHERE npp like '%CHA%'
ORDER BY npp, a;

COMMIT;

-- CALCULS DE DONNÉES ARBRES
-- calcul du volume des arbres vifs
BEGIN;

CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a
, 13 AS incref
, CASE
    WHEN up.u_pro_psg = '1' THEN '1'
    WHEN up.u_pro_psg = '2' THEN '2'
    ELSE '3'
  END AS pf_maaf
, CASE
    WHEN zp <600 THEN '0'::CHAR(1)
    WHEN zp >= 600 THEN '1'::CHAR(1)
    END AS alt2
, CASE
	WHEN ess LIKE '74' THEN 'I'
	ELSE LEFT(ser_86, 1) END AS greco
, g3a.ess, g3a.c13
, SUM(g3a.gtot * g3a.w) OVER (PARTITION BY g3a.npp) AS g
, NULL::FLOAT8 AS vest
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.e1point e1p ON e2p.npp = e1p.npp
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.npp = g3f.npp
INNER JOIN inv_exp_nm.g3arbre g3a ON g3f.npp = g3a.npp
INNER JOIN inv_exp_nm.u_e2point up ON e2p.npp = up.npp
WHERE g3a.npp LIKE '23CHA%'
ORDER BY npp, a;

ALTER TABLE arbres ADD CONSTRAINT pkarbre PRIMARY KEY (npp, a);
CREATE INDEX arbres_ess_idx ON arbres USING btree (ess);
ANALYZE arbres;

SELECT *
FROM arbres
WHERE ess LIKE '74';

CREATE TEMPORARY TABLE tarifs AS
SELECT DISTINCT TRIM(c.format) AS format, metaifn.mmfclasse(c.format) AS etendue, TRIM(c.ess) AS ess
, COALESCE(TRIM(ch.donnee), 'RIEN') AS donnee, COALESCE(ch.position, 0) AS position
, COALESCE(TRIM(d.unite), 'RIEN') AS unite
FROM prod_exp.c4tarifs t
INNER JOIN prod_exp.c4ctarif c USING (ntarif)
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif
LEFT JOIN metaifn.afchamp ch USING (format)
LEFT JOIN metaifn.addonnee d USING (donnee)
WHERE t.typtarif IN ('U1', 'U2')
AND a.incref = 13
ORDER BY TRIM(c.ess);

ALTER TABLE tarifs ADD CONSTRAINT pktarifs PRIMARY KEY (ess, position);
ANALYZE tarifs;

CREATE TEMPORARY TABLE unites AS
SELECT unite, mode, position
FROM metaifn.abmode
WHERE unite IN ('ALT2', 'PF_MAAF', 'GRECO')
ORDER BY unite, position;

ALTER TABLE unites ADD CONSTRAINT pkunites PRIMARY KEY (unite, mode);
ANALYZE unites;

CREATE TEMPORARY TABLE regroup AS
SELECT a.npp, a.a, a.incref, a.alt2, a.pf_maaf, a.greco, a.ess, a.c13, a.g
, t0.format AS format, t0.etendue AS etendue
, CASE t0.etendue   WHEN 0 THEN 0 
                    WHEN 1 THEN metaifn.mmfdomaine1(t0.format, u0.position)
                    WHEN 2 THEN metaifn.mmfdomaine2(t0.format, u0.position, u1.position)
                    WHEN 3 THEN metaifn.mmfdomaine3(t0.format, u0.position, u1.position, u2.position)
  END AS domaine
FROM arbres a
INNER JOIN tarifs t0 ON a.ess = t0.ess AND t0.position = 0
LEFT JOIN unites u0 ON t0.unite = u0.unite AND CASE t0.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u0.mode
LEFT JOIN tarifs t1 ON a.ess = t1.ess AND t1.position = 1
LEFT JOIN unites u1 ON t1.unite = u1.unite AND CASE t1.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u1.mode
LEFT JOIN tarifs t2 ON a.ess = t2.ess AND t2.position = 2
LEFT JOIN unites u2 ON t2.unite = u2.unite AND CASE t2.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u2.mode
ORDER BY a.npp, a.a;

ALTER TABLE regroup ADD CONSTRAINT pkregroup PRIMARY KEY (npp, a);
ANALYZE regroup;

CREATE TEMP TABLE coefs AS
SELECT c1.ess, c1.format, c1.domaine, t.ntarif, t.typtarif
, COALESCE(c1.coeftarif, 0::FLOAT) AS alpha
, COALESCE(c2.coeftarif, 0::FLOAT) AS beta
, COALESCE(c3.coeftarif, 0::FLOAT) AS gamma
, COALESCE(c4.coeftarif, 0::FLOAT) AS delta
, COALESCE(c5.coeftarif, 0::FLOAT) AS zeta
, COALESCE(c6.coeftarif, 0::FLOAT) AS eta
, COALESCE(c7.coeftarif, 0::FLOAT) AS sigma
FROM prod_exp.c4tarifs t
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif
LEFT JOIN prod_exp.c4ctarif c1 ON t.ntarif = c1.ntarif AND c1.nctarif = 1
LEFT JOIN prod_exp.c4ctarif c2 ON t.ntarif = c2.ntarif AND c2.nctarif = 2
LEFT JOIN prod_exp.c4ctarif c3 ON t.ntarif = c3.ntarif AND c3.nctarif = 3
LEFT JOIN prod_exp.c4ctarif c4 ON t.ntarif = c4.ntarif AND c4.nctarif = 4
LEFT JOIN prod_exp.c4ctarif c5 ON t.ntarif = c5.ntarif AND c5.nctarif = 5
LEFT JOIN prod_exp.c4ctarif c6 ON t.ntarif = c6.ntarif AND c6.nctarif = 6
LEFT JOIN prod_exp.c4ctarif c7 ON t.ntarif = c7.ntarif AND c7.nctarif = 7
WHERE t.typtarif IN ('U1', 'U2')
AND a.incref = 13
ORDER BY c1.ess, c1.format, c1.domaine, t.ntarif;

ALTER TABLE coefs ADD CONSTRAINT pkcoefs PRIMARY KEY (ntarif);
ANALYZE coefs;

CREATE TEMPORARY TABLE vols AS
SELECT g.npp, g.a, g.incref, g.ess, g.alt2, g.pf_maaf, g.greco
, EXP(
    c.alpha
    + c.beta * LN(g.c13)
    + c.gamma * (LN(g.c13))^2
    + c.delta * (LN(g.c13))^3
    + c.zeta * (LN(g.c13))^4
    + c.eta * LN(g.g)
    + c.sigma^2 / 2
) AS v13
FROM regroup g
INNER JOIN coefs c ON g.ess = c.ess AND g.format = c.format AND g.domaine = c.domaine
WHERE c.typtarif = 'U1'
UNION ALL
SELECT g.npp, g.a, g.incref, g.ess, g.alt2, g.pf_maaf, g.greco
, EXP(
    c.alpha
    + c.beta * LN(g.c13)
    + c.gamma * (LN(g.c13))^2
    + c.delta * (LN(g.c13))^3
    + c.zeta * (LN(g.c13))^4
    + c.eta * g.g
    + c.sigma^2 / 2
) AS v13
FROM regroup g
INNER JOIN coefs c ON g.ess = c.ess AND g.format = c.format AND g.domaine = c.domaine
WHERE c.typtarif = 'U2';

ALTER TABLE vols ADD CONSTRAINT pkvols PRIMARY KEY (npp, a);
ANALYZE vols;

UPDATE arbres a
SET vest = v.v13
FROM vols v
WHERE a.npp = v.npp AND a.a = v.a;

ANALYZE arbres;
SAVEPOINT point1;

--SELECT count(*) FROM arbres WHERE vest IS NULL;
ROLLBACK TO SAVEPOINT point1;

UPDATE inv_exp_nm.g3arbre g3a
SET v = a.vest * (1 - g3a.r)
FROM arbres a
WHERE g3a.npp = a.npp
AND g3a.a = a.a;

UPDATE inv_exp_nm.u_g3arbre ua
SET u_v13 = a.vest
FROM arbres a
WHERE ua.npp = a.npp
AND ua.a = a.a;

DROP TABLE arbres;
DROP TABLE tarifs;
DROP TABLE unites;
DROP TABLE regroup;
DROP TABLE coefs;
DROP TABLE vols;

COMMIT;

-- calcul du volume des arbres morts
-- ATTENTION, PLUTOT REPARTIR DE LA FONCTION calculvolarbrelnc13_mort_2015 DANS inv_exp_nm -- finalement on garde ??
BEGIN;
--ROLLBACK;
CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a
, 13 AS incref
, CASE
    WHEN up.u_pro_psg = '1' THEN '1'
    WHEN up.u_pro_psg = '2' THEN '2'
    ELSE '3'
  END AS pf_maaf
, CASE
    WHEN zp <600 THEN '0'::CHAR(1)
    WHEN zp >= 600 THEN '1'::CHAR(1)
    END AS alt2
, CASE
	WHEN ess LIKE '74' THEN 'I'
	ELSE LEFT(ser_86, 1) END AS greco
, g3a.ess, g3a.c13
, SUM(g3a.gtot * g3a.w) OVER (PARTITION BY g3a.npp) AS g
, NULL::FLOAT8 AS vest
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.e1point e1p ON e2p.npp = e1p.npp
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.npp = g3f.npp
INNER JOIN inv_exp_nm.g3morts g3a ON g3f.npp = g3a.npp
INNER JOIN inv_exp_nm.u_e2point up ON e2p.npp = up.npp
WHERE g3a.npp LIKE '23CHA%'
ORDER BY npp, a;

ALTER TABLE arbres ADD CONSTRAINT pkarbre PRIMARY KEY (npp, a);
CREATE INDEX arbres_ess_idx ON arbres USING btree (ess);
ANALYZE arbres;

CREATE TEMPORARY TABLE tarifs AS
SELECT DISTINCT TRIM(c.format) AS format, metaifn.mmfclasse(c.format) AS etendue, TRIM(c.ess) AS ess
, COALESCE(TRIM(ch.donnee), 'RIEN') AS donnee, COALESCE(ch.position, 0) AS position
, COALESCE(TRIM(d.unite), 'RIEN') AS unite
FROM prod_exp.c4tarifs t
INNER JOIN prod_exp.c4ctarif c USING (ntarif)
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif
LEFT JOIN metaifn.afchamp ch USING (format)
LEFT JOIN metaifn.addonnee d USING (donnee)
WHERE t.typtarif IN ('U1', 'U2')
AND a.incref = 13
ORDER BY TRIM(c.ess);

ALTER TABLE tarifs ADD CONSTRAINT pktarifs PRIMARY KEY (ess, position);
ANALYZE tarifs;

CREATE TEMPORARY TABLE unites AS
SELECT unite, mode, position
FROM metaifn.abmode
WHERE unite IN ('ALT2', 'PF_MAAF', 'GRECO')
ORDER BY unite, position;

ALTER TABLE unites ADD CONSTRAINT pkunites PRIMARY KEY (unite, mode);
ANALYZE unites;

CREATE TEMPORARY TABLE regroup AS
SELECT a.npp, a.a, a.incref, a.alt2, a.pf_maaf, a.greco, a.ess, a.c13, a.g
, t0.format AS format, t0.etendue AS etendue
, CASE t0.etendue   WHEN 0 THEN 0 
                    WHEN 1 THEN metaifn.mmfdomaine1(t0.format, u0.position)
                    WHEN 2 THEN metaifn.mmfdomaine2(t0.format, u0.position, u1.position)
                    WHEN 3 THEN metaifn.mmfdomaine3(t0.format, u0.position, u1.position, u2.position)
  END AS domaine
FROM arbres a
INNER JOIN tarifs t0 ON a.ess = t0.ess AND t0.position = 0
LEFT JOIN unites u0 ON t0.unite = u0.unite AND CASE t0.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u0.mode
LEFT JOIN tarifs t1 ON a.ess = t1.ess AND t1.position = 1
LEFT JOIN unites u1 ON t1.unite = u1.unite AND CASE t1.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u1.mode
LEFT JOIN tarifs t2 ON a.ess = t2.ess AND t2.position = 2
LEFT JOIN unites u2 ON t2.unite = u2.unite AND CASE t2.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u2.mode
ORDER BY a.npp, a.a;

ALTER TABLE regroup ADD CONSTRAINT pkregroup PRIMARY KEY (npp, a);
ANALYZE regroup;

CREATE TEMP TABLE coefs AS
SELECT c1.ess, c1.format, c1.domaine, t.ntarif, t.typtarif
, COALESCE(c1.coeftarif, 0::FLOAT) AS alpha
, COALESCE(c2.coeftarif, 0::FLOAT) AS beta
, COALESCE(c3.coeftarif, 0::FLOAT) AS gamma
, COALESCE(c4.coeftarif, 0::FLOAT) AS delta
, COALESCE(c5.coeftarif, 0::FLOAT) AS zeta
, COALESCE(c6.coeftarif, 0::FLOAT) AS eta
, COALESCE(c7.coeftarif, 0::FLOAT) AS sigma
FROM prod_exp.c4tarifs t
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif
LEFT JOIN prod_exp.c4ctarif c1 ON t.ntarif = c1.ntarif AND c1.nctarif = 1
LEFT JOIN prod_exp.c4ctarif c2 ON t.ntarif = c2.ntarif AND c2.nctarif = 2
LEFT JOIN prod_exp.c4ctarif c3 ON t.ntarif = c3.ntarif AND c3.nctarif = 3
LEFT JOIN prod_exp.c4ctarif c4 ON t.ntarif = c4.ntarif AND c4.nctarif = 4
LEFT JOIN prod_exp.c4ctarif c5 ON t.ntarif = c5.ntarif AND c5.nctarif = 5
LEFT JOIN prod_exp.c4ctarif c6 ON t.ntarif = c6.ntarif AND c6.nctarif = 6
LEFT JOIN prod_exp.c4ctarif c7 ON t.ntarif = c7.ntarif AND c7.nctarif = 7
WHERE t.typtarif IN ('U1', 'U2')
AND a.incref = 13
ORDER BY c1.ess, c1.format, c1.domaine, t.ntarif;

ALTER TABLE coefs ADD CONSTRAINT pkcoefs PRIMARY KEY (ntarif);
ANALYZE coefs;

CREATE TEMPORARY TABLE vols AS
SELECT g.npp, g.a, g.incref, g.ess, g.alt2, g.pf_maaf, g.greco
, EXP(
    c.alpha
    + c.beta * LN(g.c13)
    + c.gamma * (LN(g.c13))^2
    + c.delta * (LN(g.c13))^3
    + c.zeta * (LN(g.c13))^4
    + c.eta * LN(g.g)
    + c.sigma^2 / 2
) AS v13
FROM regroup g
INNER JOIN coefs c ON g.ess = c.ess AND g.format = c.format AND g.domaine = c.domaine
WHERE c.typtarif = 'U1'
UNION ALL
SELECT g.npp, g.a, g.incref, g.ess, g.alt2, g.pf_maaf, g.greco
, EXP(
    c.alpha
    + c.beta * LN(g.c13)
    + c.gamma * (LN(g.c13))^2
    + c.delta * (LN(g.c13))^3
    + c.zeta * (LN(g.c13))^4
    + c.eta * g.g
    + c.sigma^2 / 2
) AS v13
FROM regroup g
INNER JOIN coefs c ON g.ess = c.ess AND g.format = c.format AND g.domaine = c.domaine
WHERE c.typtarif = 'U2';

ALTER TABLE vols ADD CONSTRAINT pkvols PRIMARY KEY (npp, a);
ANALYZE vols;

UPDATE arbres a
SET vest = v.v13
FROM vols v
WHERE a.npp = v.npp AND a.a = v.a;

SELECT COUNT(*) FROM vols WHERE v13 is null;
SELECT COUNT(*) FROM arbres WHERE vest IS NULL;

SELECT * from arbres ;

ANALYZE arbres;

UPDATE inv_exp_nm.g3morts m
SET v = a.vest
FROM arbres a
WHERE m.npp = a.npp AND m.a = a.a;
---
DROP TABLE arbres;
DROP TABLE tarifs;
DROP TABLE unites;
DROP TABLE regroup;
DROP TABLE coefs;
DROP TABLE vols;

COMMIT;

-- calcul des donnees derivees du volume des arbres vifs
BEGIN;
--ROLLBACK;
SELECT r, v, vr, nt
FROM inv_exp_nm.g3arbre
WHERE npp LIKE '23CHA%';

UPDATE inv_exp_nm.g3arbre
SET vr = case when r != 1 then r * v / (1 - r) else 0 END, nt = 1
WHERE npp LIKE '23CHA%';

UPDATE inv_exp_nm.u_g3arbre ua
SET u_cha_vbo = CASE WHEN r != 1 THEN a.v * (u_cha_q1 + u_cha_q2) / (1 - r) END
FROM inv_exp_nm.g3arbre a
WHERE ua.npp = a.npp AND ua.a = a.a
AND (a.npp LIKE '23CHA%');

COMMIT;

BEGIN;
-- calcul des donnees derivees du volume des arbres morts
UPDATE inv_exp_nm.g3morts
SET xv_nm = CASE WHEN datemort = '2' THEN 0
                 WHEN datemort = '1' THEN v / 5
                 WHEN veget = 'A' THEN v / 5
            END
--, nt = CASE WHEN COALESCE(datemort, '1') = '1' THEN 1 ELSE 0 END
WHERE npp LIKE '23CHA%';

SAVEPOINT calcul_1;

-- calcul du C13_5 et RT_5
UPDATE inv_exp_nm.g3arbre ar
SET c13_5 = GREATEST(ar.c13 - (2 * PI() * ar.ir5) / (1 - 2 * PI() * c.coeftarif), 0)
FROM prod_exp.c4ctarif c 
INNER JOIN prod_exp.c4tarifs t ON c.ntarif = t.ntarif AND t.typtarif = 'E1'
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif AND a.incref = 10 AND format = 'DTOTAL' AND domaine = 0
WHERE ar.ess = c.ess
AND c.nctarif = 1
AND (ar.npp LIKE '23CHA%');

UPDATE inv_exp_nm.g3arbre
SET rt5 = CASE
            WHEN c13_5 < 0.235 THEN '1'
            ELSE '0'
        END
WHERE npp LIKE '23CHA%';

COMMIT;


BEGIN;
-- calcul du volume 5 ans avant (U_V13_5) 
CREATE TEMPORARY TABLE arbres AS
SELECT g3a.npp, g3a.a
, 13 AS incref
, CASE
    WHEN up.u_pro_psg = '1' THEN '1'
    WHEN up.u_pro_psg = '2' THEN '2'
    ELSE '3'
  END AS pf_maaf
, CASE
    WHEN zp <600 THEN '0'::CHAR(1)
    WHEN zp >= 600 THEN '1'::CHAR(1)
    END AS alt2
, CASE
	WHEN ess LIKE '74' THEN 'I'
	ELSE LEFT(ser_86, 1) END AS greco
, g3a.ess, g3a.c13_5
, SUM(g3a.gtot * g3a.w) OVER (PARTITION BY g3a.npp) AS g
, NULL::FLOAT8 AS vest
FROM inv_exp_nm.e2point e2p
INNER JOIN inv_exp_nm.e1point e1p ON e2p.npp = e1p.npp
INNER JOIN inv_exp_nm.g3foret g3f ON e2p.npp = g3f.npp
INNER JOIN inv_exp_nm.g3arbre g3a ON g3f.npp = g3a.npp
INNER JOIN inv_exp_nm.u_e2point up ON e2p.npp = up.npp
WHERE g3a.npp LIKE '23CHA%'
ORDER BY npp, a;

ALTER TABLE arbres ADD CONSTRAINT pkarbre PRIMARY KEY (npp, a);
CREATE INDEX arbres_ess_idx ON arbres USING btree (ess);
ANALYZE arbres;

CREATE TEMPORARY TABLE tarifs AS
SELECT DISTINCT TRIM(c.format) AS format, metaifn.mmfclasse(c.format) AS etendue, TRIM(c.ess) AS ess
, COALESCE(TRIM(ch.donnee), 'RIEN') AS donnee, COALESCE(ch.position, 0) AS position
, COALESCE(TRIM(d.unite), 'RIEN') AS unite
FROM prod_exp.c4tarifs t
INNER JOIN prod_exp.c4ctarif c USING (ntarif)
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif
LEFT JOIN metaifn.afchamp ch USING (format)
LEFT JOIN metaifn.addonnee d USING (donnee)
WHERE t.typtarif IN ('U1', 'U2')
AND a.incref = 13
ORDER BY TRIM(c.ess);

ALTER TABLE tarifs ADD CONSTRAINT pktarifs PRIMARY KEY (ess, position);
ANALYZE tarifs;

CREATE TEMPORARY TABLE unites AS
SELECT unite, mode, position
FROM metaifn.abmode
WHERE unite IN ('ALT2', 'PF_MAAF', 'GRECO')
ORDER BY unite, position;

ALTER TABLE unites ADD CONSTRAINT pkunites PRIMARY KEY (unite, mode);
ANALYZE unites;

CREATE TEMPORARY TABLE regroup AS
SELECT a.npp, a.a, a.incref, a.alt2, a.pf_maaf, a.greco, a.ess, a.c13_5, a.g
, t0.format AS format, t0.etendue AS etendue
, CASE t0.etendue   WHEN 0 THEN 0 
                    WHEN 1 THEN metaifn.mmfdomaine1(t0.format, u0.position)
                    WHEN 2 THEN metaifn.mmfdomaine2(t0.format, u0.position, u1.position)
                    WHEN 3 THEN metaifn.mmfdomaine3(t0.format, u0.position, u1.position, u2.position)
  END AS domaine
FROM arbres a
INNER JOIN tarifs t0 ON a.ess = t0.ess AND t0.position = 0
LEFT JOIN unites u0 ON t0.unite = u0.unite AND CASE t0.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u0.mode
LEFT JOIN tarifs t1 ON a.ess = t1.ess AND t1.position = 1
LEFT JOIN unites u1 ON t1.unite = u1.unite AND CASE t1.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u1.mode
LEFT JOIN tarifs t2 ON a.ess = t2.ess AND t2.position = 2
LEFT JOIN unites u2 ON t2.unite = u2.unite AND CASE t2.donnee WHEN 'ALT2' THEN a.alt2 WHEN 'PF_MAAF' THEN a.pf_maaf WHEN 'GRECO' THEN a.greco ELSE 'RIEN' END = u2.mode
ORDER BY a.npp, a.a;

ALTER TABLE regroup ADD CONSTRAINT pkregroup PRIMARY KEY (npp, a);
ANALYZE regroup;

CREATE TEMP TABLE coefs AS
SELECT c1.ess, c1.format, c1.domaine, t.ntarif, t.typtarif
, COALESCE(c1.coeftarif, 0::FLOAT) AS alpha
, COALESCE(c2.coeftarif, 0::FLOAT) AS beta
, COALESCE(c3.coeftarif, 0::FLOAT) AS gamma
, COALESCE(c4.coeftarif, 0::FLOAT) AS delta
, COALESCE(c5.coeftarif, 0::FLOAT) AS zeta
, COALESCE(c6.coeftarif, 0::FLOAT) AS eta
, COALESCE(c7.coeftarif, 0::FLOAT) AS sigma
FROM prod_exp.c4tarifs t
INNER JOIN prod_exp.c4aitarif a ON t.ntarif = a.ntarif
LEFT JOIN prod_exp.c4ctarif c1 ON t.ntarif = c1.ntarif AND c1.nctarif = 1
LEFT JOIN prod_exp.c4ctarif c2 ON t.ntarif = c2.ntarif AND c2.nctarif = 2
LEFT JOIN prod_exp.c4ctarif c3 ON t.ntarif = c3.ntarif AND c3.nctarif = 3
LEFT JOIN prod_exp.c4ctarif c4 ON t.ntarif = c4.ntarif AND c4.nctarif = 4
LEFT JOIN prod_exp.c4ctarif c5 ON t.ntarif = c5.ntarif AND c5.nctarif = 5
LEFT JOIN prod_exp.c4ctarif c6 ON t.ntarif = c6.ntarif AND c6.nctarif = 6
LEFT JOIN prod_exp.c4ctarif c7 ON t.ntarif = c7.ntarif AND c7.nctarif = 7
WHERE t.typtarif IN ('U1', 'U2')
AND a.incref = 13
ORDER BY c1.ess, c1.format, c1.domaine, t.ntarif;

ALTER TABLE coefs ADD CONSTRAINT pkcoefs PRIMARY KEY (ntarif);
ANALYZE coefs;

CREATE TEMPORARY TABLE vols AS
SELECT g.npp, g.a, g.incref, g.ess, g.alt2, g.pf_maaf, g.greco
, CASE
    WHEN c13_5 < 10^(-2) THEN 0
    ELSE EXP(
        c.alpha
        + c.beta * LN(g.c13_5)
        + c.gamma * (LN(g.c13_5))^2
        + c.delta * (LN(g.c13_5))^3
        + c.zeta * (LN(g.c13_5))^4
        + c.eta * LN(g.g)
        + c.sigma^2 / 2
    )
  END AS v13_5
FROM regroup g
INNER JOIN coefs c ON g.ess = c.ess AND g.format = c.format AND g.domaine = c.domaine
WHERE c.typtarif = 'U1'
UNION ALL
SELECT g.npp, g.a, g.incref, g.ess, g.alt2, g.pf_maaf, g.greco
, CASE
    WHEN c13_5 < 10^(-2) THEN 0
    ELSE EXP(
        c.alpha
        + c.beta * LN(g.c13_5)
        + c.gamma * (LN(g.c13_5))^2
        + c.delta * (LN(g.c13_5))^3
        + c.zeta * (LN(g.c13_5))^4
        + c.eta * LN(g.g)
        + c.sigma^2 / 2
    )
  END AS v13_5
FROM regroup g
INNER JOIN coefs c ON g.ess = c.ess AND g.format = c.format AND g.domaine = c.domaine
WHERE c.typtarif = 'U2';

ALTER TABLE vols ADD CONSTRAINT pkvols PRIMARY KEY (npp, a);
ANALYZE vols;

UPDATE arbres a
SET vest = v.v13_5
FROM vols v
WHERE a.npp = v.npp AND a.a = v.a;

ANALYZE arbres;

SAVEPOINT point1;

SELECT vest, c13_5 FROM arbres;

--SELECT count(*) FROM arbres WHERE vest IS NULL;

UPDATE inv_exp_nm.u_g3arbre ua
SET u_v13_5 = a.vest
FROM arbres a
WHERE ua.npp = a.npp
AND ua.a = a.a;

COMMIT;

DROP TABLE arbres;
DROP TABLE tarifs;
DROP TABLE unites;
DROP TABLE regroup;
DROP TABLE coefs;
DROP TABLE vols;


BEGIN; 
-- calcul de la production PV
UPDATE inv_exp_nm.g3arbre a3
SET pv = GREATEST(0.2 * 
CASE    WHEN a3.c13_5 < 0.235 THEN a3.v
        ELSE a3.v * (1 - u.u_v13_5 / u.u_v13)
END
, 0)
FROM inv_exp_nm.u_g3arbre u
WHERE a3.npp = u.npp AND a3.a = u.a
AND (a3.npp LIKE '23CHA%');

UPDATE inv_exp_nm.g3arbre
SET pv = 0
WHERE pv > 0 and pv < 0.000000001
AND (npp LIKE '23CHA%');

SELECT count(pv)
FROM inv_exp_nm.g3arbre
WHERE pv IS NOT NULL
AND npp LIKE '23CHA%';

COMMIT;


-- donnees u

BEGIN;
CREATE TABLE public.cha_arbres (
    npp CHAR(9),
    a SMALLINT,
	veget VARCHAR (1),
	cld VARCHAR (2),
	clcir VARCHAR (2),
	u_menu_bois FLOAT8,
	u_v0 FLOAT8,
	u_pv0 FLOAT8,
	u_xv0_nm FLOAT8,
	u_vbftot_r FLOAT8,
	u_cha_pvbft FLOAT8,
	u_cha_xvbft FLOAT8,
    CONSTRAINT cha_arbres_pkey PRIMARY KEY (npp, a)
) ;


\COPY public.cha_arbres FROM '/home/lhaugomat/Documents/MES_SCRIPTS/laura_gay/PAT_CHAMBARAN/donnees_integration_bd_arbres_bis.csv' WITH CSV HEADER QUOTE '"' DELIMITER ',' NULL AS 'NA' 

ALTER TABLE inv_exp_nm.u_g3arbre
    ADD COLUMN u_cha_pvbft FLOAT8;

ALTER TABLE inv_exp_nm.u_g3morts
    ADD COLUMN u_cha_xvbft FLOAT8;

UPDATE inv_exp_nm.u_g3arbre a
SET u_menu_bois = aa.u_menu_bois, u_v0 = aa.u_v0, u_pv0 = aa.u_pv0, u_vbftot = aa.u_vbftot_r
, u_cha_pvbft = aa.u_cha_pvbft
FROM cha_arbres aa
WHERE a.npp = aa.npp AND a.a = aa.a;

UPDATE inv_exp_nm.u_g3morts a
SET u_xv0_nm = aa.u_xv0_nm, u_cha_xvbft = aa.u_cha_xvbft
FROM cha_arbres aa
WHERE a.npp = aa.npp AND a.a = aa.a;

COMMIT;

BEGIN;
SELECT * FROM metaifn.ajoutdonnee('U_CHA_PVBFT', NULL, 'm3/an', 'DIRNE', NULL, 0, 'float8', 'LT', TRUE, FALSE, 'Production annuelle en volume en bois fort total', 'Production annuelle en volume en bois fort total (PAT CHA)');
SELECT * FROM metaifn.ajoutdonnee('U_CHA_XVBFT', NULL, 'm3/an', 'DIRNE', NULL, 0, 'float8', 'LT', TRUE, FALSE, 'Mortalité annuelle en volume bois fort total', 'Mortalité annuelle en volume bois fort total (PAT CHA)');

SELECT * FROM metaifn.ajoutchamp('U_CHA_PVBFT', 'U_G3ARBRE', 'INV_EXP_NM', FALSE, 13, 13, 'float8', 8);
SELECT * FROM metaifn.ajoutchamp('U_CHA_XVBFT', 'U_G3MORTS', 'INV_EXP_NM', FALSE, 13, 13, 'float8', 8);

UPDATE metaifn.afchamp 
SET defin = 13, defout = 13, calcin = 13, calcout = 13, validin = 13, validout = 13 
WHERE donnee ~* 'U_CHA_PVBFT|U_CHA_XVBFT';

INSERT INTO utilisateur.autorisation_groupe_donnee(groupe, donnee) 
VALUES ('DIRNE', 'U_CHA_PVBFT')
     , ('DIRNE', 'U_CHA_XVBFT');

COMMIT;

