---
title: "Data Manipulation Basics"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

## Data Cleaning and Preprocessing

When analyzing data, 80% of time is spent cleaning and manipulating data and only 20% actually analyzing it. For this reason, it is critical to become familiar with the data cleaning process and getting your data into a format that can be analyzed. Let's begin with reading in our data using read.csv (which will be explained below).


~~~
library(dplyr)
library(stringr)
options(repr.matrix.max.cols=500)

detections_path <- file.path('detections.csv')
data <- read.csv(detections_path)
data
~~~
{: .language-r}

load data.
This enables collapsing blocks of code using the drop arrow on the left

Acoustic telemetry data are commonly stored in 3 different files:
1. Detections
2. Receiver deployment metadata
4. Tagging information

~~~
dets_file = file.path('data', 'detections.csv')
rcv_file = file.path('data', 'deployments.csv')
tags_file = file.path('data', 'animal_tags.csv')

dets <- read.csv(dets_file) #detections from acoustic receivers
Rxdeploy <- read.csv(rcv_file) #receiver station info
tags <- read.csv(tags_file) #tagged fish data
~~~
{:.language-r}

check out the data (these are all data frames by default):

~~~
head(dets)
tail(dets)
str(dets)
dets[1:10,]

head(Rxdeploy)
head(tags)
~~~
{:.language-r}


notice the variables and their data type (important - google data types in R if unfamiliar)

clearly we need to combine the above 3 dataframes in various ways to do anything with these data
let's grease the wheels and check out fish tagging and receiver locations:
