suppressPackageStartupMessages({
  library(ggplot2)
  library(biomod2)
  library(terra)
  source("functions/process_raster_data.R")
  source("functions/modeling_tools.R")
  source("functions/eval_utils.R")
})

# Función para generar el ráster de entorno según la temporada
generate_environment_raster <- function(season, n_vars) {
  if (season == 'incubacion') {
    year <- '2018'
    month <- '01'
  } else if (season == 'crianza') {
    year <- '2016'
    month <- '04'
  } else if (season == 'empollamiento') {
    year <- '2018'
    month <- '02'
  } else {
    stop("Temporada no reconocida.")
  }

  env <- generate_masked_raster(year, month, n_vars)
  return(env)
}

# Función para proyectar los datos usando el modelo cargado
project_biomod_model <- function(myBiomodModelOut, env, season, n_vars) {
  id <- paste0(season, "_", n_vars, "vars")
  print(paste0("Proyectando datos de la temporada:", id))
  
  modelos <- get_built_models(myBiomodModelOut, run = 'RUN1')

  # Descomentar para usar los mejores modelos por temporada
  #best_metric_score_per_algo <- read.csv(paste0("resultados_comparacion/",n_vars, "vars_roc/best_metric_score_per_algo_",n_vars,"vars.csv"))
  #modelos <- get_best_model_names_by_season(best_metric_score_per_algo, season)
  print("Modelos seleccionados:")
  print(modelos)

  # Proyectar los datos
  myBiomodProj <- BIOMOD_Projection(
    bm.mod = myBiomodModelOut,
    new.env = env,
    proj.name = id, 
    binary.meth = c('TSS'),
    compress = TRUE, 
    clamping.mask = FALSE,
    models.chosen = modelos,
    metric.binary = 'TSS',
#    metric.filter = 0,
    on_0_1000 = FALSE,
    nb.cpu = 8
  )
  
  return(myBiomodProj)
}


plot_predictions <- function(myBiomodProj, season, n_vars) {
  myCurrentProj <- get_predictions(myBiomodProj)
  output_dir <- paste0("figures/projections/", season, "_", n_vars, "vars")
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Configurar archivo PDF para guardar los gráficos
  file_name <- paste0(output_dir, "/prediction_maps_", season, "_", n_vars, "vars.pdf")
  pdf(file = file_name, width = 4, height = 12)
  par(mfrow = c(5, 1), mar = c(0,0,0,0))

  # Iterar sobre las predicciones y reescalar
  for (i in 1:5) {
    rescaled_map <- myCurrentProj[[i]]
    full_name <- names(myCurrentProj[[i]])
    algorithm_name <- gsub(".*_allData_RUN1_", "", full_name)
    plot(
      rescaled_map,
      main = algorithm_name,
      cex.main = 1.5,
      col = viridis::plasma(20),  # Paleta de colores viridis con 100 niveles
      axes = TRUE,
      legend = TRUE,
      box = TRUE,
      barplot = TRUE,
      zlim = c(0, 100)
    )
  }

  dev.off()
  par(mfrow = c(1, 1))  # Restaurar configuración gráfica
}


# Función principal que integra el flujo completo de proyección y visualización
project_model <- function(season, n_vars) {
  myBiomodModelOut <- load_biomod_model(season, n_vars)
  test_env <- generate_environment_raster(season, n_vars)
  myBiomodProj <- project_biomod_model(myBiomodModelOut, test_env, season, n_vars)
  plot_predictions(myBiomodProj, season, n_vars)
}

seasons <- c("incubacion", "empollamiento", "crianza")

# Lista de configuraciones de variables
variables <- c(2,4)

# Iterar sobre temporadas y configuraciones
for (season in seasons) {
  for (n_vars in variables) {
    cat("Procesando:", season, "con", n_vars, "variables...\n")
    project_model(season, n_vars)
  }
}
