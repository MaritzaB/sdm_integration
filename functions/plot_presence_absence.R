suppressPackageStartupMessages({
  library(terra)
  source("functions/generate_pseudo_absences.R")
})

plot_raster_with_points <- function(raster, df, output_file) {

  png(filename = output_file, width = 800, height = 600)
  
  plot(raster[[1]], main = paste("Distribución de Presencias y Pseudo-Ausencias -", year, month))

  points(df$x[df$species_data == 1], df$y[df$species_data == 1], col = "red", pch = 19, cex = 1.2)
  points(df$x[df$species_data == 0], df$y[df$species_data == 0], col = "black", pch = 4, cex = 0.7)

  legend("topright", legend = c("Presencia", "Ausencia"), col = c("red", "black"), pch = c(19, 4), cex = 0.8)
  dev.off()
  
  cat("Gráfico guardado en:", output_file, "\n")
}


plot_species_distribution <- function(raster_file, df) {
  year <- unique(df$nyear)
  month <- unique(df$nmonth)
  
  output_directory <- "maps"
  if (!dir.exists(output_directory)) {
    dir.create(output_directory, recursive = TRUE)
  }

  output_file <- file.path(output_directory, paste0("presencias_ausencias_", year, "_", month, ".png"))
  plot_raster_with_points(raster_file, df, output_file)
}
