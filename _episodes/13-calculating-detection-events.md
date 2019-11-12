---
title: "Calculating Detection Events"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

The Events function (based on glatos code) calculates unique detection events based on user defined time window (period)
needs: FishID, datetime, station

~~~
Events(detsf, station="station", period=3600, condense=FALSE) #condense=FALSE returns full data frame with arrive,depart,event info
head(EventData)

Events(detsf, station="station", period=3600, condense=TRUE)  #condense=TRUE returns a summarized data frame
head(EventSum)
~~~
{:.language-r}

Let's look at residency by month and habitat type:

~~~
head(EventData)

EventD2 <- EventData %>% group_by(node, month, event) %>% summarise(res_time=max(ESTEDT)-min(ESTEDT), lat=mean(node_lat),lon=mean(node_lon))
EventD2 <- EventD2 %>% group_by(node, month) %>% summarise(res_time=sum(res_time), lat=mean(lat),lon=mean(lon))
head(EventD2)

EventD2$month <- factor(EventD2$month, levels=c("January","February","March","April","May","June","July","August","September","October","November","December"))
ggmap(FLmap, extent='normal')+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))+
  ylab("Latitude") +
  xlab("Longitude")+
  geom_point(data=EventD2, aes(x=lon,y=lat,size=as.numeric(log(as.numeric(res_time))), col=log(as.numeric((res_time)))))+
  scale_color_continuous(low="yellow", high="red")+
  facet_wrap(~month)
~~~
{:.language-r}

So raw detection data are interesting but hard to interpret:

~~~
ggmap(FLmap, extent='normal')+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))+
  ylab("Latitude") +
  xlab("Longitude")+
  labs(size="log(detections)")+
  geom_path(data=dets3, aes(x=lon,y=lat,col=FishID))+
  geom_point(data=stationFishID, aes(x=lon,y=lat,size=logdets,col=FishID))
~~~
{:language-r}

Convenient to look at this type of data as a network.

Earlier we calculated EventSum for each receiver station, which is convenient for generating a movement (adjacency)
matrix. We'll summarise the data by node instead of station to generate the network:

~~~
#will have to respecify node as station in df:
detsf2 <- detsf
detsf2$station2 <- detsf2$station
detsf2$station <- detsf2$node

Events(detsf2, station="station", period=3600, condense=TRUE)  #condense=TRUE returns a summarized data frame
head(EventSum)
table(as.character(EventSum$location))
~~~
{:.language-r}

Not the slickest way. Might be a bit slow on giant datasets:

~~~
EventSum$from <-""
EventSum$to <-""
for (i in 2:length(EventSum$event)){
  if(EventSum$individual[i]==EventSum$individual[i-1]){EventSum$from[i]=as.character(EventSum$location[i-1])}
  if(EventSum$individual[i]==EventSum$individual[i-1]){EventSum$to[i]=as.character(EventSum$location[i])}
}
head(EventSum)
EventSum2 <- EventSum %>% filter(from!="")
str(EventSum2)

MoveT <- table(EventSum2$from,EventSum2$to)
~~~
{:.language-r}



Set of functions from Jack Finn (UMass Amherst) for network analysis:
~~~
source('MovementFunctions_v2.r')
MoveEdge <- MoveEdgeList(MoveT)
MoveEdge$weight = as.numeric(MoveEdge$weight)
~~~
{:.language-r}

Import the edge list into an igraph object
~~~
library(igraph)
MoveGraph = graph.data.frame(MoveEdge, directed=T)
class(MoveGraph)
~~~
{:.language-r}

Make a default plot of the graph
~~~
plot(MoveGraph)
~~~
{:.language-r}


Inspect the data:

~~~
V(MoveGraph) #prints the list of vertices (stations)
head(E(MoveGraph)) #prints the list of edges (movements)
~~~
{:.language-r}

Number of nodes
~~~
(nv = length(V(MoveGraph)))
~~~
{:.language-r}

Number of possible connections
~~~
nv * nv
~~~
{:.language-r}

Actual number of connections
~~~
(ne = length(E(MoveGraph)[E(MoveGraph)$weight>0]))
~~~
{:.language-r}

Connectance (allowing for self connections)
~~~
ne/(nv*nv) # This graph is 23 % connected
~~~
{:.language-r}

~~~
igraph::degree(MoveGraph) # print the number of edges per vertex
# (i.e., movement types per station)
~~~
{:.language-r}

Make a spatial map of the network:
Need to summarise lat/lons by site

~~~
V(MoveGraph)$Latitude  <- EventSum$mean_latitude[match(V(MoveGraph)$name, EventSum$location)]
V(MoveGraph)$Longitude <- EventSum$mean_lonitude[match(V(MoveGraph)$name, EventSum$location)]
V(MoveGraph)$Station <- as.character(EventSum$location[match(V(MoveGraph)$name, EventSum$location)])
~~~
{:.language-r}

