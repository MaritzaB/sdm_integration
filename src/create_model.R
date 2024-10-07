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

cv.k <- bm_CrossValidation(bm.format = biomod_crianza,
  strategy = 'kfold',
  nb.rep = 5,
  k = 10)

print(dim(cv.k))


opt.df <- bm_ModelingOptions(data.type = 'binary',
  models = c('RF'),
  strategy = 'default',
  bm.format = biomod_crianza,
  calib.lines = cv.k)

myBiomodelOut <- BIOMOD_Modeling(
  bm.format = biomod_crianza,
  modeling.id = 'incubacion',
  models = c('RF'),
  CV.strategy = 'kfold',
  CV.nb.rep = 5,
  CV.k = 10,
  OPT.strategy = 'tuned',
  metric.eval = c('TSS', 'ROC'),
  var.import = 4,
  seed.val = 42)

myCalibLines <- get_calib_lines(myBiomodelOut)
myCalibLines
#plot(biomod_crianza, calib.lines = myCalibLines)
  
