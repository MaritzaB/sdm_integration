select
    substring("date",1,4) as nyear,
    substring("date",6,2) as nmonth,
    longitude, latitude,
    1 as Phoebastria_immutabilis
from albatros_seasons as2
group by nyear, nmonth, latitude, longitude
order by nyear, nmonth;
