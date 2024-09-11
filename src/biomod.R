#install.packages("dismo")
#install.packages("terra")
#install.packages("raster")
#install.packages("sp")
#install.packages("geodata")

library(dismo)
library(terra)
library(raster)

#climate_data <- getData('SRTM', lon=5, lat=45)

# Mostrar los datos climáticos
#print(climate_data)

# Descargar datos de elevación usando geodata
elevation_data <- elevation_30s(country="BEL", path=tempdir() )

# Mostrar información sobre los datos descargados
print(elevation_data)

# Crear un conjunto de datos de puntos de presencia (ejemplo)
presence_points <- data.frame(
  lon = c(5.5, 6, 6.5, 7),
  lat = c(44.5, 44, 43.5, 43)
)

# Visualizar los puntos de presencia
print(presence_points)

# Convertir los puntos a una clase espacial
library(sp)
coordinates(presence_points) <- ~lon+lat
