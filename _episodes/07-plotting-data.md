---
title: "Summarising and Plotting Data"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

## Summarise by FishID

We can group our data by animal ID, letting us isolate individuals for summary stats, plotting and further analysis.
~~~
str(dets_with_stations)
animal_id_summary <- dets_with_stations %>% group_by(animal_id) %>%
  summarise(dets=length(animal_id),stations=length(unique(station)),
            min=min(detection_timestamp_utc), max=max(detection_timestamp_utc), 
            tracklength=max(detection_timestamp_utc)-min(detection_timestamp_utc)) %>% as.data.frame()
animal_id_summary

~~~
{:.language-r}

## Summarise by station:

To group and summarise our data by station, we first need to find all unique station names and locations:
~~~
head(Rxdeploy)
stations <- Rxdeploy %>% select(station, deploy_date_time, recover_date_time, lat=deploy_lat, lon=deploy_long)
head(stations)
~~~
{:.language-r}

## Summarise detections:
Create a new data product, det_days, that give you the unique dates that an animal was seen by a station. This summary
can be used to calculate a residence index as in [Kessel et al. 2017](https://dx.doi.org/10.1007/s00300-015-1723-y)
~~~
stationsum <- dets_with_stations %>% group_by(station) %>%
  summarise(detections=length(animal_id),
            uniqueID=length(unique(animal_id)), det_days=length(unique(as.Date(detection_timestamp_utc)))) %>% as.data.frame()
~~~
{:.language-r}

## Merge with station list:

We can then re-attach station summary information to the list of stations we made earlier.

~~~
stations2 <- merge(stations, stationsum, all.x=TRUE, by="station")
stations2 <- stations2 %>% filter(detections > 0) # Filter out stations with no detections
stations2[1:10,]
~~~
{:.language-r}


## Plotting data

Abacus plot:
~~~
# summarise by day to make less computationally intensive:
head(dets3)
dets3day <- dets3 %>% group_by(node, day, animal_id) %>% summarise(dets=length(animal_id))
head(dets3day)

# plot
library(ggplot2)
?ggplot()
ggplot(data=dets3day, aes(x=day, y=animal_id, col=node))+geom_point()

# add tagging datetimes:
head(tags)
ggplot(data=dets3day, aes(x=day, y=animal_id, col=node))+geom_point() +
  geom_point(data=tags, aes(x=datetimeESTEDT,y=FishID),col="black") +
  scale_color_brewer()
~~~
{:.language-r}




## Spatial Plots:

Summarise data by station and individual ID, and then plot a map of each animal path.

~~~
# examine by station and FishID:
stationFishID <- dets3 %>% group_by(station, animal_id) %>%
  summarise(lat=mean(lat), lon=mean(lon), dets=length(animal_id), logdets=log(length(animal_id)))

# Peek at the first few rows
head(stationFishID)

perm_map <- ggmap(FLmap, extent='normal')+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))+
  ylab("Latitude") +
  xlab("Longitude")+
  labs(size="log(detections)")+
  geom_path(data=dets3, aes(x=lon,y=lat,col=animal_id))+
  geom_point(data=stationFishID, aes(x=lon,y=lat,size=logdets,col=animal_id))
perm_map

# can simply save plots using output window, or to save high res plots:
tiff("Keys_permit_map.tiff", units="in", width=15, height=8, res=300)
perm_map
dev.off()
~~~
{:.language-r}


## Using maps to track movement patterns

Let's look at maps by FishID to see indiviudal fish movement patterns.

~~~
movMap <- ggmap(FLmap, extent='normal')+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))+
  ylab("Latitude") +
  xlab("Longitude")+
  labs(size="log(detections)")+
  geom_path(data=dets3, aes(x=lon,y=lat,col=animal_id))+
  geom_point(data=stationFishID, aes(x=lon,y=lat,size=logdets,col=animal_id))+
  facet_wrap(~animal_id)
movMap
~~~
{:.language-r}

Add the tagging locations to the plot. In order to generate a movement path from
the tagging location we'll have to bind the tagging locations and detections data sets together on individual ID.
OTN detection extracts have the tag release information directly in the detection extract.

First, set up dataframes with same variables to combine:
~~~
head(dets3)
head(tags)
~~~
{:.language-r}

Then, set up detections for combination
~~~
dets4 <- dets3 %>% select(Receiver, Transmitter, FishID, FLmm, UTC, Tagdate, station, lat, lon)
dets4$tagloc <-"n"
~~~
{:.language-r}

Add tag locations:
~~~
tags2 <- tags
tags2$tagloc <-"y"
tags2$Receiver <-""
tags2$station <-""
tags2$Tagdate <- tags2$datetimeUTC
tags2$UTC <- tags2$datetimeUTC

tags2 <- tags2 %>% select(Receiver,Transmitter, FishID, FLmm, UTC, Tagdate, station, lat, lon, tagloc)
~~~
{:.language-r}

Check the data before you plot:
~~~
head(tags2)
head(dets4)
~~~
{:.language-r}

Combine the dataframes:
~~~
dets5 <- rbind(tags2, dets4)
#arrange by fishID and time
dets5 <- dets5 %>% arrange(FishID, UTC)
head(dets5)
~~~
{:.language-r}

Plot the result:
~~~
ggmap(FLmap, extent='normal')+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))+
  ylab("Latitude") +
  xlab("Longitude")+
  labs(size="log(detections)")+
  geom_point(data=stationFishID, aes(x=lon,y=lat,size=logdets,col=FishID))+
  geom_path(data=dets5, aes(x=lon,y=lat,col=FishID))+
  geom_point(data=tags, aes(x=lon, y=lat),col="yellow")+
  facet_wrap(~FishID)
~~~
{:.language-r}
