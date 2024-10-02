library(dismo)
library(terra)
library(raster)
library(sf)
library(biomod2)
library(dplyr)
library(sp)
source("functions/process_raster_data.R")
source("functions/process_occurrence_data.R")

create_biomod_data <- function(env, species_occurrence_data) {
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
    filter.raster = TRUE,
    na.rm = TRUE
  )

  cat("Biomod_data object created with pseudo-absences\n")
  return(biomod_data)
}


prepare_dataset <- function(biomod_data, year, month, mode = "presence") {
  #mode <- "plot"  # Descomentar para visualizar el dataset completo
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

  if (mode == "presence") {
    presence_absence_dataset <- presence_absence_dataset[presence_absence_dataset$species_data == 1, ]
  } else if (mode == "absence") {
    presence_absence_dataset <- presence_absence_dataset[presence_absence_dataset$species_data == 0, ]
  } else if (mode == "plot") {
    # No se aplica ningún filtro, se devuelve el dataset completo
    presence_absence_dataset <- presence_absence_dataset
  }
  return(presence_absence_dataset)
}

create_modeling_dataset <- function(year, month, mode, occurrences_file, n_vars) {
  mode <- match.arg(mode, c("presence", "absence"))
  env <- generate_masked_raster(year, month, n_vars)
  species_occurrence_data <- get_occurrence_data(year, month, mode, occurrences_file)
  biomod_data <- create_biomod_data(
    env, species_occurrence_data
    )
  final_dataset <- prepare_dataset(biomod_data, year, month, mode)
  return(final_dataset)
}

generate_full_ml_dataset <- function(
  type_of_dataset, input_data, 
  year_month_list, output_file, n_vars
  ) {
  n_variables <- n_vars
  full_ml_dataset <- data.frame()
  for (year_month in year_month_list) {
    year <- year_month[1]
    month <- year_month[2]
    print(paste("Procesando año:", year, "mes:", month))
    
    temp_dataset <- tryCatch({
      create_modeling_dataset(year, month, type_of_dataset, input_data, n_variables)
    }, error = function(e) {
      cat("Error al procesar year:", year, "month:", month, "\n")
      return(NULL)
    })
    
    raster_file <- generate_masked_raster(year, month, n_variables)
    plot_species_distribution(raster_file, temp_dataset)
    
    if (!is.null(temp_dataset)) {
      full_ml_dataset <- rbind(full_ml_dataset, temp_dataset)
    }
  }

  out_file <- output_file
  write.csv(full_ml_dataset, file = out_file, row.names = FALSE)
  cat("Proceso completado. Archivo CSV guardado en:", output_file, "\n")
}
