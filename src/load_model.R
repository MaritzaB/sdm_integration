library(biomod2)
library(dplyr)
library(tidyverse)


file.out <- "Phoebastria.Immutabilis/Phoebastria.Immutabilis.Prueba.models.out"
print(file.out)
if (file.exists(file.out)) {
    myBiomodModelOut <- get(load(file.out))
    print({"Modelo cargado exitosamente"})
    print(myBiomodModelOut)
}

print("Evaluación del modelo")
myBiomodModelEval <- get_evaluations(myBiomodModelOut)
myBiomodModelEval

bm_PlotEvalMean(bm.out = myBiomodModelOut, dataset = 'calibration')
bm_PlotEvalBoxplot(bm.out = myBiomodModelOut, group.by = c('algo', 'algo'))

#print("Importancia de variables")
#MyBiomodModelVarImp <- get_variables_importance(myBiomodModelOut)
#MyBiomodModelVarImp

