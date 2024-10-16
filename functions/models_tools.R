# Función para cargar el modelo si existe
load_biomod_model <- function(season, n_vars) {
  id <- paste0(season, "_", n_vars, "vars")
  file.out <- paste0("Phoebastria.Immutabilis/Phoebastria.Immutabilis.", id, ".models.out")
  
  print(file.out)
  
  if (file.exists(file.out)) {
    myBiomodModelOut <- get(load(file.out))
    print("Modelo cargado exitosamente")
    print(myBiomodModelOut)
    return(myBiomodModelOut)
  } else {
    stop("El archivo del modelo no existe.")
  }
}
