# Librerías necesarias
library(ggplot2)
library(dplyr)
library(patchwork) # Para combinar gráficos

# Directorio donde están los archivos
data_dir <- "presence_absence_2vars/"

# Lista de archivos
files <- list(
  "train_crianza.csv", 
  "test_crianza.csv", 
  "train_empollamiento.csv", 
  "test_empollamiento.csv", 
  "train_incubacion.csv", 
  "test_incubacion.csv"
)

# Leer y combinar datasets con etiquetas
datasets <- lapply(files, function(file) {
  file_path <- paste0(data_dir, file)  # Crear la ruta completa
  data <- read.csv(file_path)
  data$type <- ifelse(grepl("train", file), "Entrenamiento", "Prueba") # Etiquetar tipo de conjunto
  data$season <- ifelse(grepl("crianza", file), "Crianza",
                        ifelse(grepl("empollamiento", file), "Empollamiento", "Incubación")) # Etiquetar temporada
  return(data)
})

# Combinar todos los datasets en un solo DataFrame
combined_data <- bind_rows(datasets)

# Filtrar solo presencias
presence_data <- combined_data %>% filter(phoebastria_immutabilis == 1)

# Crear gráficos para cada variable
plot_chlc <- ggplot(presence_data, aes(x = season, y = chlc, fill = type)) +
  geom_boxplot() +
  scale_y_log10() + # Aplicar escala logarítmica
  scale_fill_manual(values = c("Entrenamiento" = "steelblue", "Prueba" = "orange")) +
  labs(title = "Concentración de Clorofila", 
       x = "Temporada Reproductiva", 
       y = "Log(Clorofila) (mg/m³)", 
       fill = "Conjunto") +
  theme_minimal()

plot_sst <- ggplot(presence_data, aes(x = season, y = sst, fill = type)) +
  geom_boxplot() +
  scale_fill_manual(values = c("Entrenamiento" = "steelblue", "Prueba" = "orange")) +
  labs(title = "Temperatura Superficial del Mar", 
       x = "Temporada Reproductiva", 
       y = "SST (°C)", 
       fill = "Conjunto") +
  theme_minimal()

plot_wind_speed <- ggplot(presence_data, aes(x = season, y = wind_speed, fill = type)) +
  geom_boxplot() +
  scale_fill_manual(values = c("Entrenamiento" = "steelblue", "Prueba" = "orange")) +
  labs(title = "Velocidad del Viento",
       x = "Temporada Reproductiva", 
       y = "Velocidad del Viento (m/s)", 
       fill = "Conjunto") +
  theme_minimal()

plot_wind_direction <- ggplot(presence_data, aes(x = season, y = wind_direction, fill = type)) +
  geom_boxplot() +
  scale_fill_manual(values = c("Entrenamiento" = "steelblue", "Prueba" = "orange")) +
  labs(title = "Dirección del Viento",
       x = "Temporada Reproductiva", 
       y = "Dirección del Viento (°)", 
       fill = "Conjunto") +
  theme_minimal()

# Combinar gráficos verticalmente
final_plot <- plot_chlc / plot_sst / plot_wind_speed / plot_wind_direction

# Guardar el gráfico combinado
ggsave("figures/boxplots_variables_ambientales_2vars.png", plot = final_plot, width = 10, height = 16)

# Mostrar el gráfico en pantalla
print(final_plot)
