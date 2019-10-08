---
title: "Introduction to Acoustic Telemetry"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

## What is Acoustic Telemetry?

Acoustic telemetry relies on a series of timed pings to transmit unique values from an implanted or affixed acoustic tag to a receiving station. These pings are all transmitted on the same small set of frequencies, and are subject to being confounded by noise interference, barriers to physical propagation in the water column, and collisions between two pinging tags. For noise interference or physical propagation issues, the result is nearly always a false negative, no detection is recorded at the receiver, but there could have been a tag in proximity to the receiver. For collisions between two pinging tags A and B, it is sometimes the case that the two pinging tags at the same freqency create a valid series of pings between them that generates a third code that is neither tag A nor B. This false positive is screened out of the acoustic detection data sets post-processing using a fairly straightforward analysis.

## Gathering the Data

Recovering the data from an acoustic telemetry study usually involves collecting the deployed listening instruments (acoustic receivers), downloading their onboard data into a vendor-supplied program (like Vemco VUE), and extracting a detection summary - which is often a square matrix of which receivers saw which tags and when.<span style='color:black;font-family:Courier'>Detection Time</span>  ,  <span style='color:green;font-family:Courier'>Tag Code</span>  ,  <span style='color:royalblue;font-family:Courier'>Rcvr Serial #</span>The researcher must then substitute in the information they have about the animal according to the tag codes, and information about the receiver according to the receiver's serial no. There's a lot of information that isn't contained in the vendor-supplied datasets, a lot of metadata telling us about:
when and where receivers and tags were deployed and recovered; and
when they could have been in position to create a valid detection event.

At the <a href="http://oceantrackingnetwork.org"> Ocean Tracking Network</a>, we track a lot of extra variables for all of our researchers to help us handle the more complicated aspects of working with lots of interchangeable receivers in the field, handling redeployment of receivers or tags, or working with active detection platforms like aquatic underwater vehicles (AUV) or animal-mounted receivers. For our purposes today, we'll keep it simpler than that. We'll start from a detection extract datafile from the OTN data system, one that's already matched up tag to animal and receiver to location, and that knows a few other things you might need to do a thorough analysis of this dataset.<span style='color:black;font-family:Courier'>Detection Time</span> ,  <span style='color:green;font-family:Courier'> [ Tag Code  , Species  ,  Individual Name ]</span>  ,  <span style='color:royalblue;font-family:Courier'> [ Rcvr Serial #  ,   Latitude   ,  Longitude ]</span>.

In this lesson we'll take a shortcut on combining this data by using the detection data that OTN extracts from our database for researchers to use, combining the tags from Brendal Townsend's blue shark project you've already heard about, and two of OTN's own receiver lines, our Halifax Line and the Cabot Strait Line. This matches station location to serial number to detection event to tag ID to tagged animal. Once we load the detection extract and look around, we'll run a filtering algorithm on the data and see if all the detections found in the OTN database can be attributed to this project fairly and we can have confidence in them. Then we'll plot the detection set a few different ways using the glatos acoustic telemetry analysis and visualization package. If we get through all that we'll get into the OTN-supported python package resonATe that does a lot of these things too, as well as other analyses.

library(dplyr)
options(repr.matrix.max.cols=500)
data <- read.csv("data/nsbs_matched_detections_2014.csv")
data

load data.
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
