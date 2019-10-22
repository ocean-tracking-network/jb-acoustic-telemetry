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

## Interactive map using plotly

Note that plotly seems to have issues with ggmap with projections of data onto the satellite image. Let's just use base land layer:

~~~
head(stations2)

lon_range <- range(stationFishID$lon) + c(-10, 10)
lat_range <- range(stationFishID$lat) + c(-10, 10)

library(mapdata)
w <- map_data("worldHires", ylim = lat_range, xlim = lon_range)

library(plotly)

p <-  ggplot(stations2) +
  geom_polygon(data = w, aes(x = long, y = lat, group = group), fill = "darkgreen") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  #geom_sf(data = area, fill = 'white') +
  geom_point(data=stations2, aes(lon, lat, size=detections, col=REI))+
  scale_color_continuous(low="yellow", high="red")+
  coord_sf(xlim = c(-82.5, -81), ylim = c(24.2, 25.1)) +
  xlab("Longitude")+ ylab("Latitude")+
  theme(panel.background = element_rect(fill = 'lightblue'),
        legend.position = 'none')

ggplotly(p)
~~~
{:.language-r}
Gotta be something we can do to split up the above -- BD

## Animations using gganimate

~~~
library(sf)
library(gganimate)
library(rnaturalearth)
library(gifski)

str(dets3)
dets3$year <- strftime(dets3$UTC, format="%Y")
dets3$month <- strftime(dets3$UTC, format="%Y-%m")

P201819 <- dets3 %>% filter(year>"2017")
~~~
{:.language-r}


Plot and animate
~~~
p <- ggplot(P201819) +
  geom_polygon(data = w, aes(x = long, y = lat, group = group), fill = "darkgreen") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  #geom_sf(data = area, fill = 'white') +
  geom_point(data=P201819, aes(lon, lat, col = FishID), size = 2) +
  coord_sf(xlim = c(-82.5, -81), ylim = c(24.2, 25.1)) +
  labs(title = '',
       subtitle = 'Date: {format(frame_time, "%b %Y")}',
       x = "Longitude", y = "Latitude") +
  theme(panel.background = element_rect(fill = 'white'),
        legend.position = 'none')+
  transition_time(day)+
  shadow_wake(wake_length = 0.5, alpha = FALSE)

pAnim <- animate(p, duration=24, nframes=96)
#watch it:
pAnim
#save it:
anim_save("pAnim.gif")
~~~
{:.language-r}