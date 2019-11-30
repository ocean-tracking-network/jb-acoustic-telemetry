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

## Setup your data and explore it with a quick interactive map

~~~
library(glatos)
library(sf)
library(mapview)
library(plotly)

detection_events <- 
  read_glatos_detections("data/detections.csv") %>% 
  false_detections(tf = 3600) %>% 
  filter(passed_filter != FALSE) %>% 
  detection_events(location_col = 'station')

receivers <-
  read_glatos_receivers("data/deployments.csv")

## Combine detection and reciever datasets into a single combined data frame
combined_data <- 
  detection_events %>% 
  left_join(receivers, by = c("location" = "station")) %>% 
  filter(first_detection >= deploy_date_time, first_detection <= recover_date_time)

## Plot your combined dataset 
combined_data %>% 
  group_by(animal_id, location, deploy_lat, deploy_long) %>% 
  summarise(Num.Det = n()) %>% 
  st_as_sf(coords = c("deploy_long", "deploy_lat"), crs = 4326) %>% 
  mapview(zcol = "animal_id", cex = "Num.Det", burst = T, legend = F)
  
~~~
{:.language-r}


## Animations using ggmap and gganimate

We're going to animate individual animal paths, using the gganimate package

~~~
library(gganimate)
library(ggmap)

plot_data <-
  combined_data %>% 
  mutate(timestep = round_date(first_detection, unit = "1 days")) %>% 
  group_by(timestep, animal_id) %>% 
  summarise(lon = mean(deploy_long),
            lat = mean(deploy_lat))
  
## Lets setup the base map
base <- 
  get_stamenmap(
    bbox = c(left = min(plot_data$lon),
             bottom = min(plot_data$lat), 
             right = max(plot_data$lon), 
             top = max(plot_data$lat)),
    maptype = "toner-lite",
    crop = F, 
    zoom = 8)

## Plot a static map with movement patterns
walleye.plot <-
  ggmap(base) +
  geom_point(data = plot_data, aes(x = lon, y = lat, group = animal_id, color = animal_id), size = 2) +
  geom_path(data = plot_data, aes(x = lon, y = lat, group = animal_id, color = animal_id)) +
  labs(title = "Walleye animation",
       x = "Longitude", y = "Latitude", color = "Tag ID")

walleye.plot

## Interact with ggmap
ggplotly(walleye.plot)

## Create an animation using the map
walleye.animation <-
  walleye.plot +
  labs(subtitle = 'Date: {format(frame_along, "%d %b %Y")}') +
  transition_reveal(timestep) +
  shadow_mark(past = T, future = F)

# Watch it:
walleye.animation

# Save it:
anim_save(walleye.animation, filename = "walleye_animation.gif")

~~~
{:.language-r}
