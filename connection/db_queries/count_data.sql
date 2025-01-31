select t1.year_month, t1.año, t1.mes, t1.total_puntos, t2.total_no_duplicates
from (
select 
	substring("date", 1,7) as year_month,
	substring("date", 1,4) as año,	
	substring("date", 6,2) as mes,
	count(*) as total_puntos
from albatros_seasons as2
group by substring("date", 1,7), substring("date", 6,2), substring("date", 1,4)
order by año, mes) as t1
join (
select
	year_month, año, mes, count(*) as total_no_duplicates
from (
select
	substring("date", 1,7) as year_month,
	substring("date", 1,4) as año,	
	substring("date", 6,2) as mes,
	geom 
from albatros_seasons as2
group by year_month, año, mes, geom) as subquery
group by year_month, año, mes
order by year_month ) as t2 on t1.año = t2.año and t1.mes = t2.mes
