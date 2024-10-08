suppressPackageStartupMessages({
  library(dplyr)
  library(biomod2)
})

# Función para obtener el objeto BIOMOD_FormatingData
get_biomod_data_object <- function(season, n_vars) {
  
  presence_absence_datasets <- list(
    crianza = list(train_file = 'train_crianza.csv',
                   test_file = 'test_crianza.csv'),
    empollamiento = list(train_file = 'train_empollamiento.csv',
                         test_file = 'test_empollamiento.csv'),
    incubacion = list(train_file = 'train_incubacion.csv',
                      test_file = 'test_incubacion.csv')
  )
  
  if (n_vars == 4) {
    data_dir <- "presence_absence_4vars/"
    environmental_features <- c("sst", "chlc", "wind_speed", "wind_direction")
  } else if (n_vars == 2) {
    data_dir <- "presence_absence_2vars/"
    environmental_features <- c("sst", "chlc")
  } else {
    stop("El número de variables no es válido. Debe ser 2 o 4.")
  }
  
  train_data_name <- paste0(data_dir, presence_absence_datasets[[season]]$train_file)
  test_data_name <- paste0(data_dir, presence_absence_datasets[[season]]$test_file)
  print("Archivos de datos:")
  print(train_data_name)
  print(test_data_name)

  train_data <- read.csv(train_data_name)
  test_data <- read.csv(test_data_name)
  
  n_obs <- nrow(train_data)
  train_data <- train_data[sample(n_obs),]
  print("Dimensiones del conjunto de entrenamiento")
  print(dim(train_data))
  
  coordinates_columns <- c("longitude", "latitude")
  
  binary_class_train_set <- train_data$phoebastria_immutabilis
  environmental_variables_train <- train_data[, environmental_features]
  coordinates_train <- train_data[, coordinates_columns]
  
  species_presence_data_test <- test_data$phoebastria_immutabilis
  environmental_variables_test <- test_data[, environmental_features]
  coordinates_test <- test_data[, coordinates_columns]
  print("Dimensiones del conjunto de prueba")
  print(dim(test_data))
  
  species_biomod_data <- BIOMOD_FormatingData(
    resp.var = binary_class_train_set,
    expl.var = environmental_variables_train,
    resp.xy = coordinates_train,
    resp.name = 'Phoebastria Immutabilis',
    eval.resp.var = species_presence_data_test,
    eval.expl.var = environmental_variables_test,
    eval.resp.xy = coordinates_test
  )
  
  return(species_biomod_data)
}
