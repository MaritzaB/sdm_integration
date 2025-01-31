library(dplyr)
library(tidyr)
library(PMCMRplus)

get_season_file <- function(season, nvars) {
  file <- paste0("figures/", season, "_", nvars, "vars/eval_", season, "_", nvars, "vars.csv")
  return(file)
}

combine_evaluations <- function(season_list, nvars) {
  all_evaluations <- list()
  
  for (season in season_list) {
    file <- get_season_file(season, nvars)
    season_data <- read.csv(file) %>% 
                        mutate(temporada = season) %>% 
                        select(
                          full.name,
                          temporada, algo, run, metric.eval, sensitivity, specificity, evaluation)
    all_evaluations <- append(all_evaluations, list(season_data))
  }
  combined_evaluations <- bind_rows(all_evaluations)
  return(combined_evaluations)
}

filter_metric_values <- function(data, metric = "ROC") {
  roc_data <- data %>% filter(metric.eval == metric & run != 'allRun') %>% 
        select(temporada, algo, run, evaluation)
  return(roc_data)
}

get_best_run_per_season_and_algorithm <- function(data) {
  best_run_data <- data %>%
    group_by(temporada, algo) %>%
    filter(evaluation == max(evaluation, na.rm = TRUE)) %>%
    slice(1)
  
  return(best_run_data)
}

get_best_run_per_season <- function(data) {
  best_run_data <- data %>%
    group_by(temporada) %>%
    filter(evaluation == max(evaluation, na.rm = TRUE)) %>%
    slice(1)
  return(best_run_data)
}

eval_data_wide <- function(data) {
  data_wide <- data %>% 
        pivot_wider(
            names_from = algo,
            values_from = evaluation
            )
  return(data_wide)
}

run_friedman_test <- function(data_wide) {
  # Transformar los valores de ROC a 1 - ROC
  data_transformed <- data_wide %>%
    mutate(across(GLM:MAXNET, ~ 1 - .))
  # Aplicar la prueba de Friedman a la matriz transformada
  #friedman_test <- friedman.test(as.matrix(data_wide[, -c(1,2)]))
  friedman_test <- friedman.test(as.matrix(data_transformed[, -c(1, 2)]))  # Excluir "temporada" y "run"
  p_value <- friedman_test[["p.value"]]
  print(paste("El valor p de la prueba de Friedman es:", p_value))

  if (p_value < 0.05) {
    cat("Hay diferencias estadísticamente significativas entre los algoritmos (p < 0.05).\n")
    cat("La hipótesis nula se RECHAZA.\n")
  } else {
    cat("No hay diferencias estadísticamente significativas entre los algoritmos (p ≥ 0.05).\n")
    cat("La hipótesis nula se ACEPTA.\n")
  }
  return(friedman_test)
}

get_best_model_names_by_season <- function(data, season) {
  selected_data <- data %>%
    filter(temporada == season) %>%
    mutate(model_name = paste("Phoebastria.Immutabilis_allData", run, algo, sep = "_")) %>%
    pull(model_name)
  concatenated_string <- paste(selected_data, collapse = ", ")
  concatenated_string <- strsplit(concatenated_string, ", ")[[1]]
  return(concatenated_string)
}

calculate_rankings <- function(data_wide) {
  ranked_data <- data_wide %>%
    select(-c( temporada, run)) %>%  # Excluir columnas que no son de algoritmos
    apply(1, rank, ties.method = "average") %>%  
        t() %>%
        as.data.frame()

  colnames(ranked_data) <- colnames(data_wide)[-c(1, 2)]
  average_rankings <- colMeans(ranked_data)
  rankings <- data.frame(Algorithm = names(average_rankings),
                         Average_Rank = average_rankings) %>%
    arrange(Average_Rank)
  
  return(rankings)
}

count_first_place <- function(data) {
  # Aplicar el ranking fila por fila para encontrar el algoritmo con el valor
  # más alto
  algorithm_names <- c("GLM", "MARS", "RF", "GBM", "MAXNET")
  ranked_data <- data %>%
    rowwise() %>%
    mutate(first_place = colnames(data[, algorithm_names])[which.max(c_across(all_of(algorithm_names)))]) %>%
    ungroup()
  
  # Contar cuántas veces cada algoritmo estuvo en primer lugar
  first_place_counts <- ranked_data %>%
    count(first_place, name = "count") %>%
    complete(first_place = algorithm_names, fill = list(count = 0)) %>%
    arrange(desc(count))

  colnames(first_place_counts) <- c("Algoritmo", "Conteo")
  
  return(first_place_counts)
}

#n_vars <- 2
#best_metric_score_per_algo <- read.csv(paste0("resultados_comparacion/",n_vars, "vars_roc/best_metric_score_per_algo_",n_vars,"vars.csv"))
#  modelos <- get_best_model_names_by_season(best_metric_score_per_algo, "crianza")
#  modelos <- strsplit(modelos, ", ")[[1]]
#  print("Modelos seleccionados:")
#  print(modelos)