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
3. Tag metadata

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
abacusPlot(ATTdata, det.col = "red", facet = T, new.window = F)
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

### Calculate detection metrics

The `detectionSummary()` function calculates detection metrics using the ATTdata object. This function calculates detection metrics for the full tag period and metrics for subsets during the full tag period. The output is a list object with two tibbles with detection metrics.

~~~
# Lets calculate overall detection summaries, and weekly subsets
detSum <- detectionSummary(ATTdata, sub = "%Y-%W")

detSum

# Overall metrics
detSum$Overall

# Weeky metrics
detSum$Subsetted
~~~
{:.language-r}

We can visualise these metrics across individuals and time using `ggplot2`

~~~
detSum$Subset %>% 
  mutate(Date = as.Date(paste(subset, "01", sep = "-"), "%Y-%W-%w")) %>% 
  ggplot(aes(x = Date, y = Number.of.Detections, colour = factor(Tag.ID))) +
  geom_line() + geom_point() +
  labs(title = "Number of Detections over time", x = "Date", y = "Number of Detections", colour = "Tag ID") +
  theme_linedraw()
  
~~~
{:.language-r} 


### Calculate dispersal metrics

The `dispersalSummary()` outputs a tibble data frame object with step distances and step bearings calculated for each detection. The number of rows will be equal to the raw detection data, therefore it may take longer to process dispersal metrics for a large number of animals or for large datasets.

~~~
dispSum <- dispersalSummary(ATTdata)

dispSum

dispSum %>%
  mutate(Date = date(Date.Time),
         Tag.ID = factor(Tag.ID)) %>% 
  group_by(Date, Tag.ID) %>% 
  summarise(Max.Disp.km = max(Consecutive.Dispersal)) %>%
  ggplot(aes(x = Max.Disp.km, y=..scaled..,  fill = Tag.ID, color = Tag.ID)) +
  geom_density(alpha=0.1) +
  geom_rug(sides = "t", aes(y = Max.Disp.km, color = Tag.ID)) +
  ylim(0,1) +
  labs(x = "Maximum distance traveled per day (km)",
       y = "Relative frequency of daily movements",
       fill = "Tag ID", color = "Tag ID") +
  theme_linedraw()
~~~
{:.language-r}


The glatos-based detection events above is an intermediate data summary that is useful for calculating residency at receivers. This gives you more info on what the fish were doing in between.


### Estimating short-term centers of activity (COA) 

A primary use of telemetry data is to understand where animals go and estimate how much space they use. Passive acoustic telemetry, compared to other forms of telemetry (e.g. satellite telemetry, active tracking), are inherently spatio-temporally biased depending on where we deploy our recievers and how often animals come close to recievers. Using raw detection data can produce heavily biased measures of home ranges.

