library(biomod2)
source("functions/process_raster_data.R")

file.out <- "Phoebastria.Immutabilis/Phoebastria.Immutabilis.Prueba.models.out"
print(file.out)
if (file.exists(file.out)) {
    myBiomodModelOut <- get(load(file.out))
    print({"Modelo cargado exitosamente"})
    print(myBiomodModelOut)
}

env <- generate_masked_raster('2018', '01')

myBiomodProj <- BIOMOD_Projection(
  modeling.output = myBiomodModelOut,
  new.env = env,
  proj.name = 'Albatros_proj', 
  selected.models = c(
    'Phoebastria.Immutabilis_allData_RUN2_RF',
    'Phoebastria.Immutabilis_allData_RUN1_GLM'
    ), 
  binary.meth = NULL, 
  compress = 'xz', 
  clamping.mask = NULL, 
  output.format = '.grd',
  bm.mod = myBiomodModelOut)

  myBiomodProj