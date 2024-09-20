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
})

data <- read.csv("model_dataset/full_ml_dataset.csv")

# Dividir en train (2014-2017) y test (2018)
train_data <- data %>% filter(nyear >= 2014 & nyear <= 2017)
test_data  <- data %>% filter(nyear == 2018)

# Calcular proporciones
total_rows <- nrow(data)
train_proportion <- nrow(train_data) / total_rows * 100
test_proportion  <- nrow(test_data) / total_rows * 100

cat("Número de registros en train_data:", nrow(train_data), "(", round(train_proportion, 2), "%)\n")
cat("Número de registros en test_data:", nrow(test_data), "(", round(test_proportion, 2), "%)\n")

set.seed(24)

# Preparar los datos de entrenamiento y prueba
species_presence_data_train <- train_data$species_data  # Variable de respuesta para entrenamiento
environmental_variables_train <- train_data[, c("sst", "chlc", "wind_speed", "wind_direction")]  # Variables explicativas para entrenamiento
coordinates_train <- train_data[, c("x", "y")]  # Coordenadas de entrenamiento

species_presence_data_test <- test_data$species_data  # Variable de respuesta para prueba
environmental_variables_test <- test_data[, c("sst", "chlc", "wind_speed", "wind_direction")]  # Variables explicativas para prueba
coordinates_test <- test_data[, c("x", "y")]  # Coordenadas de prueba

# Crear el objeto BIOMOD_FormatingData con parámetros adicionales
species_biomod_data <- BIOMOD_FormatingData(
  resp.var = species_presence_data_train,
  expl.var = environmental_variables_train,
  resp.xy = coordinates_train,
  resp.name = 'NombreDeLaEspecie',  # Cambia a tu especie específica
  
  eval.resp.var = species_presence_data_test,
  eval.expl.var = environmental_variables_test,
  eval.resp.xy = coordinates_test,
  
  PA.nb.rep = 0,          # No se generan pseudo-ausencias
  PA.nb.absences = NULL,  # Número de pseudo-ausencias
  PA.strategy = NULL,     # Estrategia de pseudo-ausencias
  PA.dist.min = NULL,     # Distancia mínima para pseudo-ausencias
  PA.dist.max = NULL,     # Distancia máxima para pseudo-ausencias
  PA.sre.quant = NULL,    # Cuantiles para estrategia SRE
  na.rm = TRUE            # Eliminar NA's
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

# Configurar una semilla para reproducibilidad
set.seed(24)

# Preparar los datos (asumiendo que ya tienes el objeto `species_biomod_data`)
# Puedes crear el objeto `species_biomod_data` como lo hicimos previamente si no está definido

# Definir los algoritmos de clasificación binaria que deseas utilizar

# binary_algorithms <- c("GLM", "RF", "GAM", "GBM")

algorithm_rf <- "RF"


myBiomodModelOut <- BIOMOD_Modeling(bm.format = species_biomod_data,
  modeling.id = 'AllModels',
  models = c('RF', 'GLM'),
  CV.strategy = 'random',
  CV.nb.rep = 2,
  CV.perc = 0.8,
  OPT.strategy = 'bigboss',
  metric.eval = c('TSS','ROC'),
  var.import = 3,
  seed.val = 42)

