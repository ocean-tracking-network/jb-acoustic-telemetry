---
layout: reference
---

## Glossary

{:auto_ids}
abacus plot
:   A dot-plot, often with time as the X axis, station as the Y axis, and individual ID as the color-code, popular in telemetry studies to show patterns of animal/spatial use over time.

acoustic telemetry
:   The practice of affixing animals with uniquely-coded acoustic pingers and deploying listening stations to identify and locate them over time.

ATT
:   A set of metadata formats implemented as an object in R. Devised by Vinay Udyawer of AIMS for use in the VTrack analysis package, standardizing the reporting of listening device deployment and recovery, tagging efforts, and detection events into one uniform data format.

Brownian bridges
:   A conditional probability distribution that pins the process at both origin and a second time (t), a paradigm that is very useful for estimating path probability between two known events (i.e.: the location of an animal at two points in time and space).

COA/Centers of Activity
:   An estimate of relative spatial activity given input data about animal positions in time. Based on technique described in: Simpfendorfer, C. A., M. R. Heupel, and R. E. Hueter. 2002. Estimation of short-term centers of activity from an array of omnidirectional hydrophones and its use in studying animal movements. Canadian Journal of Fisheries and Aquatic Sciences 59:23-32.

data cleaning
:   The process of removing irregularities in formatting, errors, and typos from data to ensure uniform operation in analysis and visualization.

dplyr
:   An R package focused on manipulating, subsetting, and summarising data frames (square matrices of data). Very useful for working with our tabular datasets. Part of the 'Tidyverse' family of R packages.

FishID
:   A unique identifier for an individual animal observed at a location and time, regardless of the method of location. Often synonymous with catalognumber and animalID.

fork length
:   A common measurement for fish length, the length from nose to tail fork.

glatos
:   A package maintained by the telemetry network of the same name to ingest, standardize, and operate on acoustic telemetry datasets.

Lubridate
:   Date manipulator package. Part of the 'Tidyverse' family of R packages.

MapBox
:   A geospatial visualization library, an open source mapping platform for custom-designed maps.

package
:   In R, a package is a collection of R functions, data and compiled code. The location where the packages are stored is called the library. If there is a particular functionality that you require, you can download the package from the appropriate site and it will be stored in your library.

ping
:   A series of transmissions made by an acoustic tag for the purposes of relaying its unique code to a listening instrument.

POSIX
:   A set of IEEE standards that are meant to guarantee interoperability. In most common R parlance, it's a shorthand for the functions that standardize the format for a date and time.

R
:   A statistical programming language.

residence index
:   Any of a few ratios that can be calculated to determine the relative spatial use of an animal across an observatory of listening devices.

station
:   A geographical location where listening equipment is deployed and recovered regularly.

stringr
:   Character string manipulator package. Part of the 'Tidyverse' family of R packages.

tagging date
:   The date an animal was affixed with an electronic tag (acoustic or otherwise).

Time series
:   A dataset that takes measurements regularly over a period of time.

Tx receivers
:   Listening devices that also transmit their own coded pings, for the purposes of synchronizing clocks or for being heard by mobile listening stations.

{% include links.md %}
