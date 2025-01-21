
DELETE FROM inv_prod_new.echantillon
WHERE id_ech = 144;

SELECT setval('inv_prod_new.echantillon_id_ech_seq',143);
--ou
ALTER SEQUENCE inv_prod_new.echantillon_id_ech_seq RESTART 143;