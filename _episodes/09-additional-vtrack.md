---
title: "Additional Interpolation and Plotting with VTrack"
teaching: 0
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

[`VTrack`](https://vinayudyawer.github.io/ATT/docs/ATT_Vignette.html "VTrack Reference") has some cool tools including COA and estimating activity spaces from passive telemetry data. This package has a suite of functions that help users follow a workflow to efficiently setup, analyse and visualise telemetry data. For more details on the workflow check out [this vignette](https://vinayudyawer.github.io/ATT/docs/ATT_Vignette.html).

# Setup data

The primary object `VTrack` uses is called an ATT object. This object houses the three core datasets required to analyse telemetry data:

1. Detections
2. Receiver deployment metadata
3. Receiver metadata

Apart from these datasets, the ATT object also stores information on the Geographic Coordinate Reference System for that dataset. GLATOS is capable of exporting OTN data to a format readable by VTrack. Conversion of OTN data requires data from the [OTN ERDDAP server](https://members.oceantrack.org/erddap/tabledap/index.html?page=1&itemsPerPage=1000) Data can be found at the following links: [Animals](https://members.oceantrack.org/erddap/tabledap/otn_aat_animals.html), [Receivers](https://members.oceantrack.org/erddap/tabledap/otn_aat_receivers.html), and [Tag Releases](https://members.oceantrack.org/erddap/tabledap/otn_aat_tag_releases.html).

Lets load some data from the `glatos` package, remove false detections and set it up to use in `VTrack`

~~~
library(tidyverse)
library(lubridate)
library(glatos)
library(VTrack)

## Load detection and reciever datasets from glatos package
wal_det_file <- system.file("extdata", "walleye_detections.csv", package = "glatos")
walleye_detections <- read_glatos_detections(wal_det_file)

rec_file <- system.file("extdata", "sample_receivers.csv",  package = "glatos")
rcv <- read_glatos_receivers(rec_file)

# find and remove false detections
filtered_detections <-
  walleye_detections %>% 
  false_detections(tf = 3600) %>% 
  filter(passed_filter != FALSE)

# Now we can convert the GLATOS filtered data into a ATT object to be used in VTrack
ATTdata <- glatos::convert_glatos_to_att(walleye_detections, rcv)

attr(ATTdata, "CRS") <- sp::CRS("+init=epsg:4326")

ATTdata
~~~
{:.language-r}

## VTrack functionality:

### Visualise detection patterns
~~~
# Abacus plot by tag ID
abacusPlot(ATTdata, det.col = "red")

# Abacus plot by station
abacusPlot(ATTdata, det.col = "red", facet = T)
~~~
{:.language-r}

We can use the `ggplot2` library to make more informative abacus plots

~~~
# Daily detection patterns
abacus_data <- 
  ATTdata$Tag.Detections %>% 
  left_join(ATTdata$Tag.Metadata,  by = "Transmitter") %>% 
  mutate(date = date(Date.Time)) %>% 
  group_by(Tag.ID, date, Sci.Name) %>% 
  summarise(Num.Det = n())

abacus_data %>% 
  ggplot(aes(x = date, y = factor(Tag.ID), size = Num.Det, color = Sci.Name)) +
  geom_point() +
  theme_linedraw() +
  labs(title = "Daily detection plot", x = "Date", y = "Tag ID", color = "Species", size = "Number of\ndetections")
~~~
{:.language-r}

### Generate detection summary stats:

The `detectionSummary()` function calculates detection metrics using the ATTdata object. This function calculates detection metrics for the full tag period and metrics for subsets during the full tag period. The output is a list object with two tibbles with detection metrics.

~~~
# Lets calculate overall detection summaries, and monthly subsets
detSum <- detectionSummary(ATTdata, sub = "%Y-%m")

detSum

# Overall metrics
detSum$Overall

# Mothly metrics
detSum$Subsetted
~~~
{:.language-r}

We can visualise these metrics across individuals and time using `ggplot2`

~~~
detSum$Subset %>% 
  mutate(Date.Time = lubridate::ymd(paste(subset, "01", sep = "-"))) %>% 
  ggplot(aes(x = Date.Time, y = Detection.Index, colour = factor(Tag.ID))) +
  geom_line() + geom_point() +
  labs(title = "Detection Index over time", x = "Date", y = "Detection Index", colour = "Tag ID") +
  theme_linedraw()
  
~~~
{:.language-r} 


### Calculate dispersal summary info
~~~
dispSum <- dispersalSummary(ATTdata)

dispSum

dispSum %>%
  mutate(Date = date(Date.Time),
         Tag.ID = factor(Tag.ID)) %>% 
  group_by(Date, Tag.ID) %>% 
  summarise(Max.Disp.km = max(Consecutive.Dispersal)) %>%
  ggplot(aes(x = Max.Disp.km, y=..scaled..,  fill=Tag.ID, color=Tag.ID)) +
  geom_density(alpha=0.1) +
  geom_rug(sides = "t", aes(y = Max.Disp.km, color = Tag.ID)) +
  ylim(0,1) +
  labs(x = "Maximum distance traveled per day (km)",
       y = "Relative frequency of daily movements",
       fill = "Tag ID", color = "Tag ID") +
  theme_linedraw() %+replace%
  theme(legend.position = "top")
~~~
{:.language-r}


The glatos-based detection events above is an intermediate data summary that is useful for calculating residency at receivers. This gives you more info on what the fish were doing in between.

In case you're ever interested in exploring the mechanics behind the functions:

~~~
getAnywhere(dispersalSummary)
~~~
{:.language-r}

Calculate Centers of Activity ([Simpfendorfer, C. A., M. R. Heupel, and R. E. Hueter. 2002.](https://doi.org/10.1139/f01-191))

~~~
?COA

COAdata <- COA(ATTdata, timestep=3600, split = T)

COAdata


~~~
{:.language-r}


Calculate Minimum Convex Polygons:

~~~
library(sp)
proj <- CRS("+proj=longlat +datum=WGS84")
~~~
{:.language-r}

HRSummary() requires calculation of COAs first
Estimate 100% Maximum Convex Polygon (MCP) areas

~~~
mcp_est <- HRSummary(COAdata,
                     projCRS = proj,
                     type = "MCP",
                     cont = 100,
                     sub = "%Y-%m")

mcp_est
~~~
{:.language-r}

Estimate 20%, 50% and 95% Brownian Bridge Kernel Utilisation Distribution ('BBKUD') contour areas and store polygons:

~~~
BBkud_est <- HRSummary(COAdata,
                     projCRS = proj,
                     type = "BBKUD",
                     cont = c(20,50,95),
                     storepoly = TRUE)
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
library(leaflet)

## Full KUD for all tagged animals
fullmap <- leaflet() %>%
  addProviderTiles(providers$Esri.WorldImagery)

for (i in 1:length(fullstack)) {
  tempras<-disaggregate(fullstack[[i]], fact=3, method='bilinear')
  values(tempras)[values(tempras) >95] <-NA
  fullmap <- 
    fullmap %>% 
    addRasterImage(tempras, opacity = 0.5, group = names(fullstack)[i])
}

coa.detections<-
  do.call(rbind, COAdata) %>%
  filter(Tag.ID %in% names(fullstack))

fullmap <- 
  fullmap %>%
  addCircleMarkers(lng = coa.detections$Longitude.coa, lat = coa.detections$Latitude.coa,
                   color = "red", radius = 1, weight=1, group = coa.detections$Tag.ID) %>%
  addCircleMarkers(lng = statinfo$station_longitude, lat = statinfo$station_latitude,
                   fill = F, color = "white", radius = 4, weight = 2, group = "Receiver Stations") %>%
  addMeasure(position = "bottomleft",
             primaryLengthUnit = "meters",
             primaryAreaUnit = "sqmeters") %>%
  addLayersControl(
    baseGroups = coa.detections$Tag.ID,
    overlayGroups = "Receiver Stations",
    options = layersControlOptions(collapsed = FALSE)
  )

fullmap

~~~
{:.language-r}
