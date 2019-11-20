---
title: "Additional Interpolation and Plotting with VTrack"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

[VTrack](https://vinayudyawer.github.io/ATT/docs/ATT_Vignette.html "VTrack Reference") has some cool tools including COA and Brownian bridges.

# Setup data
Needs to be in specific format to load an ATT object, including detection data, tag metadata, and station info. Check out
[the VTrack reference](https://vinayudyawer.github.io/ATT/docs/ATT_Vignette.html) for specific data format requirements. GLATOS is capable of exporting their data to a format readable by VTrack.


Detections:

~~~
head(detsf)
detsfvtrack <- detsf %>% rename(Latitude=lat, Longitude=lon, 'Station.Name'=station)
detsfvtrack$'Date.and.Time..UTC.' <- detsfvtrack$UTC
detsfvtrack$'Sensor.Value' <- as.integer("")
detsfvtrack$'Sensor.Unit' <- as.factor("")
detsfvtrack$Station.Name <- as.factor(detsfvtrack$Station.Name)
detsfvtrack$Receiver <- as.factor(detsf$station)
head(detsfvtrack)
detsfvtrack <- detsfvtrack %>% select('Date.and.Time..UTC.', Receiver, Transmitter, 'Sensor.Value', 'Sensor.Unit',
                                  'Station.Name', Latitude, Longitude)

head(detsfvtrack)
str(detsfvtrack)
~~~
{:.language-r}


Tag data:
~~~
head(tags2)
tagsvtrack <- tags2 %>% rename(tag_id=FishID, transmitter_id=Transmitter, release_latitude=lat, release_longitude=lon,
                                ReleaseDate=Tagdate, measurement=FLmm)
str(tagsvtrack)
tagsvtrack$tag_id <- as.character(tagsvtrack$tag_id)
tagsvtrack$scientific_name <- "Trachinotus falcatus"
tagsvtrack$common_name <- "permit"
tagsvtrack$tag_project_name <- "BTTFLK"
tagsvtrack$release_id <- tagsvtrack$tag_id
tagsvtrack$tag_status <-"deployed"
tagsvtrack$sex <-"unknown"
~~~
{:.language-r}

Uses the tag expected life for data periods. I elected to just use the periods between tag deployment and the last detection.

~~~
Tagperiod <- detsf %>% group_by(FishID) %>% summarise(start=min(UTC),end=max(UTC)) %>% as.data.frame()
Tagperiod$days <- as.numeric((Tagperiod$end - Tagperiod$start) )
Tagperiod$days <- as.numeric(round(Tagperiod$days,0))


tagsvtrack$tag_expected_life_time_days <- Tagperiod$days[match(tagsvtrack$tag_id, Tagperiod$FishID )]


tagsvtrack <- tagsvtrack %>% select(tag_id, transmitter_id, scientific_name, common_name, tag_project_name,
                              release_id, release_latitude, release_longitude, ReleaseDate, tag_expected_life_time_days,
                              tag_status, sex, measurement)
tagsvtrack$ReleaseDate <- as.POSIXct(tagsvtrack$ReleaseDate, tz="US/Eastern",format="%Y-%m-%d %H:%M:%S")
tagsvtrack$ReleaseDate <- format(tagsvtrack$ReleaseDate, tz="UTC",format="%Y-%m-%d %H:%M:%S")
tagsvtrack$ReleaseDate <- as.POSIXct(tagsvtrack$ReleaseDate, tz="UTC",format="%Y-%m-%d %H:%M:%S")
tagsvtrack$transmitter_id <- as.character(tagsvtrack$transmitter_id)
head(tagsvtrack)
~~~
{:.language-r}

Station info:

~~~
head(Rxdeploy3)
Rxdeployvtrack <- Rxdeploy3 %>% rename(station_name=station, receiver_name=Receiver, deploymentdatetime_timestamp=deployUTC,
                                recoverydatetime_timestamp=recoverUTC, station_latitude=lat, station_longitude=lon)

head(Rxdeployvtrack)
str(Rxdeployvtrack)
Rxdeployvtrack$installation_name <-"BTTFLK"
Rxdeployvtrack$project_name <- "BTTFLK"
Rxdeployvtrack$status <- "deployed"

Rxdeployvtrack <- Rxdeployvtrack %>% select(station_name, receiver_name, installation_name, project_name, deploymentdatetime_timestamp,
                                recoverydatetime_timestamp, station_latitude, station_longitude, status)

str(detsfvtrack)
str(tagsvtrack)
str(Rxdeployvtrack)
~~~
{:.language-r}

Data all ready

~~~
library(VTrack)
ATTdataBTT <- setupData(Tag.Detections = detsfvtrack, Tag.Metadata = tagsvtrack, Station.Information = Rxdeployvtrack , source="VEMCO")
~~~
{:.language-r}

## VTrack functionality:

### Can be used to make an abacus plot:
~~~
abacusPlot(ATTdataBTT)
~~~
{:.language-r}

### Generate detection summary stats:
~~~
detSum<-detectionSummary(ATTdataBTT,
                         sub = "%Y-%m")
detSum$Overall
~~~
{:.language-r}


### Calculate dispersal summary info
~~~
dispSum<-dispersalSummary(ATTdataBTT)
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

COAdata <- COA(ATTdataBTT, timestep=3600, split=TRUE)
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

Estimate 20%, 50% and 95% Brownian Bridge Kernel Utilisation Distribution ('BBKUD') contour areas and store polygons
~~~
BBkud_est<-HRSummary(COAdata,
                     projCRS=proj,
                     type="BBKUD",
                     cont=c(20,50,95),
                     storepoly=TRUE)
~~~
{:.language-r}

Plot
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

Lets plot the overall BBKUD for a given individual
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
