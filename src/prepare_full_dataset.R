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
# Si vamos a generar pseudo-ausencias, entonces los archivos de entrada van a
# ser los de presencia ya filtrados por temporada reproductiva y por tipo de
# datos (entrenamiento o prueba). Por lo que generaremos una lista de archivos.
args <- commandArgs(trailingOnly = TRUE)
type_of_dataset <- args[1]
number_of_variables <- 2

if (number_of_variables == 4) {
  out_dir <- "model_dataset_4vars"
} else if (number_of_variables == 2) {
  out_dir <- "model_dataset_2vars"
} else {
  stop("El número de variables no es válido. Debe ser 2 o 4.")
}

input_data <- "data/others/presence_data.csv"
generate_full_ml_dataset(
  type_of_dataset, input_data, 
  year_month_list, out_dir, number_of_variables)


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
