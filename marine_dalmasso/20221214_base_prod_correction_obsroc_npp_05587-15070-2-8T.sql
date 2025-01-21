--/*
select p.id_point, p.npp 
from point p
where npp = '05587-15070-2-8T';

select e.id_point, e.obsroc 
from ecologie_2005 e
inner join point p using(id_point)
where p.npp = '05587-15070-2-8T';
*/


update inv_prod_new.ecologie_2005
set obsroc = NULL
where id_point = '515545';


