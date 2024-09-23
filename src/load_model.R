library(biomod2)
library(dplyr)
library(tidyverse)

myRespName <- "NombreDeLaEspecie"

file.out <- "Phoebastria.Immutabilis/Phoebastria.Immutabilis.Prueba.models.out"
print(file.out)
if (file.exists(file.out)) {
    myBiomodModelOut <- get(load(file.out))
    print({"Modelo cargado exitosamente"})
    print(myBiomodModelOut)
}


loadedModel <- BIOMOD_LoadModels(bm.out = myBiomodModelOut)

print("Evaluación del modelo")
myBiomodModelEval <- get_evaluations(myBiomodModelOut)
myBiomodModelEval

print("Importancia de variables")
MyBiomodModelVarImp <- get_variables_importance(myBiomodModelOut)
MyBiomodModelVarImp

