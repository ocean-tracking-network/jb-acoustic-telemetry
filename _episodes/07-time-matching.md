---
title: "Matching Detections to Times"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

## Assigning DateTimes to Receivers

We'll have to generate a new hourly datetime object and cross assign to detections based on Receiver and hour.

~~~
det_file <- system.file("extdata", "blue_shark_detections.csv",
                         package = "glatos")
head(dets)

dets <- read_otn_detections(det_file)

#remove Station.Name, Latitude, Longitude can't be trusted
dets <- dets %>% select(-Station.Name, -Latitude, -Longitude)

#need to convert datetime to posix:
dets$UTC <- as.POSIXct(dets$detection_timestamp_utc, tz="UTC", format="%Y-%m-%d %H:%M:%S")


# use strftime to do generate an hour object:
dets$hour <- strftime(dets$UTC, tz="UTC", format="%Y-%m-%d %H")
str(dets)
dets$hour <- as.POSIXct(dets$hour, tz="UTC", format="%Y-%m-%d %H")
dets$day <- strftime(dets$UTC, tz="UTC", format="%Y-%m-%d")
dets$day <- as.POSIXct(dets$day, tz="UTC", format="%Y-%m-%d")

head(dets)

depl_file <- system.file("extdata", "hfx_deployments.csv",
                         package = "glatos")
Rxdeploy2 <- glatos::read_otn_deployments(depl_file) 

#det has all Receiver SN (character) and hour (posix). do the same with Rxdeploy2:
head(Rxdeploy2)

Rxdeploy2$deployUTChour <- strftime(Rxdeploy2$deploy_date_time, tz="UTC", format="%Y-%m-%d %H")
Rxdeploy2$deployUTChour <- as.POSIXct(Rxdeploy2$deployUTChour, tz="UTC", format="%Y-%m-%d %H")

Rxdeploy2$recoverUTChour <- strftime(Rxdeploy2$recover_date_time, tz="UTC", format="%Y-%m-%d %H")
Rxdeploy2$recoverUTChour <- as.POSIXct(Rxdeploy2$recoverUTChour, tz="UTC", format="%Y-%m-%d %H")

head(Rxdeploy2)
str(Rxdeploy2)

#Rxdeploy2 has deployUTChour (posix), recoverUTChour (posix) and Receiver (character)
~~~
{:.language-r}



## Matching Detections to Times

Matching times is tricky because we don't have all the study hours in station that are in det. To avoid using
for loops to check through the dates (very slow) we'll generate an hourly time dataset for the station info:

~~~
#reduce Rxdeploy2 down to those that were recovered:
head(Rxdeploy3)
Rxdeploy3 <- Rxdeploy2 %>% filter(downloads > 0)
~~~
{:.language-r}

Make a time variable for whole study period:

~~~
DT <- data.frame(hour=seq(from=min(Rxdeploy3$deployUTChour), to=max(Rxdeploy3$recoverUTChour), by="hour"))
str(DT)
DT[1,]
~~~
{:.language-r}

Then, combine times with station info:

~~~
DT2 <- merge(DT, Rxdeploy3, all=TRUE)
head(DT2)
~~~
{:language-r}

Reduce down to just hours between deployment and recovery:
~~~
DT3 <- DT2 %>% filter(hour>=deployUTC & hour<=recoverUTC)
head(DT3)
rm(DT2) #removes object from R environment
~~~
{:.language-r}

We can now summarise the data:
~~~
DT3sum <- DT3 %>% group_by(Receiver,deployUTChour) %>% summarise(Recoverhour=mean(recoverUTChour), count=length(hour)) %>% ungroup()
DT3sum #notice this is a tibble
~~~
{:.language-r}

Now, join det with DT3 matching SN and hour

~~~
head(dets)
dets2 <- merge(dets, DT3, all.x=TRUE,by=c("hour","Receiver"))
head(dets2)
~~~
{:.language-r}

Are there any detections occuring oustide of deployment periods? We can check.

~~~
anyNA(dets2$station)
~~~
{:language-r}

Chances are the first time there will be, which could just be from being around transmitters or tx receivers outside the water.
Check them out to see if there's issues:
~~~
issues <- dets2 %>% filter(is.na(dets2$station))
~~~
{:.language-r}

Remove NAs in station (ie detections that theortically occured outside of deployment periods). Also remove some excessive deployment info:
~~~
dets2 <- dets2 %>% filter(!is.na(station)) %>% select(-X, -Recovered, -Downloaded, -Date.and.Time..UTC.,-Transmitter.Name,
                          -Transmitter.Serial,-recoverUTC, -deployUTChour, -recoverUTChour,
                          -deployUTC, -recoverUTC, -Recovered)
head(dets2)


#assign some more station metadata:
head(Rxmeta)

dets3 <- merge(dets2, Rxmeta, all.x=TRUE, by=c("station"))
head(dets3)
dets3 <- dets3 %>% select(-X,-lat.y, -lon.y, -depth.y, lat=lat.x, lon=lon.x, depth=depth.x)
head(dets3)
~~~
{:.language-r}
