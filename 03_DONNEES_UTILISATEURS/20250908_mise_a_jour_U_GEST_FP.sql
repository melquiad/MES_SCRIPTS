-- Création donnée U_GEST_FP 

-- Renseignement des métadonnées
BEGIN;

SELECT *
FROM metaifn.ajoutdonnee('U_GEST_FP', NULL, 'GEST', 'AUTRE', NULL, 3, 'char(1)', 'CC', TRUE, TRUE, 'Traces de gestion - forêt production et peupleraie',
						'Indicateur du niveau de gestion et/ou d''exploitation actuelle du peuplement. Identique à la donnée GEST pour la forêt de production'
						);

SELECT * 
FROM metaifn.ajoutchamp('U_GEST_FP', 'U_G3FORET', 'INV_EXP_NM',
FALSE, 3, 19, 'bpchar', 1);

SELECT * 
FROM metaifn.ajoutchamp('U_GEST_FP', 'U_P3POINT', 'INV_EXP_NM',
FALSE, 3, 19, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 3, calcout = 19, validin = 3, validout = 19, defout = 19
WHERE famille = 'INV_EXP_NM'
AND donnee = 'U_GEST_FP';

INSERT INTO utilisateur.autorisation_groupe_donnee(groupe,
donnee) 
VALUES ('IFN', 'U_GEST_FP');

COMMIT;

-- Calcul en forêt de production
BEGIN;
--ROLLBACK;

ALTER TABLE inv_exp_nm.u_g3foret
ADD COLUMN u_gest_fp CHAR(1);

UPDATE inv_exp_nm.u_g3foret ug3f
SET u_gest_fp = gest
FROM inv_exp_nm.g3foret g3f
WHERE g3f.npp = ug3f.npp and ug3f.incref >= 3
;

-- Contrôle

select ug3f.incref, count(*)
from inv_exp_nm.u_g3foret ug3f
inner join inv_exp_nm.g3foret g3f on g3f.npp = ug3f.npp
where u_gest_fp = gest and ug3f.incref >= 3
group by ug3f.incref order by ug3f.incref desc;

select gest, u_gest_fp
from inv_exp_nm.u_g3foret ug3f
inner join inv_exp_nm.g3foret g3f on g3f.npp = ug3f.npp
where ug3f.incref = '18' limit 100;

select distinct u_gest_fp
from inv_exp_nm.u_g3foret
where incref >= 3

COMMIT;

-- Calcul en peupleraie
BEGIN;

ALTER TABLE inv_exp_nm.u_p3point
ADD COLUMN u_gest_fp CHAR(1)

UPDATE inv_exp_nm.u_p3point
SET u_gest_fp = '2'
WHERE incref >= 3
;

-- Contrôle

select distinct u_gest_fp
from inv_exp_nm.u_p3point
where incref >= 3
;

select u_gest_fp
from inv_exp_nm.u_p3point
where incref >= 3
;

COMMIT;

