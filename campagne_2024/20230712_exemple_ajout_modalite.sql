- POINTS NOUVEAUX
-- Nouvelles modalités sur HUMUS
INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
SELECT 'HUMUS22', 'IFN', 'NOMINAL', libelle, definition || ' (version 2022)'
FROM metaifn.abunite
WHERE unite = 'HUMUS';

WITH hum AS (
    SELECT 'HUMUS22' AS unite, "mode", libelle, definition
    FROM metaifn.abmode
    WHERE unite = 'HUMUS'
    UNION 
    SELECT *
    FROM ( VALUES 
        ('HUMUS22', '47', $$hydromull carbonaté$$, $$Humus hydromorphe et carbonaté. Horizon Oln discontinu (ou peu épais en hiver), horizon A1 de structure grumeleuse marqué par des taches rouille d hydromorphie (souvent en gaines autour des racines), souvent épais et quelquefois très humifère.$$),
        ('HUMUS22', '85', $$anmoor carbonaté$$, $$Humus hydromorphe et carbonaté. Horizon Ol peu épais reposant sur un horizon A1 noir épais (10 à 30 cm environ), gras, à structure massive à l'état humide, grumeleuse à l'état sec.$$),
        ('HUMUS22', '26', $$moder calcique$$, $$Humus de type moder, épais, sur sol jeune calcique (Tangel)$$),
        ('HUMUS22', '29', $$peyromoder$$, $$Humus très caillouteux (CAILLOUX>= 7 dans l horizon A ), acide avec OH net$$),
        ('HUMUS22', '49', $$peyromull$$, $$Humus très caillouteux (CAILLOUX>= 7  dans l horizon A), neutro à acidicline sans OH$$)
    ) AS t (unite, "mode", libelle, definition)
)
INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
SELECT unite, "mode", RANK() OVER (ORDER BY "mode") AS "position", RANK() OVER (ORDER BY "mode") AS "classe", 1 AS etendue, libelle, definition
FROM hum
ORDER BY "mode";

INSERT INTO metaifn.aiunite (usite, site, cyc, incref, inv, unite, dcunite)
SELECT 'P', 'F', '5', i, 'T', 'HUMUS', 'HUMUS'
FROM generate_series(0, 16) i
UNION 
SELECT 'P', 'F', '5', 17, 'T', 'HUMUS', 'HUMUS22'
ORDER BY i;

UPDATE metaifn.addonnee
SET codage = 0::BIT
WHERE donnee = 'HUMUS';