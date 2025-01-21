
-- Suppression des données U_DIST_BDEM et U_USAGE_HIST

DELETE FROM metaifn.abgroupe WHERE unite IN ('U_USAGE_HIST');

DELETE FROM metaifn.abmode WHERE unite IN ('U_DIST_BDEM','U_USAGE_HIST');

DELETE FROM metaifn.afchamp WHERE donnee IN ('U_DIST_BDEM','U_USAGE_HIST');

DELETE FROM metaifn.addonnee WHERE donnee IN ('U_DIST_BDEM','U_USAGE_HIST');

DELETE FROM metaifn.abunite WHERE unite IN ('U_DIST_BDEM','U_USAGE_HIST');



