---
title: "Advanced Plotting"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

## Exploring your dataset with an interactive map


~~~
head(stations2)

# Add REI to stations2
rei <- REI(dets_with_stations, Rxdeploy)
stations2 <- left_join(stations2, rei) %>% select(-latitude, -longitude)
stations2 <- stations2 %>% rename(REI=rei)

head(stations2)

lon_range <- range(stationFishID$lon) + c(-10, 10)
lat_range <- range(stationFishID$lat) + c(-10, 10)

library(mapdata)
w <- map_data("worldHires", ylim = lat_range, xlim = lon_range)

# new range to pass to plot for Nova Scotia region
lon_range <- range(stationFishID$lon) + c(-.5, .5)
lat_range <- range(stationFishID$lat) + c(-.5, .5)

library(plotly)

p <-  ggplot(stations2) +
  geom_polygon(data = w, aes(x = long, y = lat, group = group), fill = "darkgreen") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  #geom_sf(data = area, fill = 'white') +
  geom_point(data=stations2, aes(lon, lat, size=detections, col=REI))+
  scale_color_continuous(low="yellow", high="red")+
  coord_sf(xlim = lat_range, ylim = lon_range) +
  xlab("Longitude")+ ylab("Latitude")+
  theme(panel.background = element_rect(fill = 'lightblue'),
        legend.position = 'none')

ggplotly(p)
~~~
{:.language-r}


## Animations using gganimate

We're going to animate individual animal paths, using the gganimate package
First, subset the data (here as an example, filtering using a time-range to get everything after 2017).

~~~
library(sf)
library(gganimate)
library(rnaturalearth)
library(gifski)

str(dets3)
dets3$year <- strftime(dets3$UTC, format="%Y")
dets3$month <- strftime(dets3$UTC, format="%Y-%m")

plot_data <- dets3 %>% filter(year>"2017")
~~~
{:.language-r}


## Plot and animate
~~~
p <- ggplot(dets3) +
  geom_polygon(data = w, aes(x = long, y = lat, group = group), fill = "darkgreen") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  #geom_sf(data = area, fill = 'white') +
  geom_point(data=dets3, aes(lon.x, lat.x, col = catalognumber), size = 3) +
  coord_sf(xlim = lon_range, ylim = lat_range) +
  labs(title = '',
       subtitle = 'Date: {format(frame_time, "%d %b %Y")}',
       x = "Longitude", y = "Latitude") +
  theme(panel.background = element_rect(fill = 'white'))+
  transition_time(as.POSIXct(datecollected, tz= "UTC", format = "%Y-%m-%d %H:%M"))+
  shadow_wake(wake_length = 0.5, alpha = FALSE)
  

pAnim <- animate(p, duration=24, nframes=96, height = 900, width = 900)
#watch it:
pAnim
#save it:
anim_save("pAnim.gif")
~~~
{:.language-r}
