create table pro_2022_932006 as
	(select p.gid as id_onf ,p.code_onf ,(st_dump(st_makevalid(st_transform(geom,932006)))).geom
	from pro_2022 p) ; 
select updategeometrysrid('public','pro_2022_932006','geom',932006) ;