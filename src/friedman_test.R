source("functions/eval_utils.R")

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

friedman_test_4vars <- run_friedman_test(roc_data_4vars_wide)
print(friedman_test_4vars)

print("Calculando rankings promedio")
rankings_result <- calculate_rankings(roc_data_4vars_wide)
print(rankings_result)


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

friedman_test_2vars <- run_friedman_test(roc_data_2vars_wide)
print(friedman_test_2vars)

print("Calculando rankings promedio")
rankings_result <- calculate_rankings(roc_data_2vars_wide)
print(rankings_result)

print("Contando cuántas veces cada algoritmo estuvo en primer lugar")
first_place_counts <- count_first_place(roc_data_2vars_wide)
print(first_place_counts)

best_models_crianza <- get_best_model_names_by_season(best_roc_score_per_algo, "crianza")
print("Mejores modelos para la temporada de crianza")
print(best_models_crianza)
