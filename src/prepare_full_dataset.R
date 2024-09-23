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
    create_modeling_dataset(year, month, apply_filter_raster = FALSE)
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

output_directory <- "model_dataset"
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

output_file <- file.path(output_directory, "full_ml_dataset.csv")
write.csv(full_ml_dataset, file = output_file, row.names = FALSE)
cat("Proceso completado. Archivo CSV guardado en:", output_file, "\n")
