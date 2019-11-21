---
title: "The GLATOS Package"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

## GLATOS
There's an ongoing effort to combine the work done by many researchers worldwide on the creation of these and other analysis and visualization tools so that work is not duplicated, and so that researchers don't have to start from scratch when implementing analysis techniques.

The Great Lakes Acoustic Telemetry Observing System group has gathered a few of their more programming-minded researchers and authored an R package, and invited OTN and some technical people at Vemco to help them maintain and extend this package to ensure that it's useful for telemeters all over the world. There are a few very common methods of looking at acoustic detection data codified in glatos, and it serves as a great jumping off point for the design of new methods of analysis and visualization. The Pincock calculation above exists as a prebuilt function in the glatos toolbox, and there are a few others we'll peek at now to help us with the visualization of these datasets.

The notebook concept's a bit new to the glatos package, so be aware that its functions save most of their output to files. Those files will be in your project folder.

## False Detection Filtering using the Pincock algorithm.

Doug Pincock defined a temporal threshhold algorithm to determine whether detections in a set of detections from a station could be considered real ([Source](https://www.vemco.com/pdf/false_detections.pdf "Link to Pincock Paper")). The thrust of the filter is that a single detection at a station could very well be false, and it would require multiple detections of a tag by a receiver within a certain time frame to confirm that tag actually existed and was pinging at that station, and its ID was not the result of a collision event between two other tags.

Tag collision resulting in no detection:

Tag collision resulting in false detection:
(figs from False Detections: What They Are and How to Remove Them from Detection Data, Pincock 2012)

~~~
nr_detections_with_filter <- glatos::false_detections(non_release_detections, tf = 3600)
~~~
{:.language-r}

The result of false_detections() adds a passed_filter column to the table. We can use this column to get only the detections that passed the filter.

~~~
filtered_detections <- nr_detections_with_filter %>% filter(passed_filter != FALSE)
filtered_detections
~~~

{:.language-r}
