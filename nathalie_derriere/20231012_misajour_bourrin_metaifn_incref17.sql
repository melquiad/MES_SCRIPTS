UPDATE metaifn.afchamp
SET calcout = 17, validout = 17
WHERE famille = 'INV_EXP_NM'
AND validout = 16;

SELECT *
FROM metaifn.afchamp
WHERE famille = 'INV_EXP_NM' AND calcout = 16;

