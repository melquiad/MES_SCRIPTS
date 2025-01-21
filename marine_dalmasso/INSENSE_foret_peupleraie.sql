-- CALCUL DES INDICATEURS INSENSE PAR ÉLÉMENTS
-- calcul en forêt
DROP TABLE IF EXISTS indic_elem;

CREATE TEMPORARY TABLE indic_elem AS
SELECT e.npp, e.incref, 'foret' AS domaine
, CASE 
    WHEN humus IN ('80') THEN 'S0'
    WHEN pcalc < 3 THEN 'F1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) 
        THEN 'F2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('E', 'H', 'I', 'J', 'K')
            AND humus IN ('50', '55', '40', '45') 
        THEN 'F3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('E', 'H', 'I', 'J', 'K')
            AND humus IN ('31', '30', '48') 
        THEN 'M1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'B', 'C', 'D', 'F', 'G')
            AND humus IN ('50', '55', '40', '45') 
        THEN 'M2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'B', 'C', 'D', 'F', 'G')
            AND humus IN ('31', '30', '48') 
        THEN 'S1'
    WHEN (pcalc >= 3 OR pcalc IS NULL) AND humus IN ('15', '25', '42') THEN 'M3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55', '15', '25', '42')
            AND greco IN ('E', 'H') 
        THEN 'M4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55', '15', '25', '42')
            AND greco NOT IN ('E', 'H') 
        THEN 'S2'
    ELSE NULL
  END AS insense_ca
, CASE
    WHEN humus IN ('80') THEN 'S0'
    WHEN pcalc < 3 THEN 'F1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) 
        THEN 'F2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('J', 'K') 
        THEN 'F3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'H', 'I')
            AND humus IN ('50', '55', '40', '45') 
        THEN 'F4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'H', 'I')
            AND humus IN ('30', '31', '48') 
        THEN 'M1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
        THEN 'F5'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('50', '55')
            AND ((htext IS NULL)
                OR (htext = '0'
                    AND text1 = '0'
                    AND text2 = '0')
                OR (htext = '2'
                    AND text1 IN ('0', '4', '8', '1', '2', '3'))
                OR (htext = '1'
                    AND text2 IN ('0', '4', '8', '1', '2', '3'))
                ) 
        THEN 'M2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('40', '45') 
        THEN 'M3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('30', '31', '48') 
        THEN 'S1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55')
            AND greco IN ('I', 'J', 'K') 
        THEN 'M4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55')
            AND greco NOT IN ('I', 'J', 'K')
        THEN 'S2'
    ELSE NULL
  END AS insense_mg
, CASE
    WHEN htext IS NULL THEN 'IT'
    WHEN htext = '0' THEN 'IC'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55') AND (text1 = '0' AND text2 = '0') THEN 'IT'
    WHEN ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) THEN 'F1'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
        THEN 'F2'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('C', 'E', 'G', 'H', 'I', 'J') 
        THEN 'F3'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('A', 'B', 'D', 'F', 'K') 
        THEN 'M1'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2'
                    AND text1 IN ('4', '8'))
                OR (htext = '1'
                    AND text2 IN ('4', '8')))
            AND greco IN ('C', 'G') 
        THEN 'F4'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2'
            AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('A', 'D', 'E', 'I', 'J', 'K') 
        THEN 'M2'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('B', 'F', 'H') 
        THEN 'S1'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('C', 'G') 
        THEN 'F5'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('D', 'E', 'K') 
        THEN 'M3'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('A', 'B', 'F', 'H', 'I', 'J') 
        THEN 'S2'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S6'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    WHEN humus IN ('20', '22') AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) THEN 'F6'
    WHEN humus IN ('20', '22') AND ((htext = '2' AND text1 <> '7') OR (htext = '1' AND text2 <> '7')) THEN 'S3'
    WHEN humus IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('7', '5', '6')) OR (htext = '1' AND text2 IN ('7', '5', '6'))) 
        THEN 'M4'
    WHEN humus IN ('15', '25', '42')
            AND ((htext = '2' AND text1 NOT IN ('7', '5', '6')) OR (htext = '1' AND text2 NOT IN ('7', '5', '6'))) 
        THEN 'S4'
    WHEN ((htext = '2' AND text1 <> '9') OR (htext = '1' AND text2 <> '9'))
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55', '20', '22', '15', '25', '42') 
        THEN 'S5'
    ELSE NULL
  END AS insense_k
