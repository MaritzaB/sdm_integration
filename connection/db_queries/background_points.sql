select longitude,latitude,
    id,
    CASE
      WHEN class = FALSE THEN 0
      ELSE 1
    END as class,
    area_exten as area_entent
from background_points bp 
