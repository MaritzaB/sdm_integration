library(ggplot2)
library(RColorBrewer)

# Leer los datos desde un archivo CSV
file_path <- "data/others/count_data.csv"  # Cambia esto por la ruta real de tu archivo
data <- read.csv(file_path)

# Crear un vector con los nombres de los meses presentes en los datos
meses <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Agosto", "Diciembre")

# Crear el gráfico coloreando por mes con la paleta Set2
ggplot(data, aes(x = year_month, y = total_puntos, fill = as.factor(mes))) +
  geom_col(color = "black") +  # Gráfico de barras
  labs(title = "Total de Puntos por Año y Mes", 
       x = "Año-Mes", 
       y = "Total Puntos", 
       fill = "Mes") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +  # Rotar etiquetas del eje X
  scale_fill_brewer(palette = "Set2", labels = meses) +  # Cambiar etiquetas por nombres de meses
  scale_y_continuous(labels = scales::comma, breaks = seq(0, max(data$total_puntos, na.rm = TRUE), by = 20000))  # Ajustar eje Y

# Guardar el gráfico en un archivo
if (!dir.exists("figures")) {
  dir.create("figures")
}

ggsave("figures/total_puntos_coloreado_por_mes.png", width = 12, height = 6)
