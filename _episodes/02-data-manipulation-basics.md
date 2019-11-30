---
title: "Data Manipulation Basics"
teaching: 20
exercises: 0
questions:
- "How do I load data?"
- "How do I clean data?"
- "How can I inspect data?"
objectives:
- "Explain data cleaning as a component of analysis."
- "Demonstrate read.csv() as a tool for loading data."
- "Explain the different kinds of files in which telemetry data is stored."
- "Use head, tail, str, and indexing to display loaded telemetry data."
keypoints:
- "read.csv() can be used to load data."
- "head, tail, and str() can be used to inspect data."
---

## Data Cleaning and Preprocessing

When analyzing data, 80% of time is spent cleaning and manipulating data and only 20% actually analyzing it. For this reason, it is critical to become familiar with the data cleaning process and getting your data into a format that can be analyzed. Let's begin with reading in our data using the suite of tidyverse functions.

Reading in data can be done using the `read_csv` function that automatically recognises data type in each column. The data is read in as a `tibble`.

~~~
library(tidyverse)

data <- read_csv("data/detections.csv")
data
~~~
{: .language-r}


The `read_csv` function outlines what each column was recognised as (e.g. double, integer, logical, date time). The function will also tell you which columns and rows it found difficult to recognise. In this case, the warnings specify that it was expecting the `sensor_value` and `sensor_unit` colums being a logical variable, but couldnt recognise the input.

~~~
# You can view the data you have just input using the `View()` function

View(data)
~~~
{: .language-r}


Load data.
This enables collapsing blocks of code using the drop arrow on the left


Acoustic telemetry data are commonly stored in 3 different files:
1. Detections
2. Receiver deployment metadata
3. Receiver metadata


~~~
dets_file <- file.path('data', 'detections.csv')
rcv_file <- file.path('data', 'deployments.csv')
tags_file <- file.path('data', 'animal_tags.csv')

dets <- read_csv(dets_file) #detections from acoustic receivers
Rxdeploy <- read_csv(rcv_file) #receiver station info
tags <- read_csv(tags_file) #tagged fish data
~~~
{:.language-r}

Check out the data (these are all data frames by default):

~~~
head(dets)
tail(dets)
str(dets)
dets[1:10,]

head(Rxdeploy)
head(tags)
~~~
{:.language-r}


Notice the variables and their data type (important - google data types in R if unfamiliar).

Clearly we need to combine the above 3 dataframes in various ways to do anything with these data
let's grease the wheels and check out fish tagging and receiver locations:
