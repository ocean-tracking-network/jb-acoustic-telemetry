---
title: "Data Filtering and Calculating Movement Metrics"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

Assign some relevant environmental variables to the dataset.
Some available information includes diel period, season, lunar phase, temperature:


# Diel period:
~~~
library(maptools)
Keysloc = matrix(c(-81.52208, 24.6565), nrow=1)
KeysSP <- SpatialPoints(Keysloc, proj4string=CRS("+proj=longlat +datum=WGS84"))

dawn = crepuscule(KeysSP, detsf$ESTEDT, solarDep=0, direction="dawn", POSIXct.out=TRUE)
detsf$dawn = dawn$time
dusk = crepuscule(KeysSP, detsf$ESTEDT, solarDep=0, direction="dusk", POSIXct.out=TRUE)
detsf$dusk = dusk$time

detsf$Diel = ifelse(detsf$ESTEDT < detsf$dawn, "Night",
                    ifelse(detsf$ESTEDT < detsf$dusk, "Day","Night"))
head(detsf)
~~~
{:.language-r}

# Season:

~~~
#this is a weird hack of mine. Gotta be a better way
#break down to just month and day
#Bruce, in response to Jake's elocution:
#Maybe we can find that better solution?
detsf$moday <- strftime(detsf$ESTEDT, tz="EST5EDT", format="%m-%d")
#convert back to posix, which will assume it's all in the current year:
detsf$moday <- as.POSIXct(detsf$moday, tz="EST5EDT", format="%m-%d")
#assign season:
detsf$season <- ifelse(detsf$moday<"2019-03-21", "Winter",
                       ifelse(detsf$moday<"2019-06-21", "Spring",
                              ifelse(detsf$moday<"2019-09-21", "Summer",
                                     ifelse(detsf$moday<"2019-12-21", "Fall","Winter"))))
detsf$moday = NULL
head(detsf)
~~~
{:.language-r}

# Lunar phase:

~~~
library(lunar)
detsf$date <- strftime(detsf$ESTEDT, tz="EST5EDT", format="%Y-%m-%d")
detsf$date <- as.Date(detsf$date)

detsf$lunar <- lunar.phase(detsf$date, shift = 0, name = 8)
table(detsf$lunar)
~~~
{:.langauge-r}

# Temperature
I generally assign temperatures to my detection data from temp loggers in my tracking system.
If that's not an option, you can get them from NOAA data:

~~~
library(xtractomatic)
?xtractomatic
#data comes from NOAAs Advanced Very High Resolution Radiometer (AVHRR). Can get temperature,
#chlorophyll (more like borophyll), salinity and more

#look up what datasets are available for sea surface temperature:
SSTsearch <- searchData('datasetname:sst')
# mhsstd1day is up to date and available in my study region at one day resolution

#this takes a long time to do so we'll just do a few data points for fun:
detsfsub <- detsf[5010:5020,]

SST <- xtracto(xpos=detsfsub$lon, ypos=detsfsub$lat, tpos=detsfsub$date, dtype="mhsstd1day", .1, .1)
#it doesn't work for some dates. You could also try longer term (eg 8 day) datasets to fill gaps.
~~~
{:.language-r}
