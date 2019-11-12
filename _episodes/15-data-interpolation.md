---
title: "Data Interpolation"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

~~~
library(glatos)
?glatos
~~~
{:.language-r}

Lots of valuable functions here, just need to make sure you have the correct variable names

~~~
head(detsf)
str(detsf)
detsf$animal_id <- as.character(detsf$FishID)
detsf$detection_timestamp_utc <- detsf$UTC
detsf$deploy_long <- detsf$lon
detsf$deploy_lat <- detsf$lat
table(detsf$animal_id)


head(detsf)
detsf$year <- strftime(detsf$UTC, format="%Y")

detsf20182019 <- detsf %>% filter(year=="2018"|year=="2019")
Ppath <- interpolate_path(detsf20182019)
head(Ppath)

ggmap(FLmap, extent='normal')+
  coord_cartesian(xlim=c(-82.6, -80.5), ylim=c(24.2, 25.4))+
  ylab("Latitude") +
  xlab("Longitude")+
  geom_point(data=Ppath, aes(x=longitude,y=latitude, col=animal_id))
~~~
{:.language-r}


Can also integrate barriers or interpolate at hourly level. see ?interpolate_path()

~~~
head(Ppath)
~~~
{:.language-r}

Animate paths:
~~~
library(gganimate)
p <- ggplot(Ppath) +
  geom_polygon(data = w, aes(x = long, y = lat, group = group), fill = "darkgreen") +
  theme_bw() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())+
  #geom_sf(data = area, fill = 'white') +
  geom_point(data=Ppath, aes(longitude, latitude, col = animal_id), size = 2) +
  coord_sf(xlim = c(-82.5, -81), ylim = c(24.2, 25.1)) +
  labs(title = '',
       subtitle = 'Date: {format(frame_time, "%b %Y")}',
       x = "Longitude", y = "Latitude") +
  theme(panel.background = element_rect(fill = 'white'),
        legend.position = 'none')+
  transition_time(bin_timestamp)+
  shadow_wake(wake_length = 0.2)

pAnim <- animate(p, duration=24, nframes=96)
~~~
{:.language-r}

Watch it:
~~~
pAnim
~~~
{:.language-r}

Will look better if you calculate hourly movement paths and make more frames.
