suppressPackageStartupMessages({
  library(dplyr)
})

filter_by_month_year <- function(dataset, month) {
  # Hasta ahorita, las pseudoausencias para el conjunto de prueba, se generaron
  # con los datos de 2014-2017 para los meses de enero y febrero, y con los
  # datos de 2014-2016 para el mes de marzo. Hay que evaluar si vamos a generar
  # pseudoausencias tomando en  cuenta solo las ocurrencias de 2018 o si vamos a
  # considerar los datos de 2014-2018.
  if (month %in% c("01", "02")) {
    dataset <- dataset %>%
      filter(nyear < 2018, nmonth == month) %>%
       select(longitude, latitude, phoebastria_immutabilis)
  } else if (month == "03") {
    dataset <- dataset %>%
      filter(nyear < 2017, nmonth == month) %>%
      select(longitude, latitude, phoebastria_immutabilis)
  } else {
    stop("Mes no soportado en la función.")
  }
  return(dataset)
}


get_occurrence_data <- function(year, month) {
  occurrences_file <- "data/trajectories.csv"
  DataSpecies <- read.csv(occurrences_file)
  DataSpecies$nyear <- as.character(DataSpecies$nyear)
  DataSpecies$nmonth <- sprintf("%02d", as.numeric(DataSpecies$nmonth))

  # Filtrar los datos por año y mes
  #filtered_data <- DataSpecies %>%
  #    filter(nyear == year, nmonth == month) %>%
  #    select(longitude, latitude, phoebastria_immutabilis)
  filtered_data <- filter_by_month_year(DataSpecies, month)
  species_name <- "phoebastria_immutabilis"
  species_presence <- filtered_data[, species_name]
  species_coordinates <- filtered_data[, c('longitude', 'latitude')]

  return(list(
    presence_data = species_presence,
    coordinates = species_coordinates,
    species_name = species_name
    ))
}
