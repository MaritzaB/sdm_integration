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

year_month_list <- list(
  c("2014", "01"), c("2014", "02"), c("2014", "03"), c("2014", "04"), c("2014", "05"), c("2014", "12"),
  c("2015", "01"), c("2015", "02"), c("2015", "03"),
  c("2016", "02"), c("2016", "03"), c("2016", "04"),
  c("2017", "02"), c("2017", "03"),
  c("2018", "01"), c("2018", "02")
)

year_month_train_incubacion <- list(
  c("2014", "01"), c("2014", "12"),
  c("2015", "01")
)

year_month_test_incubacion <- list(
  c("2018", "01")
)

year_month_train_empollamiento <- list(
  c("2014", "02"),
  c("2015", "02"),
  c("2016", "02"),
  c("2017", "02")
)

year_month_test_empollamiento <- list(
  c("2018", "02")
)

year_month_train_crianza <- list(
  c("2014", "03"), c("2014", "04"), c("2014", "05"),
  c("2015", "03"),
  c("2016", "03"), c("2016", "04")
)

year_month_test_crianza <- list(
  c("2017", "03")
)

databases <- list(
  # nombre de la base de datos: ruta al archivo de consulta
  all_presences = list(archivo = "data/others/presence_data.csv",
                       season = year_month_list),
  train_incubacion = list(archivo = 'train/train_incubacion.csv', 
                          season = year_month_train_incubacion),
  train_empollamiento = list(archivo = 'train/train_empollamiento.csv',
                             season = year_month_train_empollamiento),
  train_crianza = list(archivo = 'train/train_crianza.csv',
                       season = year_month_train_crianza),
  test_incubacion = list(archivo = 'test/test_incubacion.csv', 
                         season = year_month_test_incubacion),
  test_empollamiento = list(archivo = 'test/test_empollamiento.csv', 
                            season = year_month_test_empollamiento),
  test_crianza = list(archivo = 'test/test_crianza.csv', 
                      season = year_month_test_crianza)
)

args <- commandArgs(trailingOnly = TRUE)
type_of_dataset <- args[1]
number_of_variables <- 4

if (number_of_variables == 4) {
  out_dir <- "model_dataset_4vars"
} else if (number_of_variables == 2) {
  out_dir <- "model_dataset_2vars"
} else {
  stop("El número de variables no es válido. Debe ser 2 o 4.")
}

if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

if (type_of_dataset == "presence") {
  input_data <- databases[["all_presences"]][["archivo"]]
  out_file <- paste0(out_dir, "/presence_all_presences.csv")
  print(out_file)
  
  generate_full_ml_dataset(
    type_of_dataset, input_data, 
    databases[["all_presences"]][["season"]],
    out_file, number_of_variables
  )
  
} else if (type_of_dataset == "absence") {
  for (name in names(databases)[-1]) {  # Excluyendo all_presences
    input_data <- paste0("presence_data_", number_of_variables, "v/", 
                          databases[[name]][["archivo"]])
    season_data <- databases[[name]][["season"]]
    out_file <- paste0(out_dir, "/absence_", name, ".csv")
    
    generate_full_ml_dataset(
      type_of_dataset, input_data, 
      season_data,
      out_file, number_of_variables
    )
  }
} else {
  stop("El argumento debe ser 'presence' o 'absence'.")
}
