# Librerías necesarias
library(ggplot2)
library(dplyr)
library(ggcorrplot)

# Directorio donde están los archivos
data_dir <- "presence_absence_4vars/"

# Lista de archivos
files <- list(
  "train_crianza.csv", 
  "test_crianza.csv", 
  "train_empollamiento.csv", 
  "test_empollamiento.csv", 
  "train_incubacion.csv", 
  "test_incubacion.csv"
)

datasets <- lapply(files, function(file) {
  file_path <- paste0(data_dir, file)  # Crear la ruta completa
  data <- read.csv(file_path)
  data$type <- ifelse(grepl("train", file), "Entrenamiento", "Prueba") # Etiquetar tipo de conjunto
  return(data)
})

combined_data <- bind_rows(datasets)
presence_data <- combined_data %>% filter(phoebastria_immutabilis == 1)
environmental_vars <- presence_data %>% select(sst, chlc, wind_speed, wind_direction)

# Calcular la matriz de correlación usando Spearman
corr_matrix <- cor(environmental_vars, method = "spearman", use = "complete.obs")

# Generar el gráfico de correlación
correlation_plot <- ggcorrplot(corr_matrix, 
                               type = "lower", 
                               outline.col = "black", 
                               lab = TRUE, 
                               ggtheme = ggplot2::theme_gray, 
                               colors = c("#6D9EC1", "white", "#E46726")) +
  labs(title = "Matriz de Correlación de Variables Ambientales") +
  theme(plot.title = element_text(hjust = 0.5))

# Crear la carpeta 'figures' si no existe
if (!dir.exists("figures")) {
  dir.create("figures")
}

# Guardar el gráfico en la carpeta 'figures'
output_path <- "figures/correlation_plot.png"
ggsave(output_path, plot = correlation_plot, width = 10, height = 8)

# Confirmación en consola
cat("El gráfico de correlación ha sido guardado en:", output_path, "\n")
