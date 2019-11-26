---
title: "Additional Interpolation and Plotting with VTrack"
teaching: 30
exercises: 0
questions:
- "How can I use VTrack to further analyse my data?"
objectives:
- "Introduce VTrack and explain what it is for."
- "Properly configure data for use with VTrack."
- "Use VTrack to make plots and detection summaries."
keypoints:
- "VTrack provides robust options for more advanced visualization."
---

[VTrack](https://vinayudyawer.github.io/ATT/docs/ATT_Vignette.html "VTrack Reference") has some cool tools including COA and Brownian bridges.

# Setup data
Needs to be in specific format to load an ATT object, including detection data, tag metadata, and station info. Check out
[the VTrack reference](https://vinayudyawer.github.io/ATT/docs/ATT_Vignette.html) for specific data format requirements. GLATOS is capable of exporting their data to a format readable by VTrack. Conversion of OTN data requires data from the [OTN ERDDAP server](https://members.oceantrack.org/erddap/tabledap/index.html?page=1&itemsPerPage=1000) Data can be found at the following links: [Animals](https://members.oceantrack.org/erddap/tabledap/otn_aat_animals.html), [Receivers](https://members.oceantrack.org/erddap/tabledap/otn_aat_receivers.html), and [Tag Releases](https://members.oceantrack.org/erddap/tabledap/otn_aat_tag_releases.html).

~~~
# files retrived from OTN ERDDAP server
att_ani_path <- file.path('data', 'otn_att_animals.csv') 
att_dpl_path <- file.path('data', 'otn_att_receivers.csv') #
att_tag_path <- file.path('data', 'otn_att_tag_releases.csv')


att_dets <- read_otn_detections(det_file)
att_ani <- read.csv(att_ani_path, as.is = TRUE)
att_dpl <- read.csv(att_dpl_path, as.is = TRUE)
att_tag <- read.csv(att_tag_path, as.is = TRUE)

  
att_bluesharks <- glatos::convert_otn_erddap_to_att(att_dets, att_tag, att_dpl, att_ani)
~~~
{:.language-r}

## VTrack functionality:

### Can be used to make an abacus plot:
~~~
abacusPlot(att_bluesharks)
~~~
{:.language-r}

### Generate detection summary stats:
~~~
detSum<-detectionSummary(att_bluesharks,
                         sub = "%Y-%m")
detSum$Overall
~~~
{:.language-r}


### Calculate dispersal summary info
~~~
dispSum<-dispersalSummary(att_bluesharks)
~~~
{:.language-r}

### Just dispersal data:
~~~
dispSum2 <- dispSum %>% filter(Consecutive.Dispersal >0)
~~~
{:.language-r}


The glatos-based detection events above is an intermediate data summary that is useful for calculating residency at
receivers. This gives you more info on what the fish were doing in between.

In case you're ever interested in exploring the mechanics behind the functions:

~~~
getAnywhere(dispersalSummary)
~~~
{:.language-r}

Calculate Centers of Activity ([Simpfendorfer, C. A., M. R. Heupel, and R. E. Hueter. 2002.](https://doi.org/10.1139/f01-191))

~~~
?COA

COAdata <- COA(att_bluesharks, timestep=3600, split=TRUE)
warnings()
~~~
{:.language-r}


Calculate Minimum Convex Polygons:

~~~
library(rgdal)
proj<-CRS("+proj=longlat +datum=WGS84")
~~~
{:.language-r}

HRSummary() requires calculation of COAs first
Estimate 100% Maximum Convex Polygon (MCP) areas

~~~
mcp_est <- HRSummary(COAdata,
                     projCRS=proj,
                     type="MCP",
                     cont=100,
                     sub = "%Y-%m")

warnings()
mcp_est
~~~
{:.language-r}

Estimate 20%, 50% and 95% Brownian Bridge Kernel Utilisation Distribution ('BBKUD') contour areas and store polygons:

~~~
BBkud_est<-HRSummary(COAdata,
                     projCRS=proj,
                     type="BBKUD",
                     cont=c(20,50,95),
                     storepoly=TRUE)
~~~
{:.language-r}

Plot:

~~~
library(raster)
library(viridis) ## access more color palettes
~~~
{:.language-r}

Select rasters of full KUDs for each individual into a single list:

~~~
fullstack <-
  unlist(BBkud_est$Spatial.Objects)[grep("*_full", names(unlist(BBkud_est$Spatial.Objects)))]

names(fullstack) <-
  unlist(lapply(strsplit(names(fullstack), "[.]"), `[[`, 1))
~~~
{:.language-r}

Lets plot the overall BBKUD for a given individual:

~~~
fulltag <- fullstack$`P91`
values(fulltag)[values(fulltag) > 96] <- NA
plot(fulltag, col = viridis(100), zlim = c(0, 100),
     xlim=c(-85, -80), ylim=c(23.2, 27))
points(station_latitude ~ station_longitude, statinfoBTT, col = 2, cex=0.7)
points(Latitude.coa ~ Longitude.coa,
       data = COAdata$`P3`,
       pch = 20,
       col = 4,
       cex = 0.5)
contour(fulltag, add = TRUE, levels = c(50, 95))
~~~
{:.language-r}
