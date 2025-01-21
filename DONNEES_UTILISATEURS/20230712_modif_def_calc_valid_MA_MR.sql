-- Je joue ce script en base de test :

UPDATE metaifn.afchamp
SET calcin = 15, calcout = 17, validin = 16, validout = 17, defin = 15, defout = NULL 
WHERE famille = 'INV_EXP_NM'
AND donnee in ('MA','MR');


-- et celui-ci en base d’exploitation :

UPDATE metaifn.afchamp
SET calcin = 16, calcout = 17, validin = 16, validout = 17, defin = 16, defout = NULL 
WHERE famille = 'INV_EXP_NM'
AND donnee in ('MA','MR');
