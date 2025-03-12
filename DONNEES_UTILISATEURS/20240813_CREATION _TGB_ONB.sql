----------------- CREATION ---------------------------------

BEGIN;

ALTER TABLE inv_exp_nm.g3arbre ADD COLUMN tgb_onb CHAR(1);

SET enable_nestloop = FALSE;

/*
-- recopie de la donnée U_TGB_ONB depuis la table U_G3ARBRE
UPDATE inv_exp_nm.g3arbre g
SET tgb_onb = ua.u_tgb_onb
FROM inv_exp_nm.u_g3arbre ua
WHERE g.incref BETWEEN 13 AND 17;
*/

CREATE TEMPORARY TABLE type_bio
(
espar VARCHAR(80),
type_bio VARCHAR(80)
);

INSERT INTO type_bio VALUES
('29AI','macro'), ('23AB','meso'), ('23AF','meso'), ('23AM','meso'), ('41','meso'), ('23A','micro'), ('40','micro'), ('49CS','meso'), ('49AA','meso'), ('49AE','micro'), ('49AM','meso'), ('13B','meso'), ('13C','macro')
, ('13G','macro'), ('37','micro'), ('12P','meso'), ('12V','macro'), ('49BO','meso'), ('49EA','micro'), ('49BS','meso'), ('65','macro'), ('76','macro'), ('22C','micro'), ('22G','meso'), ('49PM','meso'), ('22S','meso')
, ('11','meso'), ('32','meso'), ('10','macro'), ('34','macro'), ('29CM','macro'), ('02','macro'), ('05','macro'), ('04','macro'), ('03','macro'), ('07','meso'), ('06','meso'), ('08S','macro'), ('49C','micro'), ('23C','macro')
, ('39','micro'), ('68CJ','macro'), ('68CC','macro'), ('68CM','macro'), ('68CL','macro'), ('66','macro'), ('38AU','micro'), ('38AL','micro'), ('64','macro'), ('62','macro'), ('73','macro'), ('68EO','macro'), ('21O','meso')
, ('21C','meso'), ('21M','meso'), ('29EN','meso'), ('15P','macro'), ('15S','macro'), ('36','macro'), ('23F','meso'), ('49FL','micro'), ('29FI','macro'), ('17F','meso'), ('17C','macro'), ('17O','macro'), ('49EV','micro')
, ('69JC','micro'), ('69JO','micro'), ('69','meso'), ('09','macro'), ('49IA','meso'), ('67','macro'), ('49LN','meso'), ('29LI','macro'), ('29MA','macro'), ('63','macro'), ('74J','macro'), ('74H','macro'), ('22M','macro'), ('16','meso')
, ('29MI','meso'), ('49MB','meso'), ('49RA','micro'), ('49RP','macro'), ('49RC','micro'), ('31','micro'), ('27C','macro'), ('27N','macro'), ('28','meso'), ('49CA','macro'), ('18C','macro'), ('18M','macro'), ('18D','macro')
, ('33B','macro'), ('19','macro'), ('33G','macro'), ('33N','macro'), ('58','macro'), ('77','macro'), ('57B','macro'), ('59','macro'), ('57A','macro'), ('68PM','macro'), ('68PC','macro'), ('53S','macro'), ('53CA','macro'), ('53CO','macro')
, ('51','macro'), ('54','macro'), ('55','macro'), ('52','macro'), ('56','macro'), ('49PL','nano'), ('49PT','nano'), ('26E','macro'), ('26OC','macro'), ('23PA','micro'), ('23PF','micro'), ('23PC','meso'), ('23PM','meso')
, ('49PC','micro'), ('49PS','micro'), ('49PB','micro'), ('23PD','micro'), ('14','macro'), ('70SE','macro'), ('70SC','macro'), ('71','macro'), ('72V','macro'), ('68SC','macro'), ('72N','macro'), ('25B','macro'), ('25FR','macro')
, ('25C','micro'), ('25V','meso'), ('25D','micro'), ('25FD','meso'), ('25M','meso'), ('25R','micro'), ('68SV','macro'), ('23SS','meso'), ('23SO','meso'), ('49RT','meso'), ('49SN','meso'), ('49SR','micro'), ('49TF','micro'), ('49TA','micro')
, ('68TG','macro'), ('20G','macro'), ('20P','macro'), ('20X','macro'), ('24','macro'), ('68TH','macro'), ('42','macro'), ('49PA','micro'), ('29AF','macro'), ('68CE','macro'), ('29CA','micro'), ('29CT','meso'), ('49CM','micro')
, ('68CB','macro'), ('68CH','macro'), ('29CE','macro'), ('08P','macro'), ('68CA','meso'), ('49FA','micro'), ('29FA','meso'), ('49KK','meso'), ('49CN','micro'), ('49MC','micro'), ('49MN','micro'), ('49OB','meso'), ('49OO','meso')
, ('29PT','meso'), ('60','micro'), ('29PV','meso'), ('29PL','micro'), ('26OR','macro'), ('49PN','meso'), ('68SI','macro'), ('70SB','macro'), ('61','macro'), ('25E5','micro'), ('25E3','micro'), ('25P','micro'), ('25XR','meso'), ('68SG','macro')
, ('23SF','meso'), ('49TG','micro'), ('68TC','meso'), ('29TT','meso'), ('29TA','macro'), ('29TX','meso'), ('68TS','macro'), ('49VV','meso');

