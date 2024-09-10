select id, ST_AsText(geom) as geom, ST_AsEWKT(geom) as ewkt, country
from "americas";