library(dplyr)
library(tidyr)

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
                        select(temporada, algo, run, metric.eval, evaluation)
    all_evaluations <- append(all_evaluations, list(season_data))
  }
  
  combined_evaluations <- bind_rows(all_evaluations)
  
  return(combined_evaluations)
}

filter_roc_values <- function(data) {
  roc_data <- data %>% filter(metric.eval == "ROC" & run != 'allRun') %>% 
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
  # Aplicar la prueba de Friedman a la matriz de valores
  friedman_test <- friedman.test(as.matrix(data_wide[, -c(1, 2)]))  # Excluir "temporada" y "run"

  return(friedman_test)
}

calculate_rankings <- function(data_wide) {
  ranked_data <- data_wide %>%
    select(-c(temporada, run)) %>%  # Excluir columnas que no son de algoritmos
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

season_list <- c("incubacion", "empollamiento", "crianza")
combined_data_4vars <- combine_evaluations(season_list, 4)
roc_data_4vars <- filter_roc_values(combined_data_4vars)
roc_data_4vars_wide <- eval_data_wide(roc_data_4vars)

best_roc_score <- get_best_run_per_season(roc_data_4vars)
print(best_roc_score)

best_roc_score_per_algo <- get_best_run_per_season_and_algorithm(roc_data_4vars)
print(best_roc_score_per_algo)

friedman_test_4vars <- run_friedman_test(roc_data_4vars_wide)
print(friedman_test_4vars)

rankings_result <- calculate_rankings(roc_data_4vars_wide)

print(rankings_result)





