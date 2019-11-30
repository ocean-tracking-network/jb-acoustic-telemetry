---
title: "Working with Spatial data"
teaching: 20
exercises: 0
questions:
- "How do I convert my data into a spatial object?"
- "How do I transform my spatial data to different Coordinate Reference Systems?"
- "How can I plot my spatial data?"
objectives:
- "Explain how to work with spatial data in R."
- "Demonstrate main sf package functions."
- "Explain what coordinate refence systems are and how to convert between them."
- "Use mapview to quickly plot spatial data."
keypoints:
- "st_as_sf() can easily convert data frame to a spatial object."
- "mapview() is a quick and simple way to visualise spatial data."
---

## Working with Spatial data

R offers a variety of functions for importing, manipulating, analysing and exporting spatial data. Although one might at first consider this to be the exclusive domain of GIS software, using R can frequently provide a much more lightweight, yet equally effective solution that embeds within a larger analytic workflow.

One of the tricky aspects of pulling spatial data into your analytic workflow is that there are numerous complicated data formats. In fact, even within R itself, functions from different user-contributed packages often require the data to be structured in very different ways. The good news is that just like the `tidyverse` package family, efforts are underway to standardize spatial data classes in R.

This movement is facilitated by `sf`, an important base package for spatial operations in R. It provides definitions for basic spatial classes (points, lines, polygons, pixels, and grids) in an attempt to unify the way R packages represent and manage these sorts of data. Functions within this package are designed to work well with the `tidyverse` functions seamlessly. 

Lets now use the 'st_as_sf()' function in the `sf` package to convert our receiver data into a spatial object

~~~
library(tidyverse)
library(sf)

Rxdeploy <- read_csv("data/deployments.csv") #receiver station info

Rxdeploy

# Now lets convert this tibble into a spatial object

rec_sf <-
  Rxdeploy %>% 
  st_as_sf(coords = c("deploy_long", "deploy_lat")) ## specify which columns contain the longitude and latitude data

rec_sf

plot(rec_sf["glatos_array"])
~~~
{: .language-r}



# Coordinate Reference Systems (CRS)
Central to working with spatial data, is that these data have a coordinate reference system (CRS) associated with it. Geographical CRS are expressed in degrees and associated with an ellipse, a prime meridian and a datum. Projected CRS are expressed in a measure of length (meters) and a chosen position on the earth, as well as the underlying ellipse, prime meridian and datum.

Most countries have multiple coordinate reference systems, and where they meet there is usually a big mess — this led to the collection by the European Petroleum Survey Group (EPSG) of a geodetic parameter dataset.

The EPSG list among other sources is used in the workhorse PROJ.4 library, and handles transformation of spatial positions between different CRS. This library is interfaced with R in the `sf` package.

For simplicity, each projection can be referred to by a unique ID from the European Petroleum Survey Group (EPSG) geodetic parameter dataset. You can find the relevant EPSG code for your coordinate system from this website: https://epsg.io 
There, simply enter in a key word in the search box and select from the list the correct coordinate system. There is a map image in the top right of the site to help you.

The equivalent EPSG code for WGS 84 (Latitude/Longitude data) is 4326. In the next step, lets convert our receiver dataset (Rxdeploy) again into a spatial object but this time specify the CRS.

~~~

rec_sf <-
  Rxdeploy %>% 
  st_as_sf(coords = c("deploy_long", "deploy_lat"),
           crs = 4326)    ## specify your epsg code in the crs parameter 

rec_sf

plot(rec_sf["glatos_array"])

~~~
{: .language-r}


## Map spatial data interactively

Leaflet is an open-source JavaScript librarby that can be used to quickly plot interactive maps with open-source basemaps. In R, the `mapview` package provides functions to very quickly and conveniently create interactive visualisations of spatial data.

Now lets create a quick interactive map of our reciever array

~~~
library(mapview)

mapview(rec_sf)

~~~
{: .language-r}


As you can see, there are a few options to change the background map, including satellite imagery, Open Street Map, and topographic basemaps. If you want more information on each point, click on it, the map will provide all information available for each reciever station as a pop-up table.

We can also present more information in this map and interactively group points based on data attributes


~~

mapview(rec_sf, 
        zcol = "glatos_project",
        burst = TRUE)

~~~
{: .language-r}
        
You can now play around with the map, select and de-select arrays based on the "glatos_project" attribute.      



