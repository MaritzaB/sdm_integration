library(biomod2)
library(dplyr)
library(tidyverse)
library(ggplot2)
source("functions/create_biomod_data_object.R")
source("functions/process_raster_data.R")

file.out <- "Phoebastria.Immutabilis/Phoebastria.Immutabilis.incubacion.models.out"

print(file.out)
if (file.exists(file.out)) {
    myBiomodModelOut <- get(load(file.out))
    print({"Modelo cargado exitosamente"})
    print(myBiomodModelOut)
    
}

print("Evaluación del modelo")
myBiomodModelEval <- get_evaluations(myBiomodModelOut)
#myBiomodModelEval
season <- 'incubacion'
out_dir <- paste0("figures/", season, "/")
if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
}

training_boxplot <- bm_PlotEvalBoxplot(
    bm.out = myBiomodModelOut, 
    group.by = c('algo', 'algo'), 
    dataset = 'calibration', 
    do.plot = FALSE)
testing_boxplot <- bm_PlotEvalBoxplot(
    bm.out = myBiomodModelOut,
    group.by = c('algo', 'algo'),
    dataset = 'evaluation',
    do.plot = FALSE)

training_boxplot_gg <- training_boxplot$plot
training_boxplot <- training_boxplot_gg + 
    ggtitle("Evaluación del Modelo - Conjunto de entrenamiento") +
    xlab("Método de clasificación") +
    ylab("Valor de la métrica de evaluación") +
    theme(plot.title = element_text(hjust = 0.5))
training_boxplot_filename <- paste0(out_dir, "boxplot_evaluacion_trainingSet.png")
ggsave(filename = training_boxplot_filename, plot = training_boxplot, width = 8, height = 6)

testing_boxplot_gg <- testing_boxplot$plot
testing_boxplot <- testing_boxplot_gg + 
    ggtitle("Evaluación del Modelo - Conjunto de prueba") +
    xlab("Método de clasificación") +
    ylab("Valor de la métrica de evaluación") +
    theme(plot.title = element_text(hjust = 0.5))
testing_boxplot_filename <- paste0(out_dir, "boxplot_evaluacion_testingSet.png")
ggsave(filename = testing_boxplot_filename, plot = testing_boxplot, width = 8, height = 6)

print("Importancia de variables")
MyBiomodModelVarImp <- get_variables_importance(myBiomodModelOut)
df <- MyBiomodModelVarImp[,3:ncol(MyBiomodModelVarImp)]
avg_var_importance <- df %>%
  group_by(algo, expl.var) %>%
  summarize(mean_importance = mean(var.imp), .groups = 'drop')

plot_var_importance <- ggplot(avg_var_importance, aes(x = reorder(expl.var, mean_importance), y = mean_importance, fill = algo)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  labs(title = "Importancia Promedio de las Variables por Algoritmo",
       x = "Variable",
       y = "Importancia Promedio") +
  theme(plot.title = element_text(hjust = 0.5))
plot_var_importance_filename <- paste0(out_dir, "importancia_variables.png")
ggsave(filename = plot_var_importance_filename, plot = plot_var_importance, width = 10, height = 6)
