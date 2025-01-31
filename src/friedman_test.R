source("functions/eval_utils.R")
library(ggplot2)

graficar_best_score <- function(data, n_vars, metric, directorio = "resultados_comparacion") {
  if (!dir.exists(directorio)) {
    dir.create(directorio, recursive = TRUE)
  }
  
  nombre_archivo <- file.path(directorio, paste0("score_", tolower(metric), "_", n_vars, "vars.png"))
  
  p <- ggplot(data, aes(x = algo, y = evaluation, color = temporada)) +
    geom_point(size = 3) +                   # Añade puntos para cada evaluación
    geom_text(aes(label = round(evaluation, 3)), color = "black", vjust = -0.5, size = 3) +
    labs(title = paste("Mejor puntaje", toupper(metric), "por temporada y algoritmo en modelos de", n_vars, "variables"),
         x = "Algoritmo",
         y = paste("Score", toupper(metric))) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_y_continuous(limits = c(0.56, 0.95))  # Escala de evaluación (Y) entre 0.3 y 1
  
  ggsave(nombre_archivo, plot = p, width = 8, height = 6, dpi = 300)
  return(p)
}


guardar_df_csv <- function(df, n_vars, directorio = "resultados") {
  nombre_df <- deparse(substitute(df))
  nombre_archivo <- paste0(nombre_df, "_", n_vars, "vars.csv")
  
  if (!dir.exists(directorio)) {
    dir.create(directorio, recursive = TRUE)
  }
  
  ruta_archivo <- file.path(directorio, nombre_archivo)
  write.csv(df, file = ruta_archivo, row.names = FALSE, fileEncoding = "UTF-8", quote = FALSE)
  message("Archivo guardado: ", ruta_archivo)
}


pipeline_comparacion_modelos <- function(season_list, n_vars, metric, directorio = "resultados_comparacion") {
  combined_data <- combine_evaluations(season_list, n_vars)
  metric_data <- filter_metric_values(combined_data, metric)
  metric_data_wide <- eval_data_wide(metric_data)
  guardar_df_csv(metric_data_wide, n_vars, directorio)
  
  # Obtener el mejor puntaje por temporada
  best_metric_score_per_season <- get_best_run_per_season(metric_data)
  #print("Mejor puntaje por temporada:")
  #print(best_metric_score_per_season)
  
  # Obtener el mejor puntaje por temporada y algoritmo
  best_metric_score_per_algo <- get_best_run_per_season_and_algorithm(metric_data)
  guardar_df_csv(best_metric_score_per_algo, n_vars, directorio)
  
  # Graficar el mejor puntaje por temporada y algoritmo
  graficar_best_score(best_metric_score_per_algo, n_vars, metric)
  
  # Contar primeros lugares por algoritmo
  first_place_counts <- count_first_place(metric_data_wide)
  print("Conteo de primeros lugares por algoritmo:")
  first_place_counts
  guardar_df_csv(first_place_counts, n_vars, directorio)
  
  # Realizar la prueba de Friedman
  print(paste("Error de tipo I para modelos de", n_vars, "variables"))
  friedman_test <- run_friedman_test(metric_data_wide)
  print(friedman_test)
  
  # Calcular rankings promedio
  print("Calculando rankings promedio")
  rankings_result <- calculate_rankings(metric_data_wide)
  print(rankings_result)
  
  return(list(
    combined_data = combined_data,
    metric_data = metric_data,
    metric_data_wide = metric_data_wide,
    best_metric_score_per_season = best_metric_score_per_season,
    best_metric_score_per_algo = best_metric_score_per_algo,
    first_place_counts = first_place_counts,
    friedman_test = friedman_test,
    rankings_result = rankings_result
  ))
}


pipeline_completo <- function(season_list, n_vars_list, metric_list, directorio_base = "resultados_comparacion") {
  # Iterar sobre el número de variables
  for (n_vars in n_vars_list) {
    # Iterar sobre cada métrica
    for (metric in metric_list) {
      # Generar directorio específico para esta combinación
      directorio <- file.path(directorio_base, paste0(n_vars, "vars_", tolower(metric)))
      
      # Crear el directorio si no existe
      if (!dir.exists(directorio)) {
        dir.create(directorio, recursive = TRUE)
      }
      
      # Ejecutar el pipeline para esta combinación
      print(paste("Procesando:", n_vars, "variables y métrica", metric))
      resultados <- pipeline_comparacion_modelos(season_list, n_vars, metric, directorio)
      
      # Almacenar los resultados en una lista (opcional, si necesitas usarlo en memoria)
      assign(
        paste0("resultados_", n_vars, "vars_", tolower(metric)), 
        resultados, 
        envir = .GlobalEnv
      )
    }
  }
  
  print("Pipeline completo para todas las combinaciones.")
}

season_list <- c("incubacion", "empollamiento", "crianza")
n_vars_list <- c(4, 2)
metric_list <- c("ROC", "TSS", "ACCURACY")

pipeline_completo(season_list, n_vars_list, metric_list)