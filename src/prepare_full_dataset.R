suppressPackageStartupMessages({
  library(dismo)
  library(terra)
  library(raster)
  library(biomod2)
  library(dplyr)
  source("functions/process_raster_data.R")
  source("functions/process_occurrence_data.R")
  source("functions/generate_pseudo_absences.R")
  source("functions/plot_presence_absence.R")
})

generate_full_ml_dataset <- function(
  type_of_dataset, input_data, year_month_list, output_directory = "model_dataset") {
  full_ml_dataset <- data.frame()

  # Iterar sobre la lista de tuplas para generar el dataset completo
  for (year_month in year_month_list) {
    year <- year_month[1]
    month <- year_month[2]
    print(paste("Procesando año:", year, "mes:", month))
    
    temp_dataset <- tryCatch({
      create_modeling_dataset(year, month, type_of_dataset, input_data)
    }, error = function(e) {
      cat("Error al procesar year:", year, "month:", month, "\n")
      return(NULL)
    })
    
    raster_file <- generate_masked_raster(year, month)
    plot_species_distribution(raster_file, temp_dataset)
    
    if (!is.null(temp_dataset)) {
      full_ml_dataset <- rbind(full_ml_dataset, temp_dataset)
    }
  }

  # Crear el directorio de salida si no existe
  if (!dir.exists(output_directory)) {
    dir.create(output_directory, recursive = TRUE)
  }

  # Definir el archivo de salida y guardar el dataset
  output_file <- file.path(output_directory, paste0(type_of_dataset, "_dataset.csv"))
  write.csv(full_ml_dataset, file = output_file, row.names = FALSE)
  
  cat("Proceso completado. Archivo CSV guardado en:", output_file, "\n")
}

# Definir la lista de tuplas con año y mes específicos
# Ahorita estamos generando pseudoausencias para los meses a predecir
year_month_list <- list(
  c("2014", "01"), c("2014", "02"), c("2014", "03"), c("2014", "04"), c("2014", "05"), c("2014", "12"),
  c("2015", "01"), c("2015", "02"), c("2015", "03"),
  c("2016", "02"), c("2016", "03"), c("2016", "04"),
  c("2017", "02"), c("2017", "03"),
  c("2018", "01"), c("2018", "02")
)

# Si vamos a extraer solo las variables de presencia, entonces el archivo de
# entrada es el de presencia
input_data <- "data/others/presence_data.csv"
# Si vamos a generar pseudo-ausencias, entonces los archivos de entrada van a
# ser los de presencia ya filtrados por temporada reproductiva y por tipo de
# datos (entrenamiento o prueba). Por lo que generaremos una lista de archivos.
type_of_dataset <- "presence"

generate_full_ml_dataset(type_of_dataset, input_data, year_month_list)

databases <- list(
  # nombre de la base de datos: ruta al archivo de consulta
  all_presences = "data/others/presence_data.csv",
  train_incubation = 'model_dataset_4vars/train/train_incubacion.csv',
  train_brooding = 'model_dataset_4vars/train/train_empollamiento.csv',
  train_chicken_rearing = 'model_dataset_4vars/train/train_crianza.csv',
  test_incubation = 'model_dataset_4vars/test/test_incubacion.csv',
  test_brooding = 'model_dataset_4vars/test/test_empollamiento.csv',
  test_chicken_rearing = 'model_dataset_4vars/test/test_crianza.csv'
)
