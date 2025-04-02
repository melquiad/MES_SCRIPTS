
DELETE FROM inv_prod_new.echantillon
WHERE id_ech = 144;

SELECT setval('inv_prod_new.echantillon_id_ech_seq',143);
--ou
ALTER SEQUENCE inv_prod_new.echantillon_id_ech_seq RESTART 143;
---------------------------------------------------------------

DELETE FROM inv_exp_nm.unite_ech WHERE id_ech IN (49);
DELETE FROM inv_exp_nm.echantillon WHERE id_ech IN (49, 50);

SELECT setval('inv_exp_nm.echantillon_id_ech_seq',48);
--ou
ALTER SEQUENCE inv_exp_nm.echantillon_id_ech_seq RESTART 48;
