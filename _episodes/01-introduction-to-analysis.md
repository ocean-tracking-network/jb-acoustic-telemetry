---
title: "Introduction to Acoustic Telemetry Data Analysis"
teaching: 5
exercises: 0
questions:
- "What methods of data analysis will be covered?"
objectives:
- "Introduce the intended audience."
- "Find out how to refresh R skills."
- "Know what steps will be taken for data analysis."
- "What is the GLATOS package?"
keypoints:
- "Techniques covered will include cleaning and sorting of data."
- "Various packages will be used for summarising and plotting data."
---

##  Intro to Telemetry Data Analysis

OTN, FACT and GLATOS all provide researchers with pre-formatted data sets, which are easily ingested into the data analysis tools.
Before diving into a lot of analysis, it is important to take the time to clean and sort your data set, taking the pre-formatted files and combining them in different ways, allowing you to analyse the data with different questions in mind.
There are multiple R packages necessary for efficient and thorough telemetry data analysis.  General packages that allow for data cleaning and arrangement, dataset manipulation and visualization, network analysis and temporo-spatial locating are used in conjuction with the telemetry analysis tool packages VTtrack, ATT and GLATOS.

##  Intro to the GLATOS Package

glatos is an R package with functions useful to members of the Great Lakes Acoustic Telemetry Observation System (http://glatos.glos.us). Developed by Chris Holbrook of GLATOS, OTN helps to maintain and keep relevant. Functions may be generally useful for processing, analyzing, simulating, and visualizing acoustic telemetry data, but are not strictly limited to acoustic telemetry applications.  Tools included in this package facilitate false filtering of detections due to time between pings and disstance between pings.  There are tools to summarise and plot, including mapping of animal movement.

##  Intro to VTrack and ATT

These packages were designed to facilitate the assimilation, analysis and synthesis of animal location and movement data collected by the VEMCO suite of acoustic transmitters and receivers. As well as database and geographic information capabilities the principal feature of VTrack is the qualification and identification of ecologically relevant events from the acoustic detection and sensor data. This procedure condenses the acoustic detection database by orders of magnitude, greatly enhancing the synthesis of acoustic detection data. [VTrack: A Collection of Tools for the Analysis of Remote Acoustic Telemetry Data](https://cran.r-project.org/web/packages/VTrack/index.html "VTrack: A Collection of Tools for the Analysis of Remote Acoustic Telemetry Data")

##  Intended Audience

This workshop is directed at researchers who are ready to begin the work of telemetry data analysis. Other workshops exist to help bring individuals up to speed so that they can ingest the following lessons.  If you need to refresh your R coding skills, we recommend [Data Analysis and Visualization in R for Ecologists](https://datacarpentry.org/R-ecology-lesson/ "Website for R ecology lesson") as a good starting point.


## More Resources

*  [Data Carpentry Lessons](https://datacarpentry.org/lessons/)
*  [High Performance Computing Lessons](https://hpc-carpentry.github.io/)


{% include links.md %}
