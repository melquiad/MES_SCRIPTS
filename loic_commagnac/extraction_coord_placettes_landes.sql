
------------------------- version de Loïc ---------------------------------------------------------------------------

select g3f.npp as g3fnpp, g3f.div_r, g3f.comp_r, g3f.compel_r, g3f.incref as g3incref, e2p.npp as e2pnpp, e2p.ser_86
from inv_exp_nm.g3foret g3f
inner join inv_exp_nm.e2point e2p on g3f.npp = e2p.npp
where g3f.div_r = '1' and g3f.comp_r = 'PMAR' and g3f.incref in (15, 16) and e2p.ser_86 in ('F21','F22','F23')
order by e2p.npp;

------------------------- version avec coordonnéesplacettes ----------------------------------------------------------

select g3f.npp as g3fnpp, g3f.div_r, g3f.comp_r, g3f.compel_r, g3f.incref as g3incref, e2p.npp as e2pnpp, e2p.ser_86, ROUND(ST_X(geom)::NUMERIC) AS xl93, ROUND(ST_Y(geom)::NUMERIC) AS yl93
from inv_exp_nm.g3foret g3f
inner join inv_exp_nm.e2point e2p on g3f.npp = e2p.npp
inner join inv_exp_nm.e1coord e1c on g3f.npp = e1c.npp
where g3f.div_r = '1' and g3f.comp_r = 'PMAR' and g3f.incref in (15, 16) and e2p.ser_86 in ('F21','F22','F23')
order by e2p.npp;

