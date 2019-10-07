---
title: Setup
---

## Requirements

### R version 3.6.x or better and RStudio

#### R Packages to Install

```r
install.packages('ggplot2')
install.packages('ggmap')
install.packages('dplyr')
install.packages('geosphere')
install.packages('rgdal')
install.packages('raster')
install.packages('mapdata')
install.packages('maptools')
install.packages('geosphere')
install.packages('igraph')
install.packages('viridis')
install.packages("data.table")
install.packages("sf")
install.packages('gganimate')
install.packages("rnaturalearth")
install.packages("beepr")
install.packages("gifski")
install.packages("devtools")
install.packages("plotly")
install.packages('lunar')
install.packages("httr", dependencies = TRUE)
install.packages("ncdf4",dependencies = TRUE)
install.packages("sp", dependencies = TRUE)
install.packages("devtools")
devtools::install_github("rmendels/xtractomatic")
devtools::install_github("rossdwyer/VTrack")
install.packages('remotes')
library(remotes)
install_url("https://gitlab.oceantrack.org/GreatLakes/glatos/repository/master/archive.zip",
            build_opts = c("--no-resave-data", "--no-manual"))  
install.packages("here")

```
