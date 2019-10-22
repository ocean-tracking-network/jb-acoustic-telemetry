---
title: "Generating Presence/Absence Data"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

Start by printing the head of your detections file.

~~~
head(detsf)
~~~
{:.language-r}

When exploring (and analyzing) telemetry data it's important to remember that it comes as presence-only data.
we're typically more interested in presence absence data, and if so it's wise to generate a presence-absence
time series dataset before assigning environmental variables the data. Depending on the timescale of
ecological phenomena you're interested in, you might consider hourly or daily. We'll do daily by receiver node:


We first need a data frame of every day each node had receivers deployed:
~~~
DT <- data.frame(day=seq(from=min(Rxdeploy3$deployUTChour), to=max(Rxdeploy3$recoverUTChour), by="day"))
head(DT)
DT$day <- strftime(DT$day, format="%Y-%m-%d")
DT$day <- as.POSIXct(DT$day, tz="UTC", format="%Y-%m-%d")
str(DT)
~~~
{:.language-r}

# Station deployment info:
~~~
head(Rxdeploy3)
Rxdeploy3$node <- Rxmeta$node[match(Rxdeploy3$station, Rxmeta$station)]
anyNA(Rxdeploy3$node)
~~~
{:.language-r}

# NAs not relevent to this dataset:
~~~
Rxdeploy4 <- Rxdeploy3 %>% filter(!is.na(node))
~~~
{:.language-r}

Combine times with node info:
~~~
DT2 <- merge(DT, Rxdeploy4, all=TRUE)
head(DT2)
~~~
{:.language-r}

Reduce down to just hours between deployment and recovery:
~~~
DT3 <- DT2 %>% filter(day>=deployUTC & day<=recoverUTC)
head(DT3)
rm(DT2)

permPA <- DT3 %>% group_by(node, day) %>% summarise()
ggplot(permPA, aes(x=day, y=node))+geom_point()
~~~
{:.language-r}



Summarise number of individuals present on each day:
~~~
detsSum <- detsf %>% group_by(day, node) %>% summarise(IDcount=length(unique(FishID)))
~~~
{:.language-r}

Assign to detsPA:
~~~
permPA2 <- merge(permPA, detsSum, all.x=TRUE, by=c("day","node"))
~~~
{:.language-r}

Make NAs 0s:
~~~
permPA2$IDcount[is.na(permPA2$IDcount)]<-0
head(permPA2)
~~~
{:.language-r}

We might also be intersted simple presence/absence at the site:
~~~
permPA2$pres <- ifelse(permPA2$IDcount==0, 0, 1)
head(permPA2)
str(permPA2)
table(permPA2$pres)
~~~
{:.language-r}

Zero inflated data! hooray. There's ways to deal with this in various analyses

~~~
ggplot(permPA2, aes(x=day, y=IDcount))+geom_point()+facet_wrap(~node)
~~~
{:.language-r}

At this point you would need to assign all of your environmental data to this dataset as was done above
