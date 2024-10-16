ignore <- suppressPackageStartupMessages({
  library(dplyr)
})

get_data_directories <- function(number_of_variables) {
  if (number_of_variables == 4) {
    absence_dir <- "model_dataset_4vars/"
    presence_dir <- "presence_data_4v/"
  } else if (number_of_variables == 2) {
    absence_dir <- "model_dataset_2vars/"
    presence_dir <- "presence_data_2v/"
  } else {
    stop("El número de variables no es válido. Debe ser 2 o 4.")
  }
  return(list(absence_dir = absence_dir, presence_dir = presence_dir))
}

# Función para renombrar las columnas del archivo de ausencias
rename_absence_columns <- function(absence_data) {
  absence_data <- absence_data %>%
    rename(
      longitude = x,   # Cambiar col 'x' a 'longitude'
      latitude = y,    # Cambiar col 'y' a 'latitude'
       # Cambiar col 'species_data' a 'phoebastria_immutabilis'
      phoebastria_immutabilis = species_data
    )
  return(absence_data)
}

# Función para filtrar los datos por año y mes
filter_by_year_month <- function(data, year, month) {
  data %>%
    filter(nyear == year, nmonth == month)
}

# Función para tomar una muestra balanceada de ausencias
sample_absences <- function(absences_data, num_presences, sample_ratio) {
  set.seed(235)
  sample_size <- ceiling(num_presences * sample_ratio)
  num_absences <- nrow(absences_data)
  
  if (num_absences > sample_size) {
    absences_sampled <- absences_data %>%
      sample_n(sample_size)
  } else {
    absences_sampled <- absences_data
  }
  
  return(absences_sampled)
}

# Función para balancear los datos por año y mes
balance_data_for_one_month_year <- function(presences_data, absences_data, year, month, sample_ratio = 1.3) {
  presences_filtered <- filter_by_year_month(presences_data, year, month)
  absences_filtered <- filter_by_year_month(absences_data, year, month)
  num_presences <- nrow(presences_filtered)

  absences_filtered <- rename_absence_columns(absences_filtered)
  
  absences_sampled <- sample_absences(absences_filtered, num_presences, sample_ratio)
  combined_data <- bind_rows(presences_filtered, absences_sampled)
  
  return(combined_data)
}

# Función principal para balancear los datos por mes y año
balance_data_by_month_year <- function(presences_data, absences_data, sample_ratio = 1.2) {
  unique_year_months <- presences_data %>%
    select(nyear, nmonth) %>%
    distinct()

  final_dataset <- data.frame()

  for (i in 1:nrow(unique_year_months)) {
    year <- unique_year_months$nyear[i]
    month <- unique_year_months$nmonth[i]
    
    balanced_data <- balance_data_for_one_month_year(presences_data, absences_data, year, month, sample_ratio)
    final_dataset <- bind_rows(final_dataset, balanced_data)
  }
  
  return(final_dataset)
}
