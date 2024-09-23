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
  source("functions/modeling_tools.R")
})

data <- read.csv("model_dataset/full_ml_dataset.csv")

# Dividir en train (2014-2017) y test (2018)
train_data <- data %>% filter(nyear >= 2014 & nyear <= 2017)
test_data  <- data %>% filter(nyear == 2018)

calculate_proportions(train_data, test_data, column_name = "species_data")

set.seed(24)

environmental_features <- c("sst", "chlc", "wind_speed", "wind_direction")
coordinates_columns <- c("x", "y")

species_presence_data_train <- train_data$species_data
environmental_variables_train <- train_data[, environmental_features]
coordinates_train <- train_data[, coordinates_columns]

species_presence_data_test <- test_data$species_data
environmental_variables_test <- test_data[, environmental_features]
coordinates_test <- test_data[, coordinates_columns]

# Crear el objeto BIOMOD_FormatingData
species_biomod_data <- BIOMOD_FormatingData(
  resp.var = species_presence_data_train,
  expl.var = environmental_variables_train,
  resp.xy = coordinates_train,
  resp.name = 'Phoebastria Immutabilis',
  eval.resp.var = species_presence_data_test,
  eval.expl.var = environmental_variables_test,
  eval.resp.xy = coordinates_test
)

# Mostrar resumen del objeto creado
print(species_biomod_data)
#
## k-fold selection
#cv.k <- bm_CrossValidation(
#  bm.format = species_biomod_data,
#  strategy = "kfold",
#  nb.rep = 2,
#  k = 3
#)
#

set.seed(24)

# Definir los algoritmos de clasificación binaria que deseas utilizar

# binary_algorithms <- c("GLM", "RF", "GAM", "GBM")
binary_algorithms <- c("RF", "GLM")

 
myBiomodModelOut <- BIOMOD_Modeling(
  bm.format = species_biomod_data,
  modeling.id = 'Prueba',
  models = binary_algorithms,
  CV.strategy = 'random',
  CV.nb.rep = 2,
  CV.perc = 0.8,
  OPT.strategy = 'bigboss',
  metric.eval = c('TSS','ROC', 'ACCURACY'),
  var.import = 3,
  seed.val = 42)


