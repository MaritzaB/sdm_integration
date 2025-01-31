suppressPackageStartupMessages({
  library(dplyr)
})

get_occurrence_data <- function(year, month, mode = "presence", occurrences_file) {
  occurrences_file <- occurrences_file
  DataSpecies <- read.csv(occurrences_file)
  DataSpecies$nyear <- as.character(DataSpecies$nyear)
  DataSpecies$nmonth <- sprintf("%02d", as.numeric(DataSpecies$nmonth))

  # Si el modo es "presencia", filtrar los datos por año y mes
  if (mode == "presence") {
    filtered_data <- DataSpecies %>%
      filter(nyear == year, nmonth == month) %>%
      select(longitude, latitude, phoebastria_immutabilis)
  } else if (mode == "absence") {
    # Si el modo es "ausencia", no hacer el filtro de las presencias porque
    # vamos a leer todos los datos queya deberían estar filtrados por temporada
    # reproductiva y por tipo de datos (entrenamiento o prueba)
    filtered_data <- DataSpecies %>%
      select(longitude, latitude, phoebastria_immutabilis)
  }
  
  species_name <- "phoebastria_immutabilis"
  species_presence <- filtered_data[, species_name]
  species_coordinates <- filtered_data[, c('longitude', 'latitude')]

  return(list(
    presence_data = species_presence,
    coordinates = species_coordinates,
    species_name = species_name
  ))
}