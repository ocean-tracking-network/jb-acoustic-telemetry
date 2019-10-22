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

There's a few different functions in the 'functions.R' worksheet located in the working directory:
~~~
source("functions.R")
~~~
{:.language-r}

MoveInfo calculates distance, timediff and speed between detections.
needs: lat,lon, datetime (posix object), Transmitter. Data also has to be sorted by Transmitter and datetime
~~~
head(dets3)
dets3$datetime <- dets3$UTC
dets3 <- dets3 %>% arrange(FishID, datetime)

MoveInfo(dets3)
~~~
{:language-r}

## Apply detection filters with DetFilter

DetFilter is a custom function that applies 4 different filters to identify potentially
 false and duplicate detections in the data.
 Four different filters are generated as new columns in the dataset, identifying:
 1. detections that occured before the tag was deployed (Pre_tag_filter) if Tagdate is available in dataset
 2. Duplicate detections that occured within a time period less than the min tag delay (Min_tag_delay_filter)
 3. Duplicate detections that occured within a time period less than the min tag delay at distances longer
    than a specified value (mindist) (Min_tag_delay_distance_filter)
 4. Duplicate detections that occured within a time period less than the min tag delay at
    the same receiver (Min_tag_delay_receiver_filter)
 3. Detections that would indicate movements faster than realistic movement speeds (Speed_time_filter)
 4. Singular detections within a time frame specified (mindelay) (min_lag_filter)

 The data frame must have datetime, Receiver, Transmitter, and
 MoveInfo output metrics: timediff(seconds), dist(meters), speed(m/s)

 User defines tf (maximum time between detections for min_lag_filter), mindelay (min tag delay, default=60),
 mindist (min distance between receivers where fish may move quickly between due to detection ranges. default=2000),
 maxspeed (maximum sustained swimming speed. defaults to 1 m/s)
~~~
library(data.table)
dets6 <- DetFilter(MoveInfodf, tf=7200, mindelay=60, mindist=2000, maxspeed=3)
head(dets6)
~~~
{:.language-r}

Your choice on which to remove. I'll remove them all as a conservative case:

~~~
detsf <- dets6 %>% filter(Min_tag_delay_receiver_filter==1 & Speed_time_filter==1 & min_lag_filter==1 &
                          Pre_tag_filter==1 & Min_tag_delay_filter==1 & Min_tag_delay_distance_filter==1)
head(detsf)

#check out what you're losing:
Filteredout <- dets6 %>% filter(Min_tag_delay_receiver_filter==0 | Speed_time_filter==0 | min_lag_filter==0 |
                                  Pre_tag_filter==0 | Min_tag_delay_filter==0 | Min_tag_delay_distance_filter==0)
~~~
{:.language-r}

Have a quick look at movement distances over time

~~~
#at this point we should probably convert UTC over to local time (EST/EDT)
head(detsf)
detsf$ESTEDT <- strftime(detsf$UTC, tz="EST5EDT", format="%Y-%m-%d %H:%M:%S")
detsf$ESTEDT <- as.POSIXct(detsf$ESTEDT, tz="EST5EDT", format="%Y-%m-%d %H:%M:%S")
~~~
{:language-r}

Create a month variable:

~~~
detsf$month <- strftime(detsf$ESTEDT, tz="EST5EDT", format="%B")
~~~
{:language-r}

Summarise by month:

~~~
Monthdets <- detsf %>% group_by(month) %>% summarise(det=length(ESTEDT), dist=mean(dist)) %>% as.data.frame()
head(Monthdets)
~~~
{:.language-r}

~~~
Monthdets$month <- factor(Monthdets$month, levels=c("January","February","March","April","May","June","July","August","September","October","November","December"))
ggplot(Monthdets, aes(x=month, y=det))+geom_histogram(stat="identity")
ggplot(Monthdets, aes(x=month, y=dist))+geom_histogram(stat="identity")
~~~
{:.language-r}
