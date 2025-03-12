-- Création donnée U_TAILFOR_CO
-- Calcul de la taille des massifs, unité continue

-- Documentation de la donnée

BEGIN;

SELECT *
FROM metaifn.ajoutdonnee('U_TAILFOR_CO', NULL, 'm2', 'AUTRE',
NULL, 0, 'float', 'CC', TRUE, TRUE, 'Taille polyg for BDV2 du point d''inv, donnee continue',
'Taille du polygone foret ds lequel se situe le point d''inventaire : basée sur la BDforetV2. Un polyg : fusion des polyg. adjacents de la BDforetV2. Donnee continue, equivalente à U_TAILFORET');

--Documentation de la colonne en base
SELECT *
FROM metaifn.ajoutchamp('U_TAILFOR_CO', 'U_E2POINT', 'INV_EXP_NM',
FALSE, 0, 18, 'float8', 1);

-- Affectation à un groupe d'utilisateurs
INSERT INTO utilisateur.autorisation_groupe_donnee(groupe,
donnee)
VALUES ('DIRSO', 'U_TAILFOR_CO');

--Création de la donnée U
ALTER TABLE inv_exp_nm.u_e2point
ADD COLUMN U_TAILFOR_CO FLOAT;

COMMIT;

-- 2. Calcul de la donnée : création des différentes classes
DROP TABLE IF EXISTS public.croise;

CREATE TABLE public.croise (
	npp TEXT,
	id TEXT,
	id_massif TEXT,
	surf_ilot_bdforet_ha FLOAT8);

\COPY public.croise FROM '~/Documents/ECHANGES/MES_SCRIPTS/maxime_bellifa/ptsilots.csv' WITH CSV HEADER DELIMITER ',' NULL AS '';

BEGIN;
--ROLLBACK;

SELECT ROUND(surf_ilot_bdforet_ha)
from public.croise
LIMIT 100;

UPDATE inv_exp_nm.u_e2point p
SET U_TAILFOR_CO = ROUND(10000*c.surf_ilot_bdforet_ha)
FROM croise c
WHERE p.npp = c.npp;

SELECT incref, COUNT(U_TAILFOR_CO)
FROM INV_EXP_NM.U_E2POINT
WHERE U_TAILFOR_CO IS NOT NULL
GROUP BY incref ORDER BY incref;


UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18, defin = 0, defout = 18
WHERE famille = 'INV_EXP_NM'
AND format IN ('U_E2POINT')
AND donnee = 'U_TAILFOR_CO';

COMMIT;