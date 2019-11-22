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
```

Once the packages are installed, change your working directory in RStudio to `acoustic-workshop` using the files menu, or the `setwd('~/Desktop/acoustic-workshop')`


