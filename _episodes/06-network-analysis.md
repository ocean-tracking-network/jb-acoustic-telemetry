---
title: "Network Analysis"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

## Network Analysis
Network Analysis, based in graph theory, provides a means to easily interpret and analyze the linked connections between individual movements and receivers (Griffen et al., 2018). Network analysis in general is being applied to biotelemetry by looking at the relations within animal movements as a social network (Finn et al., 2014).

Pull in the necessary libraries:

~~~
library(dplyr)
library(glatos)
library(plotly)  
~~~
{:.language-r}

We are going to load the sample walleye fish detections from the Great Lakes, filter them, and then compress them.

~~~
det_file <- system.file("extdata", "walleye_detections.csv",
                         package = "glatos")
detections <- read_glatos_detections(det_file)

detections <- glatos::false_detections(detections, tf = 3600)
filtered_detections <- detections %>% filter(passed_filter != FALSE)
detection_events <- glatos::detection_events(filtered_detections, location_col = 'station')  
~~~
{:.language-r}

Below we create 2 data frames. One to create the network edges and the other to create the vertices.

~~~
# create a data frame of directed movements
detection_events %>%
arrange(first_detection) %>% # Arrange in sequential order by time of arrival
group_by(individual) %>% # Group the data  animal
mutate(to = lead(location)) %>% # Create a next location column by using the lead
mutate(to_latitude = lead(mean_latitude)) %>%  # Create a next latitude column by using the lead
mutate(to_longitude = lead(mean_longitude)) %>% # Create a next longitude column by using the lead
group_by(location, to) %>% # Group by unique sets of movements/vertices
summarise(visits = n(),
          latitude = mean(mean_latitude),
          longitude=mean(mean_longitude),
          to_latitude=mean(to_latitude),
          to_longitude=mean(to_longitude),
          res_time_seconds = mean(res_time_sec) # Summarise the data into data frame of moves by counting them and averaging the the rest of the values
         ) %>%
rename(from=location) %>% # Rename the originating station to 'from'
na.omit() -> network_analysis_data # Omit any rows with empty values

# Create a data frame of receiver vertices.
receivers <- network_analysis_data %>%
                group_by(from) %>%
                summarise(
                    latitude = mean(latitude),
                    longitude = mean(longitude),
                    visits = sum(visits),
                    res_time_seconds = mean(res_time_seconds)
                 )
~~~
{:.language-r}

Below we plot out the segments and verticews using plotly.

~~~
Sys.setenv('MAPBOX_TOKEN' = 'your toke here')

network <- network_analysis_data %>%
    plot_mapbox(height=800) %>%
    add_segments(
        x = ~longitude, xend = ~to_longitude,
        y = ~latitude, yend = ~to_latitude,
         size = I(1.5), hoverinfo = "none", color=I(toRGB("#AA3939"))
      ) %>%
      add_markers(
        data=receivers,
        x = ~longitude, y = ~latitude, text = ~paste(from, ":", visits, ' visits & ', res_time_seconds, ' seconds of residence time on average'),
        size = ~res_time_seconds/mean(network_analysis_data$res_time_seconds) + 100, hoverinfo = "text", color=~visits
      ) %>%
      layout(
        title = 'Walleye Salmon Network Plot',
        showlegend = FALSE,
        mapbox = list(zoom = 6,
                       center = list(lat = ~median(latitude),
                                     lon = ~median(longitude)),
                      style='light'
            )
      )  
~~~
{:.language-r}

Show the completed network graph.

~~~
network  library(cowsay)
cowsay::say("Any questions?",by="shark",)
~~~
{:.language-r}

## Assigning station info to detections

First thing we need to do is figure out which station each receiver was at based on it's serial number
documented in Rxdeploy:

~~~
head(Rxdeploy)
~~~
{:.language-r}


We have deployment and recovery datetimes, which need to be posix. Also need to combine the
receiver model and serial number to match into detections:

~~~
#Receiver number:
Rxdeploy$Receiver <- paste(Rxdeploy$INS_MODEL_NO, Rxdeploy$INS_SERIAL_NO, sep="-")
head(Rxdeploy)

#datetimes:
Rxdeploy$deployESTEDT <- as.POSIXct(Rxdeploy$DEPLOY_DATE_TIME....yyyy.mm.ddThh.mm.ss.,
                                    tz="EST5EDT", format="%Y-%m-%dT%H:%M:%S")
Rxdeploy$recoverESTEDT <- as.POSIXct(Rxdeploy$RECOVER_DATE_TIME..yyyy.mm.ddThh.mm.ss.,
                                    tz="EST5EDT", format="%Y-%m-%dT%H:%M:%S")

#convert to UTC:
Rxdeploy$deployUTC <- strftime(Rxdeploy$deployESTEDT, tz="UTC", format="%Y-%m-%d %H:%M:%S")
Rxdeploy$deployUTC <- as.POSIXct(Rxdeploy$deployUTC, tz="UTC", format="%Y-%m-%d %H:%M:%S")
Rxdeploy$recoverUTC <- strftime(Rxdeploy$recoverESTEDT, tz="UTC", format="%Y-%m-%d %H:%M:%S")
Rxdeploy$recoverUTC <- as.POSIXct(Rxdeploy$recoverUTC, tz="UTC", format="%Y-%m-%d %H:%M:%S")

head(Rxdeploy)
~~~
{:.language-r}

Let's clean this dataframe up with dplyr:

~~~
library(dplyr)
Rxdeploy2 <- Rxdeploy %>% select(station=STATION_NO, Receiver, deployUTC, Recovered=RECOVERED..y.n.l., recoverUTC,
                                 Downloaded=DATA_DOWNLOADED..y.n.,lat=DEPLOY_LAT, lon=DEPLOY_LONG, depth=BOTTOM_DEPTH)
head(Rxdeploy2)
~~~
{:.language-r}

Much better. We need to assign the station number to detections based on Receiver number and the time it was there.
This is a complicated data problem...
