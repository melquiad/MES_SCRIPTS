
SELECT DISTINCT donnee , defin, defout, calcin, calcout, validin, validout 
FROM metaifn.afchamp a
WHERE defout < calcout
ORDER BY donnee;

SELECT donnee , defin, defout, calcin, calcout, validin, validout 
FROM metaifn.afchamp a
WHERE defout < calcout
ORDER BY donnee;