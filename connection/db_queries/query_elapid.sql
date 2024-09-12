select
    longitude, latitude,
    1 as Phoebastria_immutabilis
from albatros_seasons as2
where 
    substring("date",6,2) = '01' and
    substring("date",1,4) >= '2014'
group by latitude, longitude
