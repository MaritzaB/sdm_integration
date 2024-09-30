select * from
(
  select
    case 
        when substring("date",6,2) = '12' or substring("date", 6, 2) = '01' then 'incubacion'
        when substring("date",6,2) = '02' then 'empollamiento'
        when substring("date",6,2) = '03' or 
             substring("date",6,2) = '04' or 
             substring("date", 6, 2) = '05' then 'crianza'
    end as season_ref,
    substring("date",1,4) as nyear,
    substring("date",6,2) as nmonth,
    longitude, latitude,
    1 as Phoebastria_immutabilis,
    case 
        when substring("date",1,4) = '2018' then 'test'
        when substring("date", 6, 2) in ('03', '04', '05') and
             substring("date",1,4) = '2017' then 'test'
        else 'train'
    end as dataset_type
  from albatros_seasons as2
  where substring("date", 6, 2) in ('12', '01', '02', '03', '04', '05')
  group by season_ref, nyear, nmonth, latitude, longitude
  order by nyear, nmonth)
where dataset_type = 'train' and season_ref = 'empollamiento';