select *
from echantillon
where id_ech = 106;
-----------------------------------------
select id_point
from point_lt
where id_ech = 104
order by id_point ;

--delete from point_lt
where id_ech = 104; --> OK
-------------------------------------
select count(id_ech)
from hydro
where id_ech = 105;

--delete from hydro 
where id_ech = 104;
-------------------------------------
select count(id_ech)
from point_ech
where id_ech = 104;

--delete from point_ech
where id_ech = 104;

--------------------------------------
select *
from troncons_proches;

