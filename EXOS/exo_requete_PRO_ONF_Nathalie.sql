select distinct on (e1.idp) idp ,e1.npp, e1.pro_nm, m.libelle,  g.gunite, g.gmode as pf_maaf, m1.libelle as lib_pf_maaf
from e1point e1
left join metaifn.abmode m on e1.pro_nm = m."mode" and m.unite = 'PRO_2015'
left join metaifn.abgroupe g on g."mode" = e1.pro_nm and g.gunite = 'PF_MAAF'
left join metaifn.abmode m1 on g.gunite = m1.unite and g.gmode = m1."mode"
where incref =14
order by idp, npp;


select count(npp)
from e1point
where incref = 10;


