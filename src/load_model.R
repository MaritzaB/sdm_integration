library(biomod2)
library(dplyr)
library(tidyverse)
library(ggplot2)
source("functions/create_biomod_data_object.R")
source("functions/process_raster_data.R")
source("functions/modeling_tools.R")

# Función para evaluar el modelo
evaluate_biomod_model <- function(myBiomodModelOut) {
  print("Evaluación del modelo")
  myBiomodModelEval <- get_evaluations(myBiomodModelOut)
  return(myBiomodModelEval)
}

# Función para crear el directorio de salida si no existe
create_output_directory <- function(season, n_vars) {
  id <- paste0(season, "_", n_vars, "vars")
  out_dir <- paste0("figures/", id, "/")
  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE)
  }
  return(out_dir)
}

# Función para generar y guardar el boxplot de evaluación del conjunto de entrenamiento y prueba
generate_evaluation_boxplots <- function(myBiomodModelOut, out_dir, scales = "fixed") {
  training_boxplot <- bm_PlotEvalBoxplot(
    bm.out = myBiomodModelOut, 
    group.by = c('algo', 'algo'), 
    dataset = 'calibration', 
    do.plot = FALSE,
    scales = scales)
  testing_boxplot <- bm_PlotEvalBoxplot(
    bm.out = myBiomodModelOut,
    group.by = c('algo', 'algo'),
    dataset = 'evaluation',
    do.plot = FALSE,
    scales = scales)
  
  # Personalizar y guardar gráficos
  training_boxplot_gg <- training_boxplot$plot +
    ggtitle("Evaluación del Modelo - Conjunto de entrenamiento") +
    xlab("Método de clasificación") +
    ylab("Valor de la métrica de evaluación") +
    theme(plot.title = element_text(hjust = 0.5))
  
  training_boxplot_filename <- paste0(out_dir, "boxplot_evaluacion_trainingSet.png")
  ggsave(filename = training_boxplot_filename, plot = training_boxplot_gg, width = 8, height = 6)
  
  testing_boxplot_gg <- testing_boxplot$plot +
    ggtitle("Evaluación del Modelo - Conjunto de prueba") +
    xlab("Método de clasificación") +
    ylab("Valor de la métrica de evaluación") +
    theme(plot.title = element_text(hjust = 0.5))
  
  testing_boxplot_filename <- paste0(out_dir, "boxplot_evaluacion_testingSet.png")
  ggsave(filename = testing_boxplot_filename, plot = testing_boxplot_gg, width = 8, height = 6)
}

# Función para calcular e imprimir la importancia de las variables
generate_variable_importance_plot <- function(myBiomodModelOut, out_dir) {
  print("Importancia de variables")
  MyBiomodModelVarImp <- get_variables_importance(myBiomodModelOut)
  df <- MyBiomodModelVarImp[, 3:ncol(MyBiomodModelVarImp)]
  avg_var_importance <- df %>%
    group_by(algo, expl.var) %>%
    summarize(mean_importance = mean(var.imp), .groups = 'drop')
  
  plot_var_importance <- ggplot(avg_var_importance, aes(x = reorder(expl.var, mean_importance), y = mean_importance, fill = algo)) +
    geom_bar(stat = "identity", position = "dodge") +
    coord_flip() +
    labs(title = "Importancia Promedio de las Variables por Algoritmo",
         x = "Variable",
         y = "Importancia Promedio") +
    theme(plot.title = element_text(hjust = 0.5))
  
  plot_var_importance_filename <- paste0(out_dir, "importancia_variables.png")
  ggsave(filename = plot_var_importance_filename, plot = plot_var_importance, width = 10, height = 6)
}

# Función principal que integra todo el flujo
get_model_evaluations <- function(season, n_vars) {
  myBiomodModelOut <- load_biomod_model(season, n_vars)
  evaluate_biomod_model(myBiomodModelOut)
  out_dir <- create_output_directory(season, n_vars)
  generate_evaluation_boxplots(myBiomodModelOut, out_dir)
  generate_variable_importance_plot(myBiomodModelOut, out_dir)
}