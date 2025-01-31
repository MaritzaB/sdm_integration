select
    substring("date",1,4) as nyear,
    substring("date",6,2) as nmonth,
    longitude, latitude,
    1 as Phoebastria_immutabilis
  from albatros_seasons as2
  where substring("date", 6, 2) in ('12', '01', '02', '03', '04', '05')
  group by nyear, nmonth, latitude, longitude
  order by nyear, nmonth