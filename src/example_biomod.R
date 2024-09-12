library(dismo)
library(terra)
library(raster)
library(sf)
library(biomod2)
library(dplyr)
library(sp)

# Load the data
main_dir <- ""
occurrences_file <- "data/trajectories.csv"

raster_dir <- "resampled_data/2014/01/"
rasters <- list(
    sst = "sst_resampled.tif",
    chlc = "chlor_a_resampled.tif",
    eastward_wind = "eastward_wind.tif",
    northward_wind = "northward_wind.tif"
)

load_raster <- function(file_name) {
  raster(file.path(raster_dir, file_name))
}

DataSpecies <- read.csv(occurrences_file)
sst <- load_raster(rasters$sst)
chlc <- load_raster(rasters$chlc)
eastward_wind <- load_raster(rasters$eastward_wind)
northward_wind <- load_raster(rasters$northward_wind)
env <- stack(sst, chlc, eastward_wind, northward_wind)
env
head(DataSpecies)

# Select the name of the studied species
myRespName <- 'phoebastria_immutabilis'

# Get corresponding presence/absence data
myResp <- as.numeric(DataSpecies[, myRespName])

# Get corresponding XY coordinates
myRespXY <- DataSpecies[, c('longitude', 'latitude')]

proj4string(env)
#convex_hull <- read.csv("data/convex_hull.csv")
#head(convex_hull)

set.seed(123)

# Create the biomod2 object
biomod_data <- BIOMOD_FormatingData(resp.var = myResp,
                                    expl.var = env,
                                    resp.xy = myRespXY,
                                    resp.name = myRespName,
                                    PA.nb.rep = 2,
                                    PA.nb.absences = 100,
                                    PA.strategy = "random", # can be "random", "sre" or "disk"
                                    PA.dist.min = NULL, # for 'disk' strategy
                                    PA.dist.max = NULL, # for 'disk' strategy
                                    PA.sre.quant = 0.1,
                                    na.rm = TRUE)

str(biomod_data)

pa_table <- biomod_data@PA.table
coordinates <- biomod_data@coord
coordinates <- as.matrix(coordinates)
species_data <- biomod_data@data.species
env_vars <- biomod_data@data.env.var

pa_table[is.na(pa_table)] <- 0
pa_table <- as.data.frame(lapply(pa_table, as.numeric)) 

combined_data <- combined_data <- data.frame(
  env_vars, 
  Presence = species_data,
  pa_table
)

presence_absence_data <- SpatialPointsDataFrame(
  data = combined_data,
  coords = coordinates,
  proj4string = CRS("+proj=longlat +datum=WGS84")
)

# Verificar la estructura del SpatialPointsDataFrame
summary(presence_absence_data)

# Convertir el SpatialPointsDataFrame a un data frame
spatial_data_df <- as.data.frame(presence_absence_data)
head(spatial_data_df)

# Escribir el data frame en un archivo CSV
write.csv(spatial_data_df, "presence_absence_data.csv", row.names = FALSE)

# Confirmación de que se escribió el archivo
cat("Archivo CSV generado: presence_absence_data.csv\n")

# Plotear el primer raster del stack 'env'
png("primer_raster.png", width = 800, height = 600)
plot(env[[1]], main = "Primer Raster del Stack")
points(presence_absence_data, col='red') 
#points(chuck.sp.utm, col='black')
dev.off()

