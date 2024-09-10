select 
ST_astext(
    ST_ConvexHull(
        ST_Collect(geom)
)) as geom_convex_hull,
ST_AsEWKT(
    ST_ConvexHull(
        ST_Collect(geom)
)) as ewkt_convex_hull
from albatros_seasons as2
