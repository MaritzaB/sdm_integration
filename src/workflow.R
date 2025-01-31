source("src/create_model.R")
source("src/load_model.R")


seasons <- c('incubacion', 'empollamiento', 'crianza')
nvariables <- c(2,4)
single_models <- c('GLM', 'MARS', 'RF', 'GBM', 'MAXNET')

for (season in seasons) {
  for (n_vars in nvariables) {
    # Registrar el tiempo de inicio
    start_time <- Sys.time()
    formatted_start_time <- format(start_time, "%Y-%m-%d %H:%M:%S")
    
    cat("=========================================\n")
    cat("🌟 Iniciando proceso\n")
    cat("📅 Temporada:", season, "\n")
    cat("🔢 Número de variables:", n_vars, "\n")
    cat("🕒 Hora de inicio:", formatted_start_time, "\n")
    cat("=========================================\n\n")
    
    # Ejecutar las funciones del flujo de trabajo
    create_biomod_model(season, n_vars, single_models)
    get_model_evaluations(season, n_vars)
    #project_model(season, n_vars)
    
    # Registrar el tiempo de finalización
    end_time <- Sys.time()
    formatted_end_time <- format(end_time, "%Y-%m-%d %H:%M:%S")
    
    cat("=========================================\n")
    cat("✅ Proceso terminado\n")
    cat("📅 Temporada:", season, "\n")
    cat("🔢 Número de variables:", n_vars, "\n")
    cat("🕒 Hora de finalización:", formatted_end_time, "\n")
    
    # Calcular la duración del proceso
    duration <- difftime(end_time, start_time, units = "mins")
    cat("⏳ Tiempo total:", round(duration, 2), "minutos\n")
    cat("=========================================\n\n")
  }
}