UPDATE inv_exp_nm.g3arbre ua
SET tgb_onb =  CASE
        WHEN p2.greco = 'J' OR p2.ser_86 IN ('K11', 'K13') THEN
        CASE
            WHEN tb.type_bio = 'macro' AND a.d13 >= 0.6 THEN '1'
            WHEN tb.type_bio = 'meso' AND a.d13 >= 0.325 THEN '1'
            WHEN tb.type_bio = 'micro' AND a.d13 >= 0.225 THEN '1'
        ELSE '0'
        END
    ELSE
        CASE
            WHEN tb.type_bio = 'macro' AND a.d13 >= 0.7 THEN '1'
            WHEN tb.type_bio = 'meso' AND a.d13 >= 0.45 THEN '1'
            WHEN tb.type_bio = 'micro' AND a.d13 >= 0.275 THEN '1'
        ELSE '0'
        END
    END
FROM inv_exp_nm.g3arbre AS a
INNER JOIN inv_exp_nm.e2point AS p2 ON a.npp = p2.npp
INNER JOIN type_bio AS tb ON a.espar = tb.espar
WHERE ua.npp = a.npp AND ua.a = a.a AND p2.incref <= 17;

-- documentation

INSERT INTO metaifn.abunite (unite, proprietaire, utype, libelle, definition)
VALUES ('TGB_ONB', 'IFN', 'NOMINAL', $$Très gros bois selon critères ONB$$, $$Arbre qualifié de très gros bois selon les critères de l'ONB$$);

INSERT INTO metaifn.abmode (unite, mode, position, classe, etendue, libelle, definition)
VALUES ('TGB_ONB', '0', 1, 1, 1, $$Arbre non TGB ONB$$, $$Arbre n'étant pas un TGB ONB$$)
, ('TGB_ONB', '1', 2, 2, 1, $$Arbre TGB ONB$$, $$Arbre TGB ONB$$);


SELECT * FROM metaifn.ajoutdonnee('TGB_ONB', NULL, 'TGB_ONB', 'IFN', NULL, 40, 'char(1)', 'CC', TRUE, TRUE, $$Très gros bois selon critères ONB$$, $$Arbre qualifié de très gros bois selon les critères de l ONB$$);                                                             

SELECT * FROM metaifn.ajoutchamp('TGB_ONB', 'G3ARBRE', 'INV_EXP_NM', FALSE, 0, 17, 'bpchar', 1);

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 17, validin = 0, validout = 17
WHERE famille = 'INV_EXP_NM'
AND donnee = 'TGB_ONB';

INSERT INTO utilisateur.autorisation_groupe_donnee (groupe, donnee) VALUES ('DIRSO', 'TGB_ONB');

COMMIT;



--------------------- MAJ incref 18 -----------------------------------------------------------------------
BEGIN;

CREATE TEMPORARY TABLE type_bio
(
espar VARCHAR(80),
type_bio VARCHAR(80)
);

INSERT INTO type_bio VALUES
('29AI','macro'), ('23AB','meso'), ('23AF','meso'), ('23AM','meso'), ('41','meso'), ('23A','micro'), ('40','micro'), ('49CS','meso'), ('49AA','meso'), ('49AE','micro'), ('49AM','meso'), ('13B','meso'), ('13C','macro')
, ('13G','macro'), ('37','micro'), ('12P','meso'), ('12V','macro'), ('49BO','meso'), ('49EA','micro'), ('49BS','meso'), ('65','macro'), ('76','macro'), ('22C','micro'), ('22G','meso'), ('49PM','meso'), ('22S','meso')
, ('11','meso'), ('32','meso'), ('10','macro'), ('34','macro'), ('29CM','macro'), ('02','macro'), ('05','macro'), ('04','macro'), ('03','macro'), ('07','meso'), ('06','meso'), ('08S','macro'), ('49C','micro'), ('23C','macro')
, ('39','micro'), ('68CJ','macro'), ('68CC','macro'), ('68CM','macro'), ('68CL','macro'), ('66','macro'), ('38AU','micro'), ('38AL','micro'), ('64','macro'), ('62','macro'), ('73','macro'), ('68EO','macro'), ('21O','meso')
, ('21C','meso'), ('21M','meso'), ('29EN','meso'), ('15P','macro'), ('15S','macro'), ('36','macro'), ('23F','meso'), ('49FL','micro'), ('29FI','macro'), ('17F','meso'), ('17C','macro'), ('17O','macro'), ('49EV','micro')
, ('69JC','micro'), ('69JO','micro'), ('69','meso'), ('09','macro'), ('49IA','meso'), ('67','macro'), ('49LN','meso'), ('29LI','macro'), ('29MA','macro'), ('63','macro'), ('74J','macro'), ('74H','macro'), ('22M','macro'), ('16','meso')
, ('29MI','meso'), ('49MB','meso'), ('49RA','micro'), ('49RP','macro'), ('49RC','micro'), ('31','micro'), ('27C','macro'), ('27N','macro'), ('28','meso'), ('49CA','macro'), ('18C','macro'), ('18M','macro'), ('18D','macro')
, ('33B','macro'), ('19','macro'), ('33G','macro'), ('33N','macro'), ('58','macro'), ('77','macro'), ('57B','macro'), ('59','macro'), ('57A','macro'), ('68PM','macro'), ('68PC','macro'), ('53S','macro'), ('53CA','macro'), ('53CO','macro')
, ('51','macro'), ('54','macro'), ('55','macro'), ('52','macro'), ('56','macro'), ('49PL','nano'), ('49PT','nano'), ('26E','macro'), ('26OC','macro'), ('23PA','micro'), ('23PF','micro'), ('23PC','meso'), ('23PM','meso')
, ('49PC','micro'), ('49PS','micro'), ('49PB','micro'), ('23PD','micro'), ('14','macro'), ('70SE','macro'), ('70SC','macro'), ('71','macro'), ('72V','macro'), ('68SC','macro'), ('72N','macro'), ('25B','macro'), ('25FR','macro')
, ('25C','micro'), ('25V','meso'), ('25D','micro'), ('25FD','meso'), ('25M','meso'), ('25R','micro'), ('68SV','macro'), ('23SS','meso'), ('23SO','meso'), ('49RT','meso'), ('49SN','meso'), ('49SR','micro'), ('49TF','micro'), ('49TA','micro')
, ('68TG','macro'), ('20G','macro'), ('20P','macro'), ('20X','macro'), ('24','macro'), ('68TH','macro'), ('42','macro'), ('49PA','micro'), ('29AF','macro'), ('68CE','macro'), ('29CA','micro'), ('29CT','meso'), ('49CM','micro')
, ('68CB','macro'), ('68CH','macro'), ('29CE','macro'), ('08P','macro'), ('68CA','meso'), ('49FA','micro'), ('29FA','meso'), ('49KK','meso'), ('49CN','micro'), ('49MC','micro'), ('49MN','micro'), ('49OB','meso'), ('49OO','meso')
, ('29PT','meso'), ('60','micro'), ('29PV','meso'), ('29PL','micro'), ('26OR','macro'), ('49PN','meso'), ('68SI','macro'), ('70SB','macro'), ('61','macro'), ('25E5','micro'), ('25E3','micro'), ('25P','micro'), ('25XR','meso'), ('68SG','macro')
, ('23SF','meso'), ('49TG','micro'), ('68TC','meso'), ('29TT','meso'), ('29TA','macro'), ('29TX','meso'), ('68TS','macro'), ('49VV','meso');

UPDATE inv_exp_nm.g3arbre ua
SET tgb_onb =  CASE
        WHEN p2.greco = 'J' OR p2.ser_86 IN ('K11', 'K13') THEN
        CASE
            WHEN tb.type_bio = 'macro' AND a.d13 >= 0.6 THEN '1'
            WHEN tb.type_bio = 'meso' AND a.d13 >= 0.325 THEN '1'
            WHEN tb.type_bio = 'micro' AND a.d13 >= 0.225 THEN '1'
        ELSE '0'
        END
    ELSE
        CASE
            WHEN tb.type_bio = 'macro' AND a.d13 >= 0.7 THEN '1'
            WHEN tb.type_bio = 'meso' AND a.d13 >= 0.45 THEN '1'
            WHEN tb.type_bio = 'micro' AND a.d13 >= 0.275 THEN '1'
        ELSE '0'
        END
    END
FROM inv_exp_nm.g3arbre AS a
INNER JOIN inv_exp_nm.e2point AS p2 ON a.npp = p2.npp
INNER JOIN type_bio AS tb ON a.espar = tb.espar
WHERE ua.npp = a.npp AND ua.a = a.a AND p2.incref = 18;

UPDATE metaifn.afchamp
SET calcin = 0, calcout = 18, validin = 0, validout = 18, defout = 18
WHERE famille = 'INV_EXP_NM'
AND donnee = 'TGB_ONB';

COMMIT;


SELECT incref, count(tgb_onb)
FROM inv_exp_nm.g3arbre
GROUP BY INCREF
ORDER BY INCREF DESC;



