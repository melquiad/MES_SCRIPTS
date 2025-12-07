
DELETE FROM ifn_prod.echantillon
WHERE id_ech = 150;

SELECT setval('ifn_prod.echantillon_id_ech_seq',147);
--ou
ALTER SEQUENCE ifn_prod.echantillon_id_ech_seq RESTART 149;
---------------------------------------------------------------

DELETE FROM inv_exp_nm.unite_ech WHERE id_ech IN (49);
DELETE FROM inv_exp_nm.echantillon WHERE id_ech IN (49, 50);

SELECT setval('inv_exp_nm.echantillon_id_ech_seq',48);
--ou
ALTER SEQUENCE inv_exp_nm.echantillon_id_ech_seq RESTART 48;
