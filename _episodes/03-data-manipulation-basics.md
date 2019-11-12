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

When analyzing data, 80% of time is spent cleaning and manipulating data and only 20% actually analyzing it. For this reason, it is critical to become familiar with the data cleaning process and getting your data into a format that can be analyzed.Let's begin with reading in our data using GLATOS (which will be explained below).

*The below is a kludge, part from our own acoustic telemetry proto-Carpentries thing and part from Jake Brownscombe's lecture. I'm not presently sure what the best way to integrate this is, but if someone better-informed than me wants to take a crack at it, that's A-OK by me. I've left in Brownscombe's use of read.csv rather than our own glatos::read_otn_detections bit because it seems more generic.
-- BD 20191008*
~~~
library(dplyr)
library(stringr)
options(repr.matrix.max.cols=500)

detections_path <- system.file('extdata', 'blue_shark_detections.csv', package ='glatos')
data <- read.csv(detections_path)
data
~~~
{: .language-r}

load data.
This enables collapsing blocks of code using the drop arrow on the left

Acoustic telemetry data are commonly stored in 4 different files:
1. detections
2. Receiver deployment information
3. Receiver metadata
4. Tagging information

~~~
dets <- read.csv("detections.csv") #detections from acoustic receivers
Rxdeploy <- read.csv("Rx_deployments.csv") #receiver station info
Rxmeta <- read.csv("Rx_metadata.csv") #receiver station info
tags <- read.csv("tag_info.csv") #tagged fish data
~~~
{:.language-r}

check out the data (these are all data frames by default):

~~~
head(dets)
tail(dets)
str(dets)
dets[1:10,]

head(Rxdeploy)
head(Rxmeta)
head(tags)
~~~
{:.language-r}


notice the variables and their data type (important - google data types in R if unfamiliar)

clearly we need to combine the above 4 dataframes in various ways to do anything with these data
let's grease the wheels and check out fish tagging and receiver locations:
