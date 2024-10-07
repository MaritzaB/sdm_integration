suppressPackageStartupMessages({
  library(dplyr)
  library(biomod2)
  library(nnet)
  library(rpart)
  library(mda)
  library(class)
  library(gam)
  library(splines)
  library(foreach)
  library(mgcv)
  library(nlme)
  library(lattice)
  source("functions/create_biomod_data_object.R")
})

n_vars <- 4
biomod_crianza <- get_biomod_data_object("incubacion", n_vars)
plot(biomod_crianza)
#print(biomod_crianza)
binary_algorithms <- c("RF")

myBiomodModelOut <- BIOMOD_Modeling(
  bm.format = biomod_crianza,
  modeling.id = "Incubacion_RF_prueba",
  models = 'RF',
  OPT.data.type = "binary.PA",
  #OPT.stategy = "bigboss",
  #CV.strategy = 'kfold',
  #CV.nb.rep = 1,
  #CV.k = 5,
  CV.do.full.models = FALSE,
  metric.eval = c('TSS', 'ROC'),
  var.import = 3,
  seed.val = 42
)

#bm_FindOptimStat(metric.eval = 'ROC', models.out = myBiomodModelOut)

