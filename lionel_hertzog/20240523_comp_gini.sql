with prep_table as (
select npp, gtot * wac as gtotw, row_number() over(partition by ga.npp order by gtot) * gtot * wac as num
from inv_exp_nm.g3arbre ga),
cc_table as (
select ga.npp, cast(count(*) as float) as n
from inv_exp_nm.g3arbre ga 
group by ga.npp
)
select p.npp, ((2 * sum(p.num)) / (c.n * sum(p.gtotw))) - ((c.n + 1) / c.n) as gini
from prep_table p
inner join cc_table c
on p.npp = c.npp
group by p.npp, c.n