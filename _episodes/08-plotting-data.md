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

~~~
str(dets3)
FishIDsum <- dets3 %>% group_by(FishID) %>%
  summarise(dets=length(FishID),stations=length(unique(Receiver)), nodes=length(unique(node)),
            min=min(UTC), max=max(UTC), tracklength=max(UTC)-min(UTC)) %>% as.data.frame()
FishIDsum
~~~
{:.language-r}

Can we get a little preamble around this? -- BD

## Summarise by station:


First we need a list of all stations:
~~~
head(Rxmeta)
stations <- Rxmeta %>% select(station, lat, lon, depth, sub=sub_detail, hab=hab_detail)
head(stations)
~~~
{:.language-r}

Summarise detections:

~~~
stationsum <- dets3 %>% group_by(station) %>%
  summarise(detections=length(FishID),
            uniqueID=length(unique(FishID)), det_days=length(unique(as.character(day)))) %>% as.data.frame()
~~~
{:.language-r}

Merge with station list:

~~~
stations2 <- merge(stations, stationsum, all.x=TRUE, by="station")
stations2[is.na(stations2)]<-0
stations2[1:10,]
~~~
{:.language-r}

Figure out number of days Rxs were in the water:
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

Generate summary table:
~~~
stations2[1:20,]
~~~
{:.language-r}

## Plotting data

Abacus plot:
~~~
#need to summarise by day to make less computationally intensive:
head(dets3)
dets3day <- dets3 %>% group_by(node, day, FishID) %>% summarise(dets=length(FishID))
head(dets3day)

#plot
library(ggplot2)
?ggplot()
ggplot(data=dets3day, aes(x=day, y=FishID, col=node))+geom_point()

#add tagging datetimes:
head(tags)
ggplot(data=dets3day, aes(x=day, y=FishID, col=node))+geom_point()+
  geom_point(data=tags, aes(x=datetimeESTEDT,y=FishID),col="black")
~~~
{:.language-r}

Feel like we could break up the above into 3 discrete blocks? Gotta get a little preamble around it though. --BD


Make some spatial plots:

~~~
#examine by station and FishID:
stationFishID <- dets3 %>% group_by(station, FishID) %>%
  summarise(lat=mean(lat), lon=mean(lon), dets=length(FishID), logdets=log(length(FishID)))
head(stationFishID)

perm_map <- ggmap(FLmap, extent='normal')+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))+
  ylab("Latitude") +
  xlab("Longitude")+
  labs(size="log(detections)")+
  geom_path(data=dets3, aes(x=lon,y=lat,col=FishID))+
  geom_point(data=stationFishID, aes(x=lon,y=lat,size=logdets,col=FishID))
perm_map

# can simply save plots using output window, or to save high res plots:
tiff("Keys_permit_map.tiff", units="in", width=15, height=8, res=300)
perm_map
dev.off()
~~~
{:.language-r}
Ditto the above, let's slice this up. -- BD