, CASE
    WHEN htext = '0' THEN 'IC'
    WHEN (text1 = '0' AND text2 = '0') THEN 'IT'
    WHEN humus IN ('80') THEN 'S0'
    WHEN ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) THEN 'F1'
    WHEN ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('C', 'D', 'E', 'G', 'H', 'I') 
        THEN 'F2'
    WHEN ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('A', 'B', 'F', 'J', 'K') 
        THEN 'M1'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('E', 'G', 'H', 'I') 
        THEN 'F3'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco IN ('A', 'C', 'D', 'J', 'K') 
        THEN 'M2'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1'  AND text2 IN ('4', '8')))
            AND greco IN ('F', 'B')
            AND humus IN ('50', '55') 
        THEN 'M3'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('F', 'B')
            AND humus NOT IN ('50', '55') 
        THEN 'S1'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco = 'G' 
        THEN 'F4'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('C', 'D', 'E', 'H', 'I', 'K') 
        THEN 'M4'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('A', 'B', 'F', 'J') 
        THEN 'S2'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S3'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    ELSE NULL
  END AS insense_p
, CASE
    WHEN htext = '0' THEN 'IC'
    WHEN (text1 = '0' AND text2 = '0') AND humus NOT IN ('15', '25', '42') THEN 'IT'
    WHEN humus = '80' THEN 'S0'
    WHEN humus IN ('15', '25', '42') THEN 'F1'
    WHEN greco = 'G' AND humus IN ('20', '22') THEN 'F2'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) 
            AND greco = 'F' 
        THEN 'M1'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) 
            AND greco <> 'F' 
        THEN 'F3'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
            AND greco IN ('F', 'I', 'J') 
        THEN 'M2'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
            AND greco NOT IN ('F', 'I', 'J') 
        THEN 'F4'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
            AND greco IN ('B', 'C', 'F', 'I', 'J', 'K') 
        THEN 'M3'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
            AND greco NOT IN ('B', 'C', 'F', 'I', 'J', 'K') 
        THEN 'F5'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco IN ('E', 'H', 'A') 
        THEN 'F6'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco = 'B' 
        THEN 'S1'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco NOT IN ('E', 'H', 'A', 'B') 
        THEN 'M4'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3'))) 
            AND greco IN ('B', 'C', 'D', 'F', 'J') 
        THEN 'S2'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3'))) 
            AND greco NOT IN ('B', 'C', 'D', 'F', 'J') 
        THEN 'M5'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H'))) 
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S3'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H'))) 
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    ELSE NULL
  END AS insense_n
FROM inv_exp_nm.g3ecologie e
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE p.incref = 16
ORDER BY npp;

-- calcul en peupleraie
INSERT INTO indic_elem
SELECT e.npp, e.incref, 'peupleraie' AS domaine
, CASE 
    WHEN humus IN ('80') THEN 'S0'
    WHEN pcalc < 3 THEN 'F1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) 
        THEN 'F2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('E', 'H', 'I', 'J', 'K')
            AND humus IN ('50', '55', '40', '45') 
        THEN 'F3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('E', 'H', 'I', 'J', 'K')
            AND humus IN ('31', '30', '48') 
        THEN 'M1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'B', 'C', 'D', 'F', 'G')
            AND humus IN ('50', '55', '40', '45') 
        THEN 'M2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'B', 'C', 'D', 'F', 'G')
            AND humus IN ('31', '30', '48') 
        THEN 'S1'
    WHEN (pcalc >= 3 OR pcalc IS NULL) AND humus IN ('15', '25', '42') THEN 'M3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55', '15', '25', '42')
            AND greco IN ('E', 'H') 
        THEN 'M4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55', '15', '25', '42')
            AND greco NOT IN ('E', 'H') 
        THEN 'S2'
    ELSE NULL
  END AS insense_ca
, CASE
    WHEN humus IN ('80') THEN 'S0'
    WHEN pcalc < 3 THEN 'F1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) 
        THEN 'F2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('J', 'K') 
        THEN 'F3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'H', 'I')
            AND humus IN ('50', '55', '40', '45') 
        THEN 'F4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('A', 'H', 'I')
            AND humus IN ('30', '31', '48') 
        THEN 'M1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
        THEN 'F5'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('50', '55')
            AND ((htext IS NULL)
                OR (htext = '0'
                    AND text1 = '0'
                    AND text2 = '0')
                OR (htext = '2'
                    AND text1 IN ('0', '4', '8', '1', '2', '3'))
                OR (htext = '1'
                    AND text2 IN ('0', '4', '8', '1', '2', '3'))
                ) 
        THEN 'M2'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('40', '45') 
        THEN 'M3'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND (text1 NOT IN ('7', '9') OR text2 NOT IN ('7', '9'))
            AND greco IN ('B', 'C', 'D', 'E', 'F', 'G')
            AND humus IN ('30', '31', '48') 
        THEN 'S1'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55')
            AND greco IN ('I', 'J', 'K') 
        THEN 'M4'
    WHEN (pcalc >= 3 OR pcalc IS NULL)
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55')
            AND greco NOT IN ('I', 'J', 'K')
        THEN 'S2'
    ELSE NULL
  END AS insense_mg
