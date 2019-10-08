---
title: "Introduction"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

load data. Notice the four # at the end of this line. ####
This enables collapsing blocks of code using the drop arrow on the left

Acoustic telemetry data are commonly stored in 4 different files:
1. detections
2. Receiver deployment information
3. Receiver metadata
4. Tagging information

dets <- read.csv("detections.csv") #detections from acoustic receivers
Rxdeploy <- read.csv("Rx_deployments.csv") #receiver station info
Rxmeta <- read.csv("Rx_metadata.csv") #receiver station info
tags <- read.csv("tag_info.csv") #tagged fish data


check out the data (these are all data frames by default):
head(dets)
tail(dets)
str(dets)
dets[1:10,]

head(Rxdeploy)
head(Rxmeta)
head(tags)



notice the variables and their data type (important - google data types in R if unfamiliar)

clearly we need to combine the above 4 dataframes in various ways to do anything with these data
let's grease the wheels and check out fish tagging and receiver locations:

{% include links.md %}
