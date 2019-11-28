install.packages("devtools")

# Tidyverse (data cleaning and arrangement)
install.packages('ggplot2')
install.packages('ggmap')
install.packages('dplyr')
install.packages('gganimate')

# animated GIF encoder
install.packages("gifski")

# Concise way to manipulate datasets
install.packages("data.table")

# Geospatial Data Manipulation and Vis Packages
install.packages('geosphere')
install.packages('rgdal')
install.packages('raster')
install.packages('mapdata')
install.packages('maptools')
install.packages("sf")
install.packages("rnaturalearth")
install.packages("plotly")
install.packages("sp", dependencies = TRUE)

# Network analysis
install.packages('igraph')

install.packages('viridis')
install.packages('lunar')

install.packages("httr", dependencies = TRUE)
install.packages("ncdf4",dependencies = TRUE)

# XTractomatic - match locations in time and space w/ model data via ERDDAP
devtools::install_github("rmendels/xtractomatic")

# VTrack and ATT - Tools for Telemetry Analysis
devtools::install_github("rossdwyer/VTrack")
devtools::install_github("vinayudyawer/ATT")

# GLATOS - acoustic telemetry package that does filtering, vis, array simulation, etc.
install.packages('remotes')
library(remotes)
install_url("https://gitlab.oceantrack.org/GreatLakes/glatos/repository/master/archive.zip",
            build_opts = c("--no-resave-data", "--no-manual"))

# Sensible Working Directory Manager
install.packages("here")
