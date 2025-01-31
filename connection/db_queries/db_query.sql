select
	substring("date", 1,7) as year_month,
	cast(substring("date", 1,4) as integer) as year,
	cast(substring("date",6,2) as integer) as month,
	latitude,
	longitude
from albatros_seasons as2
group by year_month, year, month, latitude, longitude
