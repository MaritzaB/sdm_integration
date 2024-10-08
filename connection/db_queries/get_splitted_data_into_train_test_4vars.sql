select
  longitude, latitude,
  sst, chlc, wind_speed, wind_direction,
  Phoebastria_immutabilis,
  nyear, 
  LPAD(nmonth::text, 2, '0')::text AS nmonth
from
( select
    sst, LOG(chlc) as chlc, wind_speed, wind_direction,
    case 
        when nmonth = 12 or nmonth = 1 then 'incubacion'
        when nmonth = 2 then 'empollamiento'
        when nmonth = 3 or nmonth = 4 or nmonth = 5 then 'crianza'
    end as season_ref,
    nyear,
    nmonth,
    x as longitude, y as latitude,
    1 as Phoebastria_immutabilis,
    case 
        when nyear = 2018 then 'test'
        when nmonth in (3,4,5) and
             nyear = 2017 then 'test'
        else 'train'
    end as dataset_type
  from presence_data_4vars as pd4
  where nmonth in (12,1,2,3,4,5)
  order by nyear, nmonth)
where dataset_type = %s and season_ref = %s;
