-- Query que calcula la distancia de cada registro de la tabla albatros_seasons a la isla de Guadalupe

select 
    id,
    geom::geography,
    (select geom from guadalupe_island gi), 
    ST_Distance(
	    geom::geography, 
	    (select geom from guadalupe_island gi)::geography
        )/1000 as spheroid_dist  
from albatros_seasons as2 
order by spheroid_dist desc;
