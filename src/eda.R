library(dplyr)
library(tidyr)
library(ggplot2)
library(patchwork)  # Para combinar gráficos

# Definir la función
crear_grafico <- function(archivo_4vars, archivo_2vars, metrica = "ROC", output_file) {
  
  # Leer los datos de 4 y 2 variables
  data_4vars <- read.csv(archivo_4vars)
  data_2vars <- read.csv(archivo_2vars)
  
  # Calcular estadísticas para ambos datasets
  stats_4vars <- data_4vars %>%
    group_by(temporada) %>%
    summarise(across(GLM:MAXNET, list(media = mean, std = sd), .names = "{.col}_{.fn}")) %>%
    mutate(variables = "4 Variables")
  
  stats_2vars <- data_2vars %>%
    group_by(temporada) %>%
    summarise(across(GLM:MAXNET, list(media = mean, std = sd), .names = "{.col}_{.fn}")) %>%
    mutate(variables = "2 Variables")
  
  # Combinar estadísticas
  stats_combined <- bind_rows(stats_4vars, stats_2vars)
  
  # Reestructurar datos para graficar
  stats_long <- stats_combined %>%
    pivot_longer(
      cols = -c(temporada, variables), 
      names_to = c("algoritmo", ".value"), 
      names_pattern = "(.*)_(.*)"
    )
  
  # Encontrar los límites comunes del eje y
  y_limits <- range(stats_long$media + stats_long$std, stats_long$media - stats_long$std, na.rm = TRUE)
  
  # Crear gráficos individuales por temporada con la misma escala
  plots <- stats_long %>%
    split(.$temporada) %>%
    lapply(function(df) {
      ggplot(df, aes(x = algoritmo, y = media, color = variables, group = variables)) +
        geom_point(size = 4, position = position_dodge(0.5)) +
        geom_errorbar(aes(ymin = media - std, ymax = media + std),
                      position = position_dodge(0.5), width = 0.25) +
        #geom_text(aes(label = round(std, 2), 
        #              y = media + std + 0.01),  # Ajusta la posición vertical para que las etiquetas no se sobrepongan
        #          position = position_dodge(0.01), size = 3, color = "black", vjust = 0) +
        geom_line(aes(group = variables), position = position_dodge(0.5), linetype = "dashed") +
        scale_color_manual(values = c("4 Variables" = "blue", "2 Variables" = "red")) +
        scale_y_continuous(limits = y_limits) +  # Fijar los límites del eje y
        labs(title = unique(df$temporada),
             x = "Algoritmo", y = "Media") +
        theme_minimal() +
        theme(
          plot.title = element_text(size = 18, face = "bold", hjust = 0.5),  # Ajusta el tamaño del título
          legend.position = "bottom",
          axis.text.x = element_text(size = 13, angle = 45, hjust = 1, vjust = 1),
          axis.text.y = element_text(size = 16),  # Aumenta el tamaño de las etiquetas del eje y
          axis.title.x = element_text(size = 18), # Aumenta el tamaño del título del eje x
          axis.title.y = element_text(size = 18)  # Aumenta el tamaño del título del eje y
        )
    })
  
  # Añadir título al gráfico combinado
  combined_plot <- wrap_plots(plots, ncol = 3) +
    plot_annotation(
      title = paste("Análisis Comparativo de", metrica, "por temporada"),
      subtitle = "Media y desviación estándar de la métrica",
      theme = theme(
        plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 18),
        plot.caption = element_text(hjust = 0.5, size = 16)
      )
    )
  
  # Guardar el gráfico con el título centrado
  ggsave(output_file, plot = combined_plot, width = 12, height = 10, dpi = 800)

}

# Uso de la función
crear_grafico(
  archivo_4vars = "resultados_comparacion/4vars_roc/metric_data_wide_4vars.csv",
  archivo_2vars = "resultados_comparacion/2vars_roc/metric_data_wide_2vars.csv",
  metrica = "ROC",
  output_file = "resultados_comparacion/mean_stddev_roc.png"
)

crear_grafico(
  archivo_4vars = "resultados_comparacion/4vars_tss/metric_data_wide_4vars.csv",
  archivo_2vars = "resultados_comparacion/2vars_tss/metric_data_wide_2vars.csv",
  metrica = "TSS",
  output_file = "resultados_comparacion/mean_stddev_tss.png"
)

crear_grafico(
  archivo_4vars = "resultados_comparacion/4vars_accuracy/metric_data_wide_4vars.csv",
  archivo_2vars = "resultados_comparacion/2vars_accuracy/metric_data_wide_2vars.csv",
  metrica = "ACCURACY",
  output_file = "resultados_comparacion/mean_stddev_acc.png"
)
