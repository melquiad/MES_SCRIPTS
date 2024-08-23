

--SELECT unite, proprietaire, utype, libelle, definition
SELECT *
FROM metaifn.abunite
WHERE left(unite,5) = 'U_EFT';


--SELECT unite, mode, position, classe, etendue, libelle, definition
SELECT *
FROM metaifn.abmode
--WHERE left(unite,5) = 'U_EFT';
WHERE unite = 'U_EFT_HAB';


SELECT gunite, gmode, unite, mode
FROM metaifn.abgroupe
WHERE left(gunite,5) = 'U_EFT';