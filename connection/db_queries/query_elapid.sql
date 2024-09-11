select
    'Phoebastria immutabilis' as scientific_name,
    longitude, latitude,
    cast(substring("date", 1,4) as integer) as year,
	cast(substring("date",6,2) as integer) as month
from albatros_seasons as2
where month = 1
group by year, month, latitude, longitude
