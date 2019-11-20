---
title: "Advanced Plotting"
teaching: 0
exercises: 0
questions:
- "What are some of the options for advanced data visualization?"
objectives:
- "Show how to use Plotly to create an interactive map."
- "Show how to use gganimate to produce an animated plot."
keypoints:
- "Plotly can be used to create an interactive map."
- "gganimate can be used to create an animated plot."
---

## Exploring your dataset with an interactive map


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
p <- ggplot(plot_data) +
  geom_polygon(data = w, aes(x = long, y = lat, group = group), fill = "darkgreen") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  #geom_sf(data = area, fill = 'white') +
  geom_point(data=plot_data, aes(lon, lat, col = FishID), size = 2) +
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
