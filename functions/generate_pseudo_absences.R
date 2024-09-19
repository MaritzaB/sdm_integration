library(dismo)
library(terra)
library(raster)
library(sf)
library(biomod2)
library(dplyr)
library(sp)
source("functions/process_raster_data.R")
source("functions/process_occurrence_data.R")

create_biomod_data <- function(year, month, env, species_occurrence_data) {
  # Obtener las listas de presencia y coordenadas de las especies a partir de
  # los datos de ocurrencia.
  species_presence_data <- species_occurrence_data$presence_data
  species_coordinates <- species_occurrence_data$coordinates
  studied_species_name <- species_occurrence_data$species_name
  n_absences <- ceiling(length(species_presence_data) / 5)
  
  # Generar el objeto biomod_data con pseudo-ausencias usando el método 'sre'
  set.seed(5555)
  biomod_data <- BIOMOD_FormatingData(
    resp.var = species_presence_data,
    expl.var = env,
    resp.xy = species_coordinates,
    resp.name = studied_species_name,
    PA.nb.rep = 5,
    PA.nb.absences = n_absences,
    PA.strategy = "sre",
    PA.dist.min = NULL,
    PA.dist.max = NULL,
    PA.sre.quant = 0.1,
    filter.raster = FALSE,
    na.rm = TRUE
  )
  
  cat("Biomod_data object created with pseudo-absences\n")
  return(biomod_data)
}


prepare_dataset <- function(biomod_data, year, month) {
  coordinates <- as.matrix(biomod_data@coord)
  env_vars <- biomod_data@data.env.var
  species_data <- biomod_data@data.species
  species_data[is.na(species_data)] <- 0

  presence_absence_dataset <- data.frame(
    coordinates,
    env_vars,
    species_data
  )
  
  presence_absence_dataset$nyear <- rep(year, nrow(presence_absence_dataset))
  presence_absence_dataset$nmonth <- rep(month, nrow(presence_absence_dataset))
  
  return(presence_absence_dataset)
}

create_modeling_dataset <- function(year, month) {
  env <- generate_masked_raster(year, month)
  species_occurrence_data <- get_occurrence_data(year, month)
  biomod_data <- create_biomod_data(year, month, env, species_occurrence_data)
  print(biomod_data)
  final_dataset <- prepare_dataset(biomod_data, year, month)
  return(final_dataset)
}