, CASE
    WHEN htext IS NULL THEN 'IT'
    WHEN htext = '0' THEN 'IC'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55') AND (text1 = '0' AND text2 = '0') THEN 'IT'
    WHEN ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) THEN 'F1'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
        THEN 'F2'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('C', 'E', 'G', 'H', 'I', 'J') 
        THEN 'F3'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('A', 'B', 'D', 'F', 'K') 
        THEN 'M1'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2'
                    AND text1 IN ('4', '8'))
                OR (htext = '1'
                    AND text2 IN ('4', '8')))
            AND greco IN ('C', 'G') 
        THEN 'F4'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2'
            AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('A', 'D', 'E', 'I', 'J', 'K') 
        THEN 'M2'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('B', 'F', 'H') 
        THEN 'S1'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('C', 'G') 
        THEN 'F5'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('D', 'E', 'K') 
        THEN 'M3'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('A', 'B', 'F', 'H', 'I', 'J') 
        THEN 'S2'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S6'
    WHEN humus IN ('30', '31', '40', '45', '48', '50', '55')
            AND ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    WHEN humus IN ('20', '22') AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) THEN 'F6'
    WHEN humus IN ('20', '22') AND ((htext = '2' AND text1 <> '7') OR (htext = '1' AND text2 <> '7')) THEN 'S3'
    WHEN humus IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('7', '5', '6')) OR (htext = '1' AND text2 IN ('7', '5', '6'))) 
        THEN 'M4'
    WHEN humus IN ('15', '25', '42')
            AND ((htext = '2' AND text1 NOT IN ('7', '5', '6')) OR (htext = '1' AND text2 NOT IN ('7', '5', '6'))) 
        THEN 'S4'
    WHEN ((htext = '2' AND text1 <> '9') OR (htext = '1' AND text2 <> '9'))
            AND humus NOT IN ('30', '31', '40', '45', '48', '50', '55', '20', '22', '15', '25', '42') 
        THEN 'S5'
    ELSE NULL
  END AS insense_k
, CASE
    WHEN htext = '0' THEN 'IC'
    WHEN (text1 = '0' AND text2 = '0') THEN 'IT'
    WHEN humus IN ('80') THEN 'S0'
    WHEN ((htext = '2' AND text1 IN ('7', '9')) OR (htext = '1' AND text2 IN ('7', '9'))) THEN 'F1'
    WHEN ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('C', 'D', 'E', 'G', 'H', 'I') 
        THEN 'F2'
    WHEN ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6')))
            AND greco IN ('A', 'B', 'F', 'J', 'K') 
        THEN 'M1'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('E', 'G', 'H', 'I') 
        THEN 'F3'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco IN ('A', 'C', 'D', 'J', 'K') 
        THEN 'M2'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1'  AND text2 IN ('4', '8')))
            AND greco IN ('F', 'B')
            AND humus IN ('50', '55') 
        THEN 'M3'
    WHEN ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8')))
            AND greco IN ('F', 'B')
            AND humus NOT IN ('50', '55') 
        THEN 'S1'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco = 'G' 
        THEN 'F4'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('C', 'D', 'E', 'H', 'I', 'K') 
        THEN 'M4'
    WHEN ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3')))
            AND greco IN ('A', 'B', 'F', 'J') 
        THEN 'S2'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S3'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H')))
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    ELSE NULL
  END AS insense_p
, CASE
    WHEN htext = '0' THEN 'IC'
    WHEN (text1 = '0' AND text2 = '0') AND humus NOT IN ('15', '25', '42') THEN 'IT'
    WHEN humus = '80' THEN 'S0'
    WHEN humus IN ('15', '25', '42') THEN 'F1'
    WHEN greco = 'G' AND humus IN ('20', '22') THEN 'F2'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) 
            AND greco = 'F' 
        THEN 'M1'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 = '9') OR (htext = '1' AND text2 = '9')) 
            AND greco <> 'F' 
        THEN 'F3'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
            AND greco IN ('F', 'I', 'J') 
        THEN 'M2'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 = '7') OR (htext = '1' AND text2 = '7')) 
            AND greco NOT IN ('F', 'I', 'J') 
        THEN 'F4'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
            AND greco IN ('B', 'C', 'F', 'I', 'J', 'K') 
        THEN 'M3'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('5', '6')) OR (htext = '1' AND text2 IN ('5', '6'))) 
            AND greco NOT IN ('B', 'C', 'F', 'I', 'J', 'K') 
        THEN 'F5'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco IN ('E', 'H', 'A') 
        THEN 'F6'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco = 'B' 
        THEN 'S1'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('4', '8')) OR (htext = '1' AND text2 IN ('4', '8'))) 
            AND greco NOT IN ('E', 'H', 'A', 'B') 
        THEN 'M4'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3'))) 
            AND greco IN ('B', 'C', 'D', 'F', 'J') 
        THEN 'S2'
    WHEN humus NOT IN ('15', '25', '42') 
            AND ((htext = '2' AND text1 IN ('1', '2', '3')) OR (htext = '1' AND text2 IN ('1', '2', '3'))) 
            AND greco NOT IN ('B', 'C', 'D', 'F', 'J') 
        THEN 'M5'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H'))) 
            AND tsol IN ('14', '15', '16', '17') 
        THEN 'S3'
    WHEN ((htext = '2' AND text1 IN ('H')) OR (htext = '1' AND text2 IN ('H'))) 
            AND tsol NOT IN ('14', '15', '16', '17') 
        THEN 'IX'
    ELSE NULL
  END AS insense_n
