SET search_path = inv_prod_new, inv_exp_nm, metaifn, public, topology;

SET search_path TO inv_prod_new, inv_exp_nm, metaifn, public, topology;

SHOW search_path;


ALTER DATABASE inventaire SET search_path = 'inv_prod_new', 'public';
ALTER DATABASE inventaire SET search_path = 'public';

ALTER ROLE "lhaugomat" SET search_path = 'public', 'inv_prod_new';
ALTER ROLE "lhaugomat" SET search_path TO inv_prod_new, public;