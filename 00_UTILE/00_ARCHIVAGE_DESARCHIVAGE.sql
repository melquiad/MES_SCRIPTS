
-- désarchivage
UPDATE metaifn.afchamp
SET format = 'U_G3ARBRE', famille = 'INV_EXP_NM' 
WHERE famille = 'ARCHIVE'
AND format = 'ARCHIVE'
AND donnee IN ('U_AI1', 'U_AI2', 'U_AI3', 'U_AI4');


-- archivage
UPDATE metaifn.afchamp
SET format = 'ARCHIVE', famille = 'ARCHIVE'
WHERE famille = 'INV_EXP_NM'
AND format = 'U_G3ARBRE'
AND donnee IN ('U_AI1', 'U_AI2', 'U_AI3', 'U_AI4');
