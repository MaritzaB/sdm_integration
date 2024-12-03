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
        geom_point(size = 3, position = position_dodge(0.5)) +
        geom_errorbar(aes(ymin = media - std, ymax = media + std),
                      position = position_dodge(0.5), width = 0.25) +
        geom_line(aes(group = variables), position = position_dodge(0.5), linetype = "dashed") +
        scale_y_continuous(limits = y_limits) +  # Fijar los límites del eje y
        labs(title = unique(df$temporada),
             x = "Algoritmo", y = "Media") +
        theme_minimal() +
        theme(legend.position = "bottom")
    })
  
  # Añadir título al gráfico combinado
  combined_plot <- wrap_plots(plots, ncol = 3) +
    plot_annotation(
      title = paste("Análisis Comparativo de", metrica, ": Algoritmos y Variables por Temporada Reproductiva"),
      subtitle = "Media y desviación estándar para cada temporada reproductiva",
      theme = theme(
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, size = 14),
        plot.caption = element_text(hjust = 0.5, size = 9)
      )
    )
  
  # Guardar el gráfico con el título centrado
  ggsave(output_file, plot = combined_plot, width = 12, height = 10, dpi = 500)

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
