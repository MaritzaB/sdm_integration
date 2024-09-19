library(dismo)
library(terra)
library(raster)
library(sf)
library(biomod2)
library(dplyr)
library(sp)
source("src/process_raster_data.R")
source("src/process_occurrence_data.R")

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

# Definir la lista de tuplas con año y mes específicos
year_month_list <- list(
  c("2014", "01"), c("2014", "02"), c("2014", "03"), c("2014", "04"), c("2014", "05"), c("2014", "12"),
  c("2015", "01"), c("2015", "02"), c("2015", "03"),
  c("2016", "02"), c("2016", "03"), c("2016", "04"),
  c("2017", "02"), c("2017", "03"),
  c("2018", "01"), c("2018", "02")
)


full_ml_dataset <- data.frame()

# Iterar sobre la lista de tuplas para generar el dataset completo
for (year_month in year_month_list) {
  year <- year_month[1]
  month <- year_month[2]

  temp_dataset <- tryCatch({
    create_modeling_dataset(year, month)
  }, error = function(e) {
    cat("Error al procesar year:", year, "month:", month, "\n")
    return(NULL)
  })

  if (!is.null(temp_dataset)) {
    full_ml_dataset <- rbind(full_ml_dataset, temp_dataset)
  }
}



print(dim(full_ml_dataset))
print(head(full_ml_dataset))


output_directory <- "model_dataset"
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

output_file <- file.path(output_directory, "full_ml_dataset.csv")
write.csv(full_ml_dataset, file = output_file, row.names = FALSE)
cat("Proceso completado. Archivo CSV guardado en:", output_file, "\n")