~~~
V(MoveGraph)$Station
V(MoveGraph)$Latitude
~~~
{:.language-r}


Put vertex properties in a data frame

Need to rescale vertex size for the map (this was trial and error)
~~~
V(MoveGraph)$Size =  igraph::degree(MoveGraph) # Put original vertex size into the variable Size
V(MoveGraph)$size = V(MoveGraph)$Size   # We may want to resize it later but not lose OG data
range(V(MoveGraph)$size)
~~~
{:.language-r}

~~~
Vertices = data.frame(Name = V(MoveGraph)$name, lat = V(MoveGraph)$Latitude,
                      lon = V(MoveGraph)$Longitude, size = V(MoveGraph)$Size)
head(Vertices)

ggmap(FLmap, extent='normal') +
  geom_point(data=Vertices, aes(x=lon, y=lat, size=size),alpha=.6, color="yellow")+
  scale_size(range=c(0.1,7)) +
  labs(size="node degree")+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))
~~~
{:.language-r}



To include edges we need # of movements between each site

~~~
head(EventSum)

EventSummove2 <- EventSum %>% group_by(from, to) %>% summarise(count=length(to))
head(EventSummove2)


table(EventSum$location)
EventSummove2$latfrom <- EventSum$mean_latitude[match(EventSummove2$from, EventSum$location)]
EventSummove2$lonfrom <- EventSum$mean_lonitude[match(EventSummove2$from, EventSum$location)]
EventSummove2$latto <- EventSum$mean_latitude[match(EventSummove2$to, EventSum$location)]
EventSummove2$lonto <- EventSum$mean_lonitude[match(EventSummove2$to, EventSum$location)]

EventSummove2.1 <- EventSummove2 %>% filter(from!=to)
head(EventSummove2.1)

#scale values for mapping
range(EventSummove2.1$count) #convert to 0.1 to 3 ish
EventSummove2.1$weight <- log10(EventSummove2.1$count)+0.1
range(EventSummove2.1$weight)

range(Vertices$size) # scale from 0.01 to 7
Vertices$degree <- Vertices$size/2
range(Vertices$degree)
~~~
{:.language-r}

Plot

~~~
ggmap(FLmap, extent='normal') +
  geom_segment(data = EventSummove2.1, aes(x = lonfrom, y = latfrom, xend = lonto, yend = latto, size=weight),
               arrow = arrow(length=unit(0.11,"cm"),type = "closed"), alpha=0.6,col="green")+
  geom_point(data=Vertices, aes(x=lon, y=lat, size=degree),alpha=.6, color="yellow") +
  scale_size_identity()+
  xlab("Longitude")+
  ylab("Latitude")+
  coord_cartesian(xlim=c(-82.4, -80.8), ylim=c(24.4, 25.1))
~~~
{:.language-r}

Community detection algorithm

Greedy algorithm:
~~~
cfg <- cluster_fast_greedy(as.undirected(MoveGraph))
plot(cfg, as.undirected(MoveGraph))


V(MoveGraph)$community <- cfg$membership
V(MoveGraph)$community

community = data.frame(Name = V(MoveGraph)$name, comm = V(MoveGraph)$community)
Vertices$community <- community$comm[match(Vertices$Name, community$Name)]
~~~
{:.language-r}

Plot
~~~
ggmap(FLmap, extent='normal') +
  geom_segment(data = EventSummove2.1, aes(x = lonfrom, y = latfrom, xend = lonto, yend = latto, size=weight), col="yellow",
               arrow = arrow(length=unit(0.11,"cm"),type = "closed"), alpha=0.6)+
  geom_point(data=Vertices, aes(x=lon, y=lat, size=degree,color=as.factor(community)),alpha=.8) + scale_size_identity()+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))
~~~
{:.language-r}

Put ellipses on:
~~~
ggmap(FLmap, extent='normal') +
  geom_segment(data = EventSummove2.1, aes(x = lonfrom, y = latfrom, xend = lonto, yend = latto, size=weight),
               arrow = arrow(length=unit(0.11,"cm"),type = "closed"), alpha=0.6,col="yellow")+
  geom_point(data=Vertices, aes(x=lon, y=lat, size=degree,color=as.factor(community)),alpha=.8) + scale_size_identity()+
  stat_ellipse(data=Vertices, geom="polygon", aes(x=lon, y=lat,color=as.factor(community), fill=as.factor(community)),alpha=.3)+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))+
  theme(legend.position = "none")+
  xlab("Longitude")+ylab("Latitude")
~~~
{:.language-r}


This is really a bad example of a community detection. Largely because the data are very sparse because
We're using a small, altered version of my data. Anyway you may find the code useful
there's a lot to know about network analysis. Check out some of the resources I included with this workshop


