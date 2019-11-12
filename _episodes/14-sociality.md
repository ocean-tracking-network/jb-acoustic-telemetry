---
title: "Sociality"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

What about 'sociality'?

~~~
head(detsf)
detsc <- detsf %>% select(station, node, datetime, season,Transmitter, FishID, lat=node_lat, lon=node_lon) %>% arrange(datetime)
MoveInfo(detsc)
detsc <- MoveInfodf
~~~
{:.language-r}

Weird hack to avoid using a for loop, count the number of connections between IDs:
~~~
detsc$nrow <- 1:length(detsc$station)
df <- detsc
df$nrow <- df$nrow+1

detsc$FishID2 <- df$FishID[match(detsc$nrow, df$nrow)]
detsc$station2 <- df$station[match(detsc$nrow, df$nrow)]

detsc$FishID3 <- ifelse(detsc$timediff<600 & detsc$FishID2!=detsc$FishID & detsc$station==detsc$station2,
                          as.character(detsc$FishID2), "") #10 minute delay
head(detsc)

detsc2 <- detsc %>% filter(FishID3!="")
detsc2$FishID <- as.character(detsc2$FishID)
str(detsc2)

Sociality <- table(detsc2$FishID,detsc2$FishID3)
Sociality

SocEdge <- MoveEdgeList(Sociality)
SocEdge$weight = as.numeric(SocEdge$weight)
head(SocEdge)
~~~
{:.language-r}

Import the edge list into an igraph object

~~~
library(igraph)
SocGraph = graph.data.frame(SocEdge, directed=T)
plot(SocGraph)

(nv = length(V(SocGraph)))
nv * nv
(ne = length(E(SocGraph)[E(SocGraph)$weight>0]))
ne/(nv*nv)
~~~

There's a lot better ways to plot this data. Not going into it today

When and where are they being 'social'?

{:.language-r}
SocSpace <- detsc %>% group_by(node, season) %>% summarise(soc_count=length(which(FishID3!="")), lat=mean(lat),lon=mean(lon))
SocSpace$logsoc_count <-log(SocSpace$soc_count+1)
head(SocSpace)

ggmap(FLmap, extent='normal')+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))+
  ylab("Latitude") +
  xlab("Longitude")+
  geom_point(data=SocSpace, aes(x=lon,y=lat, col=logsoc_count,size=logsoc_count))+
  scale_color_continuous(low="yellow", high="red")+
  facet_wrap(~season)
~~~

