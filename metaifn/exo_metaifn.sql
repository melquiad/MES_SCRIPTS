
---------------Ma 1 ere solution trop compliquée, qui marche mais sans noms vernaculaires---------------
with t1 as 
(
select g.gunite, g.gmode, g.unite, g.mode
from metaifn.abgroupe g
where g.gunite = 'CDREF13' and g.unite = 'CODESP'
),
t2 as
(select g.gunite, g.gmode, g.unite, g.mode
from metaifn.abgroupe g
where g.gunite = 'ESPAR1' and g.unite = 'CODESP'
)
select distinct t2.gunite, t2.unite, t2.gmode, t2.mode, t1.gunite, t1.unite, t1.gmode, t1.mode, m.libelle 
from t2
left join t1 on t1.mode = t2.mode
join metaifn.abmode m on t2.mode = m.mode
	where m.unite = 'CODESP'
order by t1.mode;
-----------------------------------------------------------------------------------------
select a1.gunite, a1.gmode, a2.gunite, a2.gmode, a2.unite, a2.mode
from metaifn.abgroupe a1
	inner join metaifn.abgroupe a2 on a1.mode = a2.mode
		where a1.gunite = 'ESPAR1' and a2.gunite = 'CDREF13';
	
-------------------------Ma solution inspirée de CEDRIC-----------------------------
select e."mode", e.libelle, c."mode", c.libelle, ei."mode", ei.unite, ic."mode", ic.unite
from metaifn.abmode e
	left join metaifn.abgroupe ei on ei.gunite = e.unite and ei.gmode = e."mode" and ei.unite = 'CODESP'
	left join metaifn.abgroupe ic on ic.unite = ei.unite and ic."mode" = ei."mode" and ic.gunite = 'CDREF13'
	left join metaifn.abmode c on c.unite = ic.gunite and c."mode" = ic.gmode 
		where e.unite = 'ESPAR1'
order by 1;

-----------------------------Solution de CEDRIC-------------------------------------

SELECT e."mode", e.libelle, c."mode", c.libelle
FROM metaifn.abmode e
LEFT JOIN metaifn.abgroupe eo ON e.unite = eo.gunite AND e."mode" = eo.gmode AND eo.unite = 'CODESP'
LEFT JOIN metaifn.abgroupe oc ON eo.unite = oc.unite AND eo."mode" = oc."mode" AND oc.gunite = 'CDREF13'
LEFT JOIN metaifn.abmode c ON oc.gunite = c.unite AND oc.gmode = c."mode" 
WHERE e.unite = 'ESPAR1'
ORDER BY 1;
