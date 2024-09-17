library(terra)
library(raster)
library(sf)

load_raster <- function(file_name) {
  raster(file.path(raster_dir, file_name))
}

load_polygon <- function(file_name) {
  st_read(file.path(file_name))
}

main_dir <- ""
raster_dir <- "resampled_data/2014/01/"
rasters <- c(
  sst = "sst_resampled.tif",
  chlc = "chlor_a_resampled.tif",
  eastward_wind = "wind_speed.tif",
  northward_wind = "wind_direction.tif"
)

loaded_rasters <- lapply(rasters, load_raster)
polygon <- load_polygon("data/binary/convex_hull.shp")

env_stack <- stack(loaded_rasters)
env_stack

names(env_stack) <- names(rasters)

print(names(env_stack))

training_raster <- crop(env_stack, polygon)

masked_raster <- mask(training_raster, polygon)

# Save the masked raster
writeRaster(masked_raster, "training_env.tif", format = "GTiff", overwrite = TRUE)

