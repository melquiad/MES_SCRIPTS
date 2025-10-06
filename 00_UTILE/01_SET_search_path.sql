SET search_path = ifn_prod, inv_exp_nm, metaifn, public, topology;

SET search_path TO ifn_prod, inv_exp_nm, metaifn, public, topology;

SHOW search_path;


ALTER DATABASE inventaire SET search_path = 'ifn_prod', 'public';
ALTER DATABASE inventaire SET search_path = 'public';

ALTER ROLE "lhaugomat" SET search_path = 'public', 'ifn_prod';
ALTER ROLE "lhaugomat" SET search_path TO ifn_prod, public;