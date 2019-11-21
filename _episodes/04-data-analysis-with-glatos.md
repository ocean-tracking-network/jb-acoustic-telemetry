---
title: "Data Analysis Using GLATOS"
teaching: 0
exercises: 0
questions:
- "How does the GLATOS package facilitate data analysis?"
- "How does the GLATOS package facilitate data visualization?"
objectives:
- "Demonstrate how to clean and filter raw data with the GLATOS package."
- "Show how summarise() can be used to group data."
- "Demonstrate how grouped data can be plotted."
- "Demonstrate how grouped data can be plotted on a map."
keypoints:
- "First key point. Brief Answer to questions. (Leaving this for Naomi since I'm not sure I can put in the right answerd -- BD20191121)"
---

## Data Analysis Using GLATOS
[Data analysis](https://en.wikipedia.org/wiki/Data_analysis "Wikipedia Data Analysis Page") is a process of inspecting, cleansing, transforming, and modeling data with the goal of discovering useful information, informing conclusions, and supporting decision-making.

Basically, the point is to turn data into information and information into knowledge. There are many ways to look at and compare dependent and independent variables, find relations, and even create models and predict behaviours. But, we are only going to focus on analyzing time and location data in the simplest way.

First, clean and filter the data:

~~~
library(dplyr)
library(glatos)
library(stringr)

detections_path <- system.file('extdata', 'blue_shark_detections.csv', package ='glatos')
detections <- glatos::read_otn_detections(detections_path)
detections <- detections %>% filter(!stringr::str_detect(unqdetecid, "release"))
detections <- glatos::false_detections(detections, tf = 3600)
filtered_detections <- detections %>% filter(passed_filter != FALSE)

detection_events <- glatos::detection_events(filtered_detections, location_col = 'station')
detection_events  # Time Series Analysis & Lubridate
~~~
{:.language-r}

Time series show the when, the before, and the after for data points. The [Lubridate](https://lubridate.tidyverse.org "Lubridiate Homepage") package is especially useful for handling time calculations.

Date-time data can be frustrating to work with in R. R commands for date-times are generally unintuitive and change depending on the type of date-time object being used. Moreover, the methods we use with date-times must be robust to time zones, leap days, daylight savings times, and other time related quirks, and R lacks these capabilities in some situations. Lubridate makes it easier to do the things R does with date-times and possible to do the things R does not.

~~~
library(lubridate)
detection_events <- detection_events %>% mutate(detection_interval = lubridate::interval(first_detection, last_detection))

# detection_events  
~~~
{:.language-r}

Now that we have an interval column, we can go row by row and look at each location to figure out if more than one animal was seen at a station. This is useful to find co-located detections.

~~~
for(event in detection_events$event) {

    detection_events$overlaps_with[event] = paste( # We use paste to create a string of other events
                                                which(detection_events$location == detection_events$location[event] &  # Make sure that the location is the same
                                                       detection_events$event != event &  # Make sure the event is not the same
                                                       lubridate::int_overlaps(detection_events$detection_interval[event], detection_events$detection_interval) # We can use lubridate's int_overlaps function to find the overlapping events
                                                     ),
                                                collapse=",")
}

detection_events
~~~
{:.language-r}

We can then filter based on whether or not the overlaps_with string is empty

~~~
detection_events %>% select(-one_of("detection_interval")) %>% filter(detection_events$overlaps_with != '')  
~~~
{:.language-r}

## Summarise

Summarise is a useful function implemented to create a new data frame from running functions on grouped data.

summarise() is typically used on grouped data created by group_by(). The output will have one row for each group.

~~~
summary_data <- detection_events %>% group_by(location) %>% summarise(detection_count = sum(num_detections),
                                                                      num_unique_tags = n_distinct(animal_id),
                                                                      total_residence_time_in_seconds = sum(detection_interval),
                                                                      latitude = mean(mean_latitude),
                                                                      longitude = mean(mean_longitude))  

summary_data
~~~
{:.language-r}

## Plotting

Plotting is necessary for most research and analysis. It's just an easier way for our brains to digest the information.

We will be using Plotly, a plotting package that allows for exports and interactivity.

We will create an abacus plot first. An abacus plot will show us a timline of what animal is seen when by the receivers. We put detection_timestamp_utc on the x axis and the animal_id on the y axis.

~~~
library(plotly)
abacus_plot <- filtered_detections %>%
    filter(str_detect(station, "HFX") & !str_detect(station, "lost")) %>%  # filter out everything not on the halifax line
    plot_ly(x = ~detection_timestamp_utc, y = ~animal_id,type = "scatter",  mode = "markers",text = ~station, marker=list(color = ~deploy_lat, colorscale="Viridis", showscale=TRUE)) # Use the marker argument to color by latitude

abacus_plot
~~~
{:.language-r}

## Maps

You can also plot your data against a map to give more geospatial context. Below is an example of a geospatial plot from plotly. The geo list sets the style and parameters for the map and will be passed into the layout function.

The scope of the map will determine what boundaries are drawn. You can also change the projection of the map. [(Reference)](https://plot.ly/r/reference/#layout-geo-projection "Map Projection Reference")

~~~
geo <- list(
#   scope = 'north america',
  showland = TRUE,
  landcolor = toRGB("#7BB992"),
  showocean = TRUE,
  oceancolor = toRGB("#A0AAB4"),
  showcountries = TRUE,
  resolution = 50,
  center = list(lat = ~median(latitude),
                lon = ~median(longitude)),
  lonaxis = list(range=c(~min(longitude)-1, ~max(longitude)+1)),
  lataxis = list(range=c(~min(latitude)-1, ~max(latitude)+1))
)


map <- summary_data %>%
    filter(str_detect(location, "HFX") & !str_detect(location, "lost")) %>%
    plot_geo(lat = ~latitude, lon = ~longitude, color = ~detection_count, height = 900 )%>%
    add_markers(
        text = ~paste(location, ': ', detection_count,'detections', ' & ', total_residence_time_in_seconds, ' seconds of residence time'),
        hoverinfo = "text",
        size = ~c(detection_count/10)#  + total_residence_time_in_seconds/3600)
    )%>%
    layout(title = "Detections on the Halifax Line",geo = geo)


map  
~~~
{:.language-r}

Here is some Mapping related code courtesy of J. Brownscombe.

~~~
dets <- read.csv("detections.csv") #detections from acoustic receivers
Rxdeploy <- read.csv("Rx_deployments.csv") #receiver station info
Rxmeta <- read.csv("Rx_metadata.csv") #receiver station info
tags <- read.csv("tag_info.csv") #tagged fish data


#check out the data (these are all data frames by default):
head(dets)
tail(dets)
str(dets)
dets[1:10,]

head(Rxdeploy)
head(Rxmeta)
head(tags)
~~~
{:.language-r}

The above code is duplicated in lesson 3, so we should probably figure out a better way to consolidate all this.

Notice the variables and their data type (important - google data types in R if unfamiliar)

Clearly we need to combine the above 4 dataframes in various ways to do anything with these data
Let's grease the wheels and check out fish tagging and receiver locations:

I like to use google maps to plot on for basic visualization. Google recently made it a little trickier to do this
because you have to go online and register a 'project' with them to get an API code. So this code will not work for
you unless you do that and get your API code that goes beside 'key' below.

[Here's the RData for the google map](https://github.com/ocean-tracking-network/jb-acoustic-telemetry/raw/gh-pages/Acoustic%20telemetry%20workshop%20workspace.RData)

~~~
library(ggmap)

# register_google(key = "")
FLmap <- get_googlemap(center = c(lon=-81.7, lat=24.8),
                        zoom = 8, size = c(640, 640), scale = 4,
                        maptype = c("satellite"))


#just load in the map from a workspace I provided (you need to change this to your working directory info)
load("~/Desktop/workshops/Acoustic telemetry workshop Dal 2019/Acoustic telemetry workshop workspace.RData")

ggmap(FLmap, extent='normal')+
  scale_x_continuous(limits=c(-82.6, -80.1))+
  scale_y_continuous(limits=c(24.2, 25.5))+
  ylab("Latitude") +
  xlab("Longitude")+
  geom_point(data=Rxmeta, aes(x=lon,y=lat), col="red",size=2)+
  geom_point(data=tags,aes(x=lon,y=lat), col="yellow", size=1)
~~~
{:.language-r}

In order to use dets in a meaningful way, we'll need to assign station deployments, metadata, and fish tagging
info to them.

~~~
# assign permit tag info to the detections ####

str(dets)
str(tags)

~~~
{:.language-r}

Let's assign FishID, tagging date (datetime), and fork length (FLmm) to detections.
but first, we'll deal with dates really quickly:

~~~
#date/times need to be converted to a POSIXct object to be manipulated and plotted:
tags$datetimeESTEDT <- as.POSIXct(tags$datetime, tz="EST5EDT", format="%d-%m-%Y %H:%M")
str(tags)

#convert to UTC time:
tags$datetimeUTC <- as.POSIXct(strftime(tags$datetimeESTEDT, tz="UTC", format="%Y-%m-%d %H:%M:%S"))
head(tags)
~~~
{:.language-r}



Now we can assign above variables from tags to dets using the merge function:

~~~
?merge
dets2 <- merge(dets, tags, by="Transmitter", all.x=TRUE)
head(dets2)
~~~
{:.language-r}

Now we would have to clean this dataset up quite a bit.

Another option is to use match:

~~~
dets$FishID <- tags$FishID[match(dets$Transmitter, tags$Transmitter)]
dets$FLmm <- tags$FLmm[match(dets$Transmitter, tags$Transmitter)]
dets$Tagdate <- tags$datetimeUTC[match(dets$Transmitter, tags$Transmitter)]
anyNA(dets$FishID)
head(dets)
~~~
{:.language-r}

## MapBox
Mapbox is a Live Location Platform that can serve up map tiles for use.

You can create a free account and get an access token [at the Mapbox site](https://mapbox.com, "Mapbox Home Page")

Below we set the access token as an environment variable that Plotly can call.

~~~
Sys.setenv('MAPBOX_TOKEN' = 'your token here')
~~~
{:.language-r}

From there, we can just call the [plot_mapbox()](https://plot.ly/r/scattermapbox/, "Plot_Mapbox reference") function and pass whatever arguments we need for the map.

~~~
mapbox <- summary_data %>%
    filter(str_detect(location, "HFX") & !str_detect(location, "lost")) %>%
    plot_mapbox(lat = ~latitude, lon = ~longitude, color = ~detection_count , height = 900) %>%
    add_markers(
        text = ~paste(location, ': ', detection_count,'detections', ' & ', total_residence_time_in_seconds, ' seconds of residence time'),
        hoverinfo = "text",
        size = ~c(detection_count/10  + total_residence_time_in_seconds/3600)
    )%>%
    layout( mapbox = list(zoom = 7,
                           center = list(lat = ~median(latitude),
                                         lon = ~median(longitude))
    ))

mapbox
~~~
{:.language-r}
