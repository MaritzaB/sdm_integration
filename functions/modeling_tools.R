
calculate_proportions <- function(train_data, test_data, column_name) {
  # Calcular totales generales
  total_train <- nrow(train_data)
  total_test <- nrow(test_data)
  total_data <- total_train + total_test
  
  # Calcular proporciones del total
  train_proportion <- total_train / total_data * 100
  test_proportion <- total_test / total_data * 100
  
  # Calcular totales y proporciones en el conjunto de entrenamiento
  train_presences <- sum(train_data[[column_name]] == 1)
  train_absences  <- sum(train_data[[column_name]] == 0)
  train_presences_proportion <- train_presences / total_train * 100
  train_absences_proportion  <- train_absences / total_train * 100

  # Calcular totales y proporciones en el conjunto de prueba
  test_presences <- sum(test_data[[column_name]] == 1)
  test_absences  <- sum(test_data[[column_name]] == 0)
  test_presences_proportion <- test_presences / total_test * 100
  test_absences_proportion  <- test_absences / total_test * 100

  cat("=== Proporciones del Conjunto Total ===\n")
  cat("Número total de registros:", total_data, "\n")
  cat("Proporción de registros en train_data:", round(train_proportion, 2), "%\n")
  cat("Proporción de registros en test_data:", round(test_proportion, 2), "%\n\n")
  
  cat("=== Conjunto de Entrenamiento ===\n")
  cat("Número de registros en train_data:", total_train, "\n")
  cat("Número de puntos de presencia en train_data:", train_presences, "(", round(train_presences_proportion, 2), "%)\n")
  cat("Número de puntos de ausencia en train_data:", train_absences, "(", round(train_absences_proportion, 2), "%)\n\n")

  cat("=== Conjunto de Prueba ===\n")
  cat("Número de registros en test_data:", total_test, "\n")
  cat("Número de puntos de presencia en test_data:", test_presences, "(", round(test_presences_proportion, 2), "%)\n")
  cat("Número de puntos de ausencia en test_data:", test_absences, "(", round(test_absences_proportion, 2), "%)\n")
}