Estimating short-term centers of activity (COA) as a first step can help account for some of the spatio-temporal biases when calculating home range metrics. COAs are estimated by calculating mean positions of a tagged animal within set temporal bins. These positions do not account for the varying listening ranges between recievers within an array, therefore detection probability needs to be considered using other techniques (e.g. kernel distribution smoothing parameter). This technique of calculating short-term centers of activity is based on this [study](https://doi.org/10.1139/f01-191)).

~~~
# First lets quickly map our receiver array
library(sf)
library(mapview)

base <-
  ATTdata$Station.Information %>% 
  st_as_sf(coords=c("Station.Longitude", "Station.Latitude"), crs = 4326) %>% 
  mapview(alpha.regions = 0, color = "grey", cex = 3, legend = F, homebutton = F, layer.name = "Receiver Stations")

base

## Now lets use the COA() function to calculate hourly centers of activity
COAdata <- 
    COA(ATTdata, 
        timestep = 60) ## timestep used to estimate centers of activity (in minutes)

COAdata


## Now lets add our centers of activity for each individual on the map
COAmap <- 
  base + 
  COAdata %>% 
  st_as_sf(coords = c("Longitude.coa", "Latitude.coa"), crs = 4326) %>% 
  mapview(zcol = "Tag.ID", burst = T, alpha = 0, cex = 3, legend = F)

COAmap

~~~
{:.language-r}


Once COA are estimated we can calculate activity space metrics:

Lets calculate Minimum Convex Polygons

We first need to define the projected coordinate reference system to convert lat/lon coordinates to meters. This will help estimate activity space in the unit that is most useful. Projected coordinate systems should signify distance in meters so the output area values are in sq meters.

~~~
library(sp)
# here epsg:3174 refers to the NAD83/Great Lakes Albers projection
# https://epsg.io/3174-1725 

proj<-CRS("+init=epsg:3174")

~~~
{:.language-r}

HRSummary() requires calculation of COAs first
Estimate 100% Maximum Convex Polygon (MCP) areas

~~~
mcp_est <- HRSummary(COAdata,
                     projCRS = proj,
                     type = "MCP",
                     cont = 100,
                     sub = "%Y-%W")

mcp_est

## Lets have a look at how 100% MCP area changes over the tagging period
mcp_est$Subset %>% 
  mutate(Date = as.Date(paste(subset, "01", sep = "-"), "%Y-%W-%w")) %>% 
  ggplot(aes(x = Date, y = MCP.100/1e6, colour = factor(Tag.ID))) +
  geom_line() + geom_point() +
  labs(x = "Date", y = "Area of MCP (km2)", colour = "Tag ID") +
  theme_linedraw()

~~~
{:.language-r}

Other types of activity space metrics can also be calculated (e.g. fixed KUD using `type = "fKUD"` and Brownian Bridge KUD using `type = "BBKUD"`. Cumulative activity space metrics across temporal subsets can also be calculated using the `cumulative = TRUE` argument.

### Storing spatial data associated with activity space metrics

MCP polygons and probability distributions associated with fKUD and BBKUDs can be stored when `storepoly = TRUE`. This outputs a list object with the two components, `$Overall`: a tibble data frame with activity space metrics for the full period of the tag and `$Subsetted`: a tibble data frame with activity space metrics for weekly or monthly temporal subsets depending on the sub argument, but also includes an additional `$Spatial.Objects` list that stores polygons (if calculating MCPs) or probability distribution raster (if calculating fKUD or BBKUD) for full tag life and temporal subsets.

~~~
## Lets estimate 20%, 50% and 95% Brownian Bridge Kernel Utilisation Distribution ('BBKUD') contour areas and store polygons
BBkud_est <- HRSummary(COAdata,
                     projCRS = proj,
                     h = 200,
                     type = "BBKUD",
                     cont = c(20,50,95),
                     storepoly = TRUE,
                     sub = "%Y-%W")
                     
summary(BBkud_est)

# Overall Brownian bridge UD estimates for full tagging period
BBkud_est$Overall

# Weekly Brownian bridge UD estimates for the three tagged walleye
BBkud_est$Subsetted

~~~
{:.language-r}

## Map activity space

Now lets map the Utilisation Distributions we just estimated

~~~
# First lets select rasters of full KUDs for each individual into a single list:
fullstack <-
  unlist(BBkud_est$Spatial.Objects)[grep("*_full", names(unlist(BBkud_est$Spatial.Objects)))]

names(fullstack) <-
  unlist(lapply(strsplit(names(fullstack), "[.]"), `[[`, 1))
~~~
{:.language-r}

You can have a quick look at each raster by plotting them seperately

~~~
library(raster)

## Lets plot the overall BBKUD for Tag.ID `153`
fulltag <- fullstack$`153`
values(fulltag)[values(fulltag) > 95] <- NA

## Raster plot
plot(fulltag, zlim = c(0, 100))

## Mapview plot
base + 
  mapview(fulltag)

~~~
{:.language-r}

Now lets plot all of them together

~~~
library(leaflet)

## Full KUD for all tagged animals
fullmap <- COAmap@map

for (i in 1:length(fullstack)) {
  tempras<-disaggregate(fullstack[[i]], fact=3, method='bilinear')
  values(tempras)[values(tempras) >95] <-NA
  fullmap <- 
    fullmap %>% 
    addRasterImage(tempras, opacity = 0.7, group = names(fullstack)[i])
}

fullmap <- 
  fullmap %>%
  addLayersControl(
    baseGroups = names(fullstack),
    overlayGroups = "Receiver Stations",
    options = layersControlOptions(collapsed = FALSE)
  )

fullmap

~~~
{:.language-r}


To learn more information and features of the VTrack package check out the rest of [this vignette](https://vinayudyawer.github.io/ATT/docs/ATT_Vignette.html#interactive_maps_with_leaflet).







