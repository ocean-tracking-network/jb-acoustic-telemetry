---
title: "The R Programming Language"
teaching: 0
exercises: 0
questions:
- "Key question (FIXME)"
objectives:
- "First learning objective. (FIXME)"
keypoints:
- "First key point. Brief Answer to questions. (FIXME)"
---

## R: A Statistical Programming Language

R is a language and environment for statistical computing and graphics. R provides a wide variety of statistical (linear and nonlinear modelling, classical statistical tests, time-series analysis, classification, clustering, …) and graphical techniques, and is highly extensible.Source: [https://www.r-project.org/about.html](https://www.r-project.org/about.html) R Scripts
An R script is simply a text file containing (almost) the same commands that you would enter on the command line of R. ( almost) refers to the fact that if you are using sink() to send the output to a file, you will have to enclose some commands in print() to get the same output as on the command line.Source: [https://cran.r-project.org/doc/contrib/Lemon-kickstart/kr_scrpt.html](https://www.r-project.org/about.html)

~~~
variable <- "Your name"

print(variable)
~~~
{:.language-r}


## Data Types

R has a wide variety of data types including scalars, vectors (numerical, character, logical), matrices, data frames, and lists. Check out a short explanation here: [https://www.statmethods.net/input/datatypes.html](https://www.statmethods.net/input/datatypes.html) Our data has been read in and the columns have been converted to their proper data types.

~~~
sapply(detections, class)
~~~
{:.language-r}

## R Packages

Packages are collections of R functions, data, and compiled code in a well-defined format. The directory where packages are stored is called the library. R comes with a standard set of packages. Others are available for download and installation. Once installed, they have to be loaded into the session to be used.Source: [https://www.statmethods.net/interface/packages.html](https://www.statmethods.net/interface/packages.html)

### Install the R package stringr

~~~
install.packages("stringr")  stringr
~~~
{:.language-r}

A consistent, simple and easy to use set of wrappers around the fantastic 'stringi' package. All function and argument
names (and positions) are consistent, all functions deal with "NA"'s and zero length vectors in the same way, and the
output from one function is easy to feed into the input of another. library(stringr)  We can use stringr to find substrings using Regular Expressions or strings.

~~~
stringr::str_detect(variable, "[aeiou]")  
~~~
{:.language-r}

stringr also has a function to count the occurance of substrings.

~~~
stringr::str_count(variable, "[aeiou]")
~~~
{:.language-r}

### stringr + dplyr

Let's import some data a find a sepcific string in a column.

~~~
library(dplyr)
detections_path <- system.file('extdata', 'blue_shark_detections.csv', package ='glatos')
data <- read.csv(detections_path)
stringr::str_detect(data$unqdetecid, "release")
~~~
{:.language-r}

## Filtering
We can use dplyr::filter() to find rows/cases where conditions are true. Combining this with stringr::str_detect()

dplyr Filtering: [https://dplyr.tidyverse.org/reference/filter.html](https://dplyr.tidyverse.org/reference/filter.html)

~~~
releases <- detections %>% dplyr::filter(stringr::str_detect(unqdetecid, "release"))  
~~~
{:.language-r}

~~~
non_release_detections <- detections %>% dplyr::filter(!stringr::str_detect(unqdetecid, "release"))
~~~
{:.language-r}

Total Detections
~~~
 count(detections)  
~~~
{:.language-r}

Number of releases
~~~
 count(releases)
~~~
{:.language-r}

Number of Non-Release Detections (The Good Stuff)
~~~
count(non_release_detections)
~~~
{:.language-r}

{% include links.md %}
