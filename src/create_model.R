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
biomod_crianza

single_models <- c('GLM', 'GAM', 'GBM','MARS', 'RF')

myBiomodelOut <- BIOMOD_Modeling(
  bm.format = biomod_crianza,
  modeling.id = 'incubacion',
  models = single_models,
  CV.strategy = 'strat',
  CV.nb.rep = 10,
  CV.k = 5,
  CV.balance = 'presences',
  CV.strat = 'x',
  OPT.strategy = 'bigboss',
  metric.eval = c('TSS', 'ROC', 'ACCURACY'),
  var.import = 4,
  seed.val = 42)
 
