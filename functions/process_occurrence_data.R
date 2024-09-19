library(dplyr)

get_occurrence_data <- function(year, month) {
  occurrences_file <- "data/trajectories.csv"
  DataSpecies <- read.csv(occurrences_file)
  DataSpecies$nyear <- as.character(DataSpecies$nyear)
  DataSpecies$nmonth <- sprintf("%02d", as.numeric(DataSpecies$nmonth))

  # Filtrar los datos por año y mes
  filtered_data <- DataSpecies %>%
    filter(nyear == year, nmonth == month) %>%
    select(longitude, latitude, phoebastria_immutabilis)

  species_name <- "phoebastria_immutabilis"
  species_presence <- filtered_data[, species_name]
  species_coordinates <- filtered_data[, c('longitude', 'latitude')]

  return(list(
    presence_data = species_presence,
    coordinates = species_coordinates,
    species_name = species_name
    ))
}
