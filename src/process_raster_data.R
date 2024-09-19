library(terra)
library(sf)

# Función para cargar rásteres
load_raster <- function(raster_dir, file_name) {
  rast(file.path(raster_dir, file_name))
}

# Función para cargar el polígono del área calibración (convex hull)
load_polygon <- function() {
  convex_hull_path <- "data/binary/convex_hull.shp"
  st_read(convex_hull_path)
}

# Función para crear el stack de rásteres
create_raster_stack <- function(raster_dir, rasters) {
  loaded_rasters <- lapply(
    rasters, function(raster_file) load_raster(raster_dir, raster_file)
    )
  env_stack <- rast(loaded_rasters)
  return(env_stack)
}

# Función para recortar y enmascarar el ráster
crop_and_mask_raster <- function(env_stack, polygon, raster_names) {
  training_raster <- crop(env_stack, polygon)
  masked_raster <- mask(training_raster, polygon)
  names(masked_raster) <- raster_names
  return(masked_raster)
}

# Función para generar el ráster recortado y enmascarado
generate_masked_raster <- function(year, month) {
  raster_dir <- file.path("resampled_data", year, month)
  
  rasters <- c(
    sst = "sst_resampled.tif",
    chlc = "chlor_a_resampled.tif",
    wind_speed = "wind_speed.tif",
    wind_direction = "wind_direction.tif"
  )

  polygon <- load_polygon()
  
  env_stack <- create_raster_stack(raster_dir, rasters)
  masked_raster <- crop_and_mask_raster(env_stack, polygon, names(rasters))
  return(masked_raster)
}
