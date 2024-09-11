#install.packages("dismo")
#install.packages("terra")
#install.packages("raster")
#install.packages("sp")
#install.packages("geodata")

library(dismo)
library(terra)
library(raster)
library(sf)

# Load the data
data <- read.csv("data/trajectories.csv")
coordinates(data) <- ~longitude+latitude
head(data)

convex_hull <- read.csv("data/convex_hull.csv")
head(convex_hull)


