---
title: "Data Analysis Using GLATOS"
teaching: 45
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
- "Multiple tools agregated to allow for data ingestion and filtering."
- "Provides functionality for creating basic plots from GLATOS formatted data."
---

## GLATOS Workbooks versus OTN Detection Extracts
Before we begin, we need to know if the data you plan to import is in the GLATOS format, or the OTN format. Both are acceptable for this lesson, but we use different functions to import them. Fortunately, it's easy to determine what format your data is in.

These two files contain similar information, but the difference between them lies in the names and types of columns in the file. We can check which format the data is in, therefore, by inspecting the file itself. We could inspect the file by opening the raw .csv and looking at the column headers, but some software, notably Microsoft Excel, can corrupt data like dates and times and render your file unusable. It's safer, and just as quick, to inspect the file with R.

We can inspect your data using the same techniques covered in [episode 2](/02-data-manipulation-basics.md "Episode 02: Data Manipulation Basics"). First, import your data with `read_csv`, then use `head()` to print out the first few rows:

~~~
detections_path <- file.path('../data', 'detections.csv')

col_specs <- cols(
  sensor_value = col_character(),
  sensor_unit = col_character(),
  glatos_caught_date = col_date()
)

data = read_csv(detections_path, col_types = col_specs)

head(data)
~~~
{:.language-r}

At this point, we can tell the format of the data. Because we have supplied explicit parsers for the sensor_value, sensor_unit, and glatos_caught_date columns, R looks for those columns when it loads the CSV. However, those columns don't exist in OTN formatted data! So, if your data is in the OTN format, it will produce the following error:

```
Warning message:
“The following named parsers don't match the column names: sensor_value, sensor_unit, glatos_caught_date”
```

Otherwise, if it's a GLATOS-formatted file, it will display without errors, and you should be able to find the sensor_value, sensor_unit, and glatos_caught_date among the column headers.

Once you know the format, you can choose the correct import function. For OTN-formatted data, use `glatos::read_otn_detections()`. For GLATOS-formatted data, use `glatos::read_glatos_detections()`. We have included both functions in the example below, so you can adapt the code to your needs.

## Data Analysis Using GLATOS
[Data analysis](https://en.wikipedia.org/wiki/Data_analysis "Wikipedia Data Analysis Page") is a process of inspecting, cleansing, transforming, and modeling data with the goal of discovering useful information, informing conclusions, and supporting decision-making.

Basically, the point is to turn data into information and information into knowledge. There are many ways to look at and compare dependent and independent variables, find relations, and even create models and predict behaviours. But, we are only going to focus on analyzing time and location data in the simplest way.

First, clean and filter the data:

~~~
library(tidyverse)
library(glatos)


detections_path <- file.path('data', 'detections.csv')
detections <- glatos::read_glatos_detections(detections_path)
#If using OTN detections, comment the line above and uncomment the line below.
#detections <- glatos::read_otn_detections(detections_path)

detections <- glatos::false_detections(detections, tf = 3600)
filtered_detections <- detections %>% filter(passed_filter != FALSE)

detection_events <- glatos::detection_events(filtered_detections, location_col = 'station')
detection_events  
~~~
{:.language-r}

## Time Series Analysis & lubridate

Time series show the when, the before, and the after for data points. The [lubridate](https://lubridate.tidyverse.org "Lubridiate Homepage") package is especially useful for handling time calculations.

Date-time data can be frustrating to work with in R. R commands for date-times are generally unintuitive and change depending on the type of date-time object being used. Moreover, the methods we use with date-times must be robust to time zones, leap days, daylight savings times, and other time related quirks, and R lacks these capabilities in some situations. Lubridate makes it easier to do the things R does with date-times and possible to do the things R does not.

~~~
library(lubridate)

detection_events <-
    detection_events %>%
    mutate(detection_interval = lubridate::interval(first_detection, last_detection))

detection_events
~~~
{:.language-r}

Now that we have an interval column, we can go row by row and look at each location to figure out if more than one animal was seen at a station. This is useful to find co-located detections.

~~~
for(event in detection_events$event) {
    detection_events$overlaps_with[event] = paste( # We use paste to create a string of other events
        which(detection_events$location == detection_events$location[event] &  # Make sure that the location is the same
            detection_events$event != event &  # Make sure the event is not the same
            lubridate::int_overlaps(detection_events$detection_interval[event], detection_events$detection_interval)
            # We can use lubridate's int_overlaps function to find the overlapping events
        ),
        collapse=",")
}

detection_events
~~~
{:.language-r}

We can then filter based on whether or not the overlaps_with string is empty

~~~
detection_events %>%
    select(-one_of("detection_interval")) %>%
    filter(detection_events$overlaps_with != '')  
~~~
{:.language-r}

## Summarise

Summarise is a useful function implemented to create a new data frame from running functions on grouped data.

summarise() is typically used on grouped data created by group_by(). The output will have one row for each group.

~~~
summary_data <-
    detection_events %>%
    group_by(location) %>%
    summarise(detection_count = sum(num_detections),
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

We will create an abacus plot first. An abacus plot will show us a timeline of what animal is seen when by the receivers. We put detection_timestamp_utc on the x axis and the animal_id on the y axis.

~~~
library(plotly)

abacus_plot <-
    filtered_detections %>%
    filter(!str_detect(station, "lost")) %>%
    ggplot(aes(x = detection_timestamp_utc, y = animal_id, color = deploy_lat)) +
    geom_point() +
    ylab("Animal ID") + xlab("Date") + labs(color = "Detection latitude") +
    theme_minimal()

## Static plot
abacus_plot

## Interactive plot using plotly
ggplotly(abacus_plot)

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
  showrivers = TRUE,
  rivercolor = toRGB("#A0AAB4"),
  showlakes = TRUE,
  lakecolor = toRGB("#A0AAB4"),
  showcountries = TRUE,
  resolution = 50,
  center = list(lat = ~median(latitude),
                lon = ~median(longitude)),
  lonaxis = list(range=c(~min(longitude) - 4, ~max(longitude) + 4)),
  lataxis = list(range=c(~min(latitude) - 4, ~max(latitude) + 4))
)


map <- summary_data %>%
    filter(!str_detect(location, "lost")) %>%
    plot_geo(lat = ~latitude, lon = ~longitude, color = ~detection_count, height = 900 )%>%
    add_markers(
        text = ~paste(location, ': ', detection_count,'detections', ' & ', total_residence_time_in_seconds, ' seconds of residence time'),
        hoverinfo = "text",
        size = ~c(detection_count/10)#  + total_residence_time_in_seconds/3600)
    )%>%
    layout(title = "Detections in the Great Lakes", geo = geo)


map  
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
    filter(!str_detect(location, "lost")) %>%
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


## Mapview

Lets replicate this using the `mapview` package

~~~
library(mapview)
library(sf)

map <-
  summary_data %>%
  filter(!str_detect(location, "lost")) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  mapview(zcol = "detection_count", cex = "detection_count")  

map
~~~
{:.language-r}
