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
  source("src/project_model.R")
  source("functions/modeling_tools.R")
})

create_biomod_model <- function(season, n_vars) {
  # Crear el id para el modelado
  id <- paste0(season, "_", n_vars, "vars")
  print(id)
  
  # Obtener el objeto biomod
  biomod_crianza <- get_biomod_data_object(season, n_vars)
  print(biomod_crianza)
  
  # Modelos a utilizar
  single_models <- c('GLM', 'GAM', 'GBM', 'MARS', 'RF')
  
  # Configuración para Random Forest
  RF <- list(
    do.classif = TRUE,
    ntree = 100,
    mtry = 2,
    nodesize = 2,
    maxnodes = NULL
  )
  
  # Configuración de user.val para Random Forest
  user.val <- list(
    'RF.binary.randomForest.randomForest' = list('_allData_allRun' = RF)
  )
  
  # Opciones de modelado
  myOpt <- bm_ModelingOptions(
    data.type = 'binary',
    models = single_models,
    strategy = 'user.defined',
    user = user.val,
    user.base = 'bigboss',
    bm.format = biomod_crianza
  )
  
  # Ejecutar el modelado
  myBiomodelOut <- BIOMOD_Modeling(
    bm.format = biomod_crianza,
    modeling.id = id,
    models = single_models,
    CV.strategy = 'strat',
    CV.nb.rep = 10,
    CV.k = 5,
    CV.balance = 'presences',
    CV.strat = 'x',
    OPT.user = myOpt,
    metric.eval = c('ACCURACY', 'TSS', 'ROC'),
    var.import = 4,
    seed.val = 42
  )
  
  # Obtener las opciones del modelo
  get_options(myBiomodelOut)
}
