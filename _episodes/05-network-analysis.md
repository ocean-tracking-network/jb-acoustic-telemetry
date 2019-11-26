---
title: "Network Analysis"
teaching: 30
exercises: 0
questions:
- "What is network analysis?"
- "How do these packages facilitate network analysis?"
objectives:
- "Show how to use tools and plotly to create a network graph."
- "Show how to display the plotted network."
- "Demonstrate how to integrate station detections with a network."
keypoints:
- "Network analysis is the interpretation of connections between individual movements and receivers."
- "A data frame is created and cleaned to facilitate network analysis."
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
network_analysis_data <- detection_events %>%
  arrange(first_detection) %>% # Arrange in sequential order by time of arrival
  group_by(animal_id) %>% # Group the data  animal
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
  na.omit() # Omit any rows with empty values

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

Below we plot out the segments and vertices using plotly.

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
network  
~~~
{:.language-r}
