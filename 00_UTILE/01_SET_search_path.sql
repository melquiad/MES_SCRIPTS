SET search_path = inv_prod_new, metaifn, inv_exp_nm, public, topology;
SHOW search_path;

ALTER ROLE "lhaugomat" SET search_path TO inv_prod_new;

ALTER DATABASE inventaire SET search_path = 'inv_prod_new';
ALTER DATABASE inventaire SET search_path = 'public';