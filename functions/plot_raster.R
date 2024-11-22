library(viridis)
source('functions/process_raster_data.R')
library(RColorBrewer)
library(raster)

test_raster <- generate_masked_raster('2014', '01', 4)
log_chlorophyll <- log(test_raster[["chlc"]])

# Especificar el nombre y ruta del archivo de salida
png("maps/env_raster_2014-01.png", width = 4200, height = 3250, res = 400)

pal <- colorRampPalette(brewer.pal(9, "YlGnBu"))(100)
jet.colors <- colorRampPalette(c("blue", "cyan", "yellow", "orange", "red"))
autumn_r <- colorRampPalette(c("yellow", "orange", "red"))(100)


layout(matrix(1:4, ncol = 2, byrow = TRUE), widths = c(1, 1), heights = c(1.5, 1.5))

par(mfrow=c(2,2), mar=c(5,5,2,2), oma=c(2, 2, 2, 2))


# 1. SST - Temperatura del mar
plot(test_raster[["sst"]], 
     main="Temperatura Superficial del Mar (°C)", 
     xlab="Longitud", ylab="Latitud",
     cex.main=1.3,
     cex.lab=1.2,
     col=jet.colors(100))


# 2. Log(Clorofila) - Concentración de clorofila en escala logarítmica
plot(log_chlorophyll, col=viridis(100),
     xlab="Longitud", ylab="Latitud",
     cex.main=1.3,
     cex.lab=1.2,
     main="Concentración de Clorofila (mg/m³)")

wind_speed <- test_raster[["wind_speed"]]
wind_direction <- test_raster[["wind_direction"]]

# 3. Velocidad del viento
plot(wind_speed, 
     main="Velocidad del viento (m/s)", 
     xlab="Longitud", ylab="Latitud",
     cex.main=1.3,
     cex.lab=1.2,
     col=autumn_r)

# 4. Dirección del viento
plot(wind_direction, 
     main="Dirección del viento (°)", 
     xlab="Longitud", ylab="Latitud",
     cex.main=1.3,
     cex.lab=1.2,
     col=rainbow(100))
#mtext("Variables oceanográficas mensuales homogeneizadas a una resolución espacial de 0.0375 grados geográficos \n",
#     outer = TRUE, cex = 1.5)
dev.off()