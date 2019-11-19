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
str(dets3)
FishIDsum <- dets3 %>% group_by(animal_id) %>%
  summarise(dets=length(animal_id),stations=length(unique(station)), nodes=length(unique(node)),
            min=min(UTC), max=max(UTC), tracklength=max(UTC)-min(UTC)) %>% as.data.frame()
FishIDsum
~~~
{:.language-r}



## Summarise by station:

To group and summarise our data by station, we first need to find all unique station names and locations:
~~~
head(Rxmeta)
stations <- Rxmeta %>% select(station, lat, lon, depth, sub=sub_detail, hab=hab_detail)
head(stations)
~~~
{:.language-r}

## Summarise detections:
Create a new data product, det_days, that give you the unique dates that an animal was seen by a station. This summary
can be used to calculate a residence index as in Kessel et al. 2017 (https://dx.doi.org/10.1007/s00300-015-1723-y)
~~~
stationsum <- dets3 %>% group_by(station) %>%
  summarise(detections=length(animal_id),
            uniqueID=length(unique(animal_id)), det_days=length(unique(as.character(day)))) %>% as.data.frame()
~~~
{:.language-r}

## Merge with station list:

We can then re-attach station summary information to the list of stations we made earlier.

~~~
stations2 <- merge(stations, stationsum, all.x=TRUE, by="station")
stations2[is.na(stations2)]<-0
stations2[1:10,]
~~~
{:.language-r}

# How many days were the Receivers in the water?:

Residence Indices often must take into account the number of potential observation days. Using our deployment history,
we can calculate the number of days the tag and receiver were deployed. The Receiver Efficiency Index (REI) described in
Ellis et al. 2019 (https://doi.org/10.1016/j.fishres.2018.09.015) is a ratio useful for quantifying the relative importance/value of each receiver in a given array/cloud
deployment, and requires similar input data. We can calculate it this way:

~~~
head(Rxdeploy3)
Rxdeploy3$deploy_time <- Rxdeploy3$recoverUTC-Rxdeploy3$deployUTC
Rxdeploysum <- Rxdeploy3 %>% group_by(station) %>% summarise(deploy_time=sum(deploy_time))
stations2$Rx_deploy_time <- Rxdeploysum$deploy_time[match(stations2$station, Rxdeploysum$station)]
head(stations2)

#Receiver efficiency index from Ellis et al. (2019) Fisheries Research
stations2$REI <- (stations2$uniqueID/length(unique(dets3$Transmitter))) * (stations2$det_days/sum(stations2$det_days)) *
                 (max(stations2$det_days)/stations2$det_days)

stations2$REI[is.na(stations2$REI)]<-0
stations2$REI <- stations2$REI/max(stations2$REI)*100
~~~
{:.language-r}


## Station Summary Table Review

Now we have a station summary dataframe with REI scoring and other summary information inline, from which we can derive some plots.
~~~
stations2[1:20,]
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

Summarise things by station and individual ID, and then plot a map of each animal path.

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
