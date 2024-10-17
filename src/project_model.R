library(ggplot2)
library(biomod2)
library(terra)
source("functions/process_raster_data.R")
source("functions/modeling_tools.R")

# Función para generar el ráster de entorno según la temporada
generate_environment_raster <- function(season, n_vars) {
  if (season == 'incubacion') {
    year <- '2018'
    month <- '01'
  } else if (season == 'crianza') {
    year <- '2017'
    month <- '03'
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
  
  # Cargar los modelos construidos
  modelos <- get_built_models(myBiomodModelOut, run = 'allRun')
  
  # Proyectar los datos
  myBiomodProj <- BIOMOD_Projection(
    bm.mod = myBiomodModelOut,
    new.env = env,
    proj.name = id, 
    binary.meth = c('TSS', 'ROC'),
    compress = TRUE, 
    clamping.mask = FALSE,
    models.chosen = modelos,
    metric.binary = 'ROC',
    metric.filter = 0.75,
    output.format = '.tif',
    on_0_1000 = FALSE,
    nb.cpu = 8
  )
  
  return(myBiomodProj)
}

plot_predictions <- function(myBiomodProj, season, n_vars) {
  myCurrentProj <- get_predictions(myBiomodProj)
  print(myCurrentProj)
  # Crear directorio de salida
  id <- paste0(season, "_", n_vars, "vars")
  output_dir <- paste0("figures/projections/", id, "/")
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Configuración de la ventana de gráficos y guardado de archivos
  for (i in 1:min(5, length(myCurrentProj))) {
    projection_plot <- plot(myCurrentProj[[i]], main = names(myCurrentProj)[i])
    file_name <- paste0(output_dir, "projection_", names(myCurrentProj)[i], ".png")
    
    # Guardar cada proyección como un archivo PNG
    png(filename = file_name, width = 800, height = 600)
    plot(myCurrentProj[[i]], main = names(myCurrentProj)[i])
    dev.off()
  }
  
  # Restablecer la configuración de la ventana de gráficos
  par(mfrow = c(1, 1))
}

# Función principal que integra el flujo completo de proyección y visualización
project_model <- function(season, n_vars) {
  myBiomodModelOut <- load_biomod_model(season, n_vars)
  test_env <- generate_environment_raster(season, n_vars)
  myBiomodProj <- project_biomod_model(myBiomodModelOut, test_env, season, n_vars)
  plot_predictions(myBiomodProj, season, n_vars)
}
