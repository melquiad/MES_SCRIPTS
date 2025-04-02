

-- Ajout de la donnée GEST en peupleraie.
ALTER TABLE inv_exp_nm.p3point ADD COLUMN gest CHAR(1);

-- On fixe sa valeur à '2'.
UPDATE inv_exp_nm.p3point
SET gest = '2'
WHERE incref = 19;