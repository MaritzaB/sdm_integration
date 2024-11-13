source("functions/eval_utils.R")
library(ggplot2)

graficar_best_score_roc <- function(data, n_vars, nombre_archivo = "score_roc.png") {
  p <- ggplot(data, aes(x = algo, y = evaluation, color = temporada)) +
    geom_point(size = 3) +                   # Añade puntos para cada evaluación
    geom_text(aes(label = round(evaluation, 3)), color = "black", vjust = -0.5, size = 3) +
    labs(title = paste("Mejor puntaje ROC por temporada y algoritmo en modelos de", n_vars, "variables"),
         x = "Algoritmo",
         y = "Score ROC") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # Guardar el plot como archivo PNG
  ggsave(nombre_archivo, plot = p, width = 8, height = 6, dpi = 300)
  
  # Retornar el plot para visualizar en R si se desea
  return(p)
}

season_list <- c("incubacion", "empollamiento", "crianza")
combined_data_4vars <- combine_evaluations(season_list, 4)
roc_data_4vars <- filter_roc_values(combined_data_4vars)
roc_data_4vars
roc_data_4vars_wide <- eval_data_wide(roc_data_4vars)
roc_data_4vars_wide

best_roc_score <- get_best_run_per_season(roc_data_4vars)
print("Mejor puntaje ROC por temporada")
print(best_roc_score)

best_roc_score_per_algo <- get_best_run_per_season_and_algorithm(roc_data_4vars)
print("Mejor puntaje ROC por temporada y algoritmo")
print(best_roc_score_per_algo)
graficar_best_score_roc(best_roc_score_per_algo, 4, "figures/score_roc_4vars.png")

friedman_test_4vars <- run_friedman_test(roc_data_4vars_wide)
print(friedman_test_4vars)

print("Calculando rankings promedio")
rankings_result <- calculate_rankings(roc_data_4vars_wide)
print(rankings_result)

print("Contando cuántas veces cada algoritmo estuvo en primer lugar para modelos de 4 variables")
first_place_counts <- count_first_place(roc_data_4vars_wide)
print(first_place_counts)

#best_models_crianza <- get_best_model_names_by_season(best_roc_score_per_algo, "crianza")
#print("Mejores modelos para la temporada de crianza")
#print(best_models_crianza)


## Prueba de Friedman para 2 variables
combined_data_2vars <- combine_evaluations(season_list, 2)
roc_data_2vars <- filter_roc_values(combined_data_2vars)
roc_data_2vars_wide <- eval_data_wide(roc_data_2vars)
roc_data_2vars_wide

best_roc_score <- get_best_run_per_season(roc_data_2vars)
print("Mejor puntaje ROC por temporada")
print(best_roc_score)

best_roc_score_per_algo <- get_best_run_per_season_and_algorithm(roc_data_2vars)
print("Mejor puntaje ROC por temporada y algoritmo")
print(best_roc_score_per_algo)
graficar_best_score_roc(best_roc_score_per_algo, 2, "figures/score_roc_2vars.png")

friedman_test_2vars <- run_friedman_test(roc_data_2vars_wide)
print(friedman_test_2vars)

print("Calculando rankings promedio")
rankings_result <- calculate_rankings(roc_data_2vars_wide)
print(rankings_result)

print("Contando cuántas veces cada algoritmo estuvo en primer lugar para modelos de 2 variables")
first_place_counts <- count_first_place(roc_data_2vars_wide)
print(first_place_counts)

best_models_crianza <- get_best_model_names_by_season(best_roc_score_per_algo, "crianza")
print("Mejores modelos para la temporada de crianza")
print(best_models_crianza)
