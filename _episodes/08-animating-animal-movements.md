---
title: "Animating animal movements"
teaching: 30
exercises: 0
questions:
- "What are some of the options for visualising animal movements?"
objectives:
- "Show how to use ggmap to visualise movement trajectories."
- "Show how to use gganimate and ggmap to produce an animation."
keypoints:
- "ggmap can be used to create an interactive map."
- "gganimate can be used to create an animated plot."
---

## Exploring your dataset with an interactive map


~~~
det_file <- file.path('data', 'detections.csv')
rcv_file <- file.path('data', 'deployments.csv')

dets <- read_glatos_detections(det_file)
Rxdeploy <- read_glatos_receivers(rcv_file)


dets_with_stations <- left_join(
  dets %>% rename(
    deploy_long_det = deploy_long,
    deploy_lat_det = deploy_lat
  ), 
  Rxdeploy, by=c("station"))
dets_with_stations <- dets_with_stations %>% 
  filter(detection_timestamp_utc >= deploy_date_time, detection_timestamp_utc <= recover_date_time)


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

dets_with_stations$year <- strftime(dets_with_stations$detection_timestamp_utc, format="%Y")
dets_with_stations$month <- strftime(dets_with_stations$detection_timestamp_utc, format="%Y-%m")

plot_data <- dets_with_stations %>% filter(year>"2012")
~~~
{:.language-r}


## Plot and animate
~~~
p <- 
  ggplot(dets_with_stations) +
  geom_polygon(data = w, aes(x = long, y = lat, group = group), fill = "darkblue") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  #geom_sf(data = area, fill = 'white') +
  geom_point(data=dets_with_stations, aes(deploy_long, deploy_lat, col = animal_id), size = 3) +
  coord_sf(xlim = lon_range, ylim = lat_range) +
  labs(title = '',
       subtitle = 'Date: {format(frame_time, "%d %b %Y")}',
       x = "Longitude", y = "Latitude") +
  theme(panel.background = element_rect(fill = 'lightgreen'))+
  transition_time(as.POSIXct(detection_timestamp_utc, tz= "UTC", format = "%Y-%m-%d %H:%M"))+
  shadow_wake(wake_length = 0.5, alpha = FALSE)
  

pAnim <- animate(p, duration=24, nframes=96, height = 900, width = 900)
#watch it:
pAnim
#save it:
anim_save("pAnim.gif")
~~~
{:.language-r}