FROM inv_exp_nm.p3ecologie e
INNER JOIN inv_exp_nm.e2point p USING (npp)
WHERE p.incref = 16
ORDER BY npp;

-- ajout de la sensibilité finale
ALTER TABLE indic_elem
    ADD COLUMN insense char(2);

WITH totaux AS (
    SELECT ie.npp, e.humus, e.prof2
    , char_length(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n)) - char_length(replace(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n), 'F', '')) AS nb_faible
    , char_length(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n)) - char_length(replace(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n), 'M', '')) AS nb_moyen
    , char_length(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n)) - char_length(replace(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n), 'S', '')) AS nb_fort
    , char_length(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n)) - char_length(replace(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n), 'I', '')) AS nb_indet
    FROM indic_elem ie
    INNER JOIN inv_exp_nm.g3ecologie e USING (npp)
)
UPDATE indic_elem ie
SET insense = 
  CASE
    WHEN nb_faible >= 3 AND nb_fort = 0 AND prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'F1'
    WHEN nb_faible >= 3 AND nb_fort = 0 AND prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'M1'
    WHEN nb_moyen >= 3 AND prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'M2' 
    WHEN nb_moyen >= 3 AND prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'S1'
    WHEN nb_fort >= 3 AND nb_faible = 0 AND humus NOT IN ('80') THEN 'S2'
    WHEN nb_indet >= 3 OR (nb_indet = 2 AND prof2 IS NULL) THEN 'IN'
    WHEN prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'PA'
    WHEN prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'S3'
    WHEN humus IN ('80') THEN 'S4'
  END
FROM totaux t
WHERE ie.npp = t.npp;

WITH totaux AS (
    SELECT ie.npp, e.humus, e.prof2
    , char_length(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n)) - char_length(replace(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n), 'F', '')) AS nb_faible
    , char_length(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n)) - char_length(replace(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n), 'M', '')) AS nb_moyen
    , char_length(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n)) - char_length(replace(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n), 'S', '')) AS nb_fort
    , char_length(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n)) - char_length(replace(concat(insense_ca, insense_mg, insense_k, insense_p, insense_n), 'I', '')) AS nb_indet
    FROM indic_elem ie
    INNER JOIN inv_exp_nm.p3ecologie e USING (npp)
)
UPDATE indic_elem ie
SET insense = 
  CASE
    WHEN nb_faible >= 3 AND nb_fort = 0 AND prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'F1'
    WHEN nb_faible >= 3 AND nb_fort = 0 AND prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'M1'
    WHEN nb_moyen >= 3 AND prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'M2' 
    WHEN nb_moyen >= 3 AND prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'S1'
    WHEN nb_fort >= 3 AND nb_faible = 0 AND humus NOT IN ('80') THEN 'S2'
    WHEN nb_indet >= 3 OR (nb_indet = 2 AND prof2 IS NULL) THEN 'IN'
    WHEN prof2 NOT IN ('0','1','2') AND humus NOT IN ('80') THEN 'PA'
    WHEN prof2 IN ('0','1','2') AND humus NOT IN ('80') THEN 'S3'
    WHEN humus IN ('80') THEN 'S4'
  END
FROM totaux t
WHERE ie.npp = t.npp;

UPDATE inv_exp_nm.g3ecologie e
SET insense_ca = ie.insense_ca, 
    insense_mg = ie.insense_mg, 
    insense_k = ie.insense_k, 
    insense_p = ie.insense_p, 
    insense_n = ie.insense_n, 
    insense = ie.insense
FROM indic_elem ie
WHERE e.npp = ie.npp;

UPDATE inv_exp_nm.p3ecologie e
SET insense_ca = ie.insense_ca, 
    insense_mg = ie.insense_mg, 
    insense_k = ie.insense_k, 
    insense_p = ie.insense_p, 
    insense_n = ie.insense_n, 
    insense = ie.insense
FROM indic_elem ie
WHERE e.npp = ie.npp;