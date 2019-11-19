---
title: Setup
---

## Requirements

### Download the data folder
Create a folder on your desktop called `acoustic-workshop`. Download the 
[data folder zip](https://github.com/ocean-tracking-network/jb-acoustic-telemetry/releases), 
extract it to a folder on your desktop called `acoustic-workshop`. You should now have a folder 
called `data` inside of the `acoustic-workshop` folder.

### R version 3.6.x or better and RStudio

Once RStudio is open, run this install script. It's best to run it line by line instead of all at once in case there are errors. 
<b>Note:</b> When running through the installs, if you encounter a prompt asking you to upgrade packages. Choosing Option `3: None`, works in most situations.
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

Once the packages are installed, change your working directory in RStudio to `acoustic-workshop` using the files menu, or the `setwd('~/Desktop/acoustic-workshop')`


