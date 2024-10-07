library(biomod2)
library(dplyr)
library(tidyverse)
source("functions/create_biomod_data_object.R")

file.out <- "Phoebastria.Immutabilis/Phoebastria.Immutabilis.incubacion.models.out"
#sink("OutputBiomodModel.txt")
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
bm_PlotEvalMean(bm.out = myBiomodModelOut, dataset = 'evaluation')

#bm_PlotEvalBoxplot(bm.out = myBiomodModelOut, group.by = c('algo', 'run'), dataset = 'calibration')
#bm_PlotEvalBoxplot(bm.out = myBiomodModelOut, group.by = c('algo', 'run'), dataset = 'evaluation')
bm_PlotEvalBoxplot(bm.out = myBiomodModelOut, group.by = c('algo', 'algo'), dataset = 'calibration')
bm_PlotEvalBoxplot(bm.out = myBiomodModelOut, group.by = c('algo', 'algo'), dataset = 'evaluation')

n_runs <- c("RUN1", "RUN2", "RUN3", "RUN4", "RUN5", "RUN6", "RUN7", "RUN8", "RUN9", "RUN10")
mods <- get_built_models(myBiomodModelOut, run = n_runs)
bm_PlotResponseCurves(
    bm.out = myBiomodModelOut,
    models.chosen = mods,
    fixed.var = 'median')
bm_PlotResponseCurves(
    bm.out = myBiomodModelOut,
    models.chosen = mods,
    fixed.var = 'min')

#mods <- get_built_models(
#    myBiomodModelOut,
#    full.name = 'LAAL_RUN2_RF')
#bm_PlotResponseCurves(
#    bm.out = myBiomodModelOut,
#    models.chosen = mods,
#    fixed.var = 'median',
#    do.bivariate = TRUE)

#print("Importancia de variables")
#MyBiomodModelVarImp <- get_variables_importance(myBiomodModelOut)
#MyBiomodModelVarImp
#sink()

