---
title: Setup
---

## Requirements

### Download the data folder
Create a folder on your desktop called `acoustic-workshop`. Download the 
[data folder zip](https://github.com/ocean-tracking-network/jb-acoustic-telemetry/releases), 
extract it to a folder on your desktop called `acoustic-workshop`. You should now have a folder 
called `data` inside of the `acoustic-workshop` folder.

### R version: 3.6.x or newer and RStudio

Open RStudio and run this install script. It's best to run it line by line instead of all at once in case there are errors. 
<b>Note:</b> When running through the installs, you may encounter a prompt asking you to upgrade dependent packages. Choosing Option `3: None`, works in most situations and will prevent upgrades of packages you weren't explicitly looking to upgrade.
```r


install.packages("devtools")

# Tidyverse (data cleaning and arrangement)
install.packages('tidyverse')

# Concise way to manipulate large datasets
install.packages('data.table')

# Geospatial Data Manipulation and Vis Packages
install.packages('geosphere')
install.packages('rgdal')
install.packages('raster')
install.packages('sf')
install.packages('sp', dependencies = TRUE)
install.packages('ncdf4', dependencies = TRUE)

# Mapping spatial data
install.packages('mapdata')
install.packages('maptools')
install.packages('leaflet')
install.packages('mapview')
install.packages('ggmap')
install.packages('rnaturalearth')
install.packages('plotly')

# Animating spatial data
install.packages('gganimate')
install.packages('gifski')

# Network analysis
install.packages('igraph')
install.packages('leaflet.minicharts')

# Other misscelaneous packages to help
install.packages('viridis')
install.packages('lunar')
install.packages('httr', dependencies = TRUE)

# XTractomatic - match locations in time and space w/ model data via ERDDAP
devtools::install_github("rmendels/xtractomatic")

# VTrack - Tools for Telemetry Analysis
devtools::install_github("rossdwyer/VTrack")

# GLATOS - acoustic telemetry package that does filtering, vis, array simulation, etc.
install.packages('remotes')
library(remotes)
install_url("https://gitlab.oceantrack.org/GreatLakes/glatos/repository/master/archive.zip",
            build_opts = c("--no-resave-data", "--no-manual"))  

# Sensible Working Directory Manager
install.packages("here")
```

Once the packages are installed, change your working directory in RStudio to `acoustic-workshop` using the files menu, or the `setwd('~/Desktop/acoustic-workshop')`


