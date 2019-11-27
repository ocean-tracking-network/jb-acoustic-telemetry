---
title: "Additional Interpolation and Plotting with VTrack"
teaching: 30
exercises: 0
questions:
- "How can I use VTrack to further analyse my data?"
objectives:
- "Introduce VTrack and explain what it is for."
- "Properly configure data for use with VTrack."
- "Use VTrack to make plots and detection summaries."
keypoints:
- "VTrack provides robust options for more advanced visualization."
---

[VTrack](https://vinayudyawer.github.io/ATT/docs/ATT_Vignette.html "VTrack Reference") has some cool tools including COA and Brownian bridges.

# Setup data
Needs to be in specific format to load an ATT object, including detection data, tag metadata, and station info. Check out
[the VTrack reference](https://vinayudyawer.github.io/ATT/docs/ATT_Vignette.html) for specific data format requirements. GLATOS is capable of exporting their data to a format readable by VTrack. Conversion of OTN data requires data from the [OTN ERDDAP server](https://members.oceantrack.org/erddap/tabledap/index.html?page=1&itemsPerPage=1000) Data can be found at the following links: [Animals](https://members.oceantrack.org/erddap/tabledap/otn_aat_animals.html), [Receivers](https://members.oceantrack.org/erddap/tabledap/otn_aat_receivers.html), and [Tag Releases](https://members.oceantrack.org/erddap/tabledap/otn_aat_tag_releases.html).

~~~
# files retrived from OTN ERDDAP server
att_ani_path <- file.path('data', 'otn_att_animals.csv') 
att_dpl_path <- file.path('data', 'otn_att_receivers.csv') #
att_tag_path <- file.path('data', 'otn_att_tag_releases.csv')


att_dets <- read_otn_detections(det_file)
att_ani <- read.csv(att_ani_path, as.is = TRUE)
att_dpl <- read.csv(att_dpl_path, as.is = TRUE)
att_tag <- read.csv(att_tag_path, as.is = TRUE)

  
att_bluesharks <- glatos::convert_otn_erddap_to_att(att_dets, att_tag, att_dpl, att_ani)
~~~
{:.language-r}

## VTrack functionality:

### Can be used to make an abacus plot:
~~~
abacusPlot(att_bluesharks)
~~~
{:.language-r}

### Generate detection summary stats:
~~~
detSum<-detectionSummary(att_bluesharks,
                         sub = "%Y-%m")
detSum$Overall
~~~
{:.language-r}


### Calculate dispersal summary info
~~~
dispSum<-dispersalSummary(att_bluesharks)
~~~
{:.language-r}

### Just dispersal data:
~~~
dispSum2 <- dispSum %>% filter(Consecutive.Dispersal >0)
~~~
{:.language-r}


The glatos-based detection events above is an intermediate data summary that is useful for calculating residency at
receivers. This gives you more info on what the fish were doing in between.

In case you're ever interested in exploring the mechanics behind the functions:

~~~
getAnywhere(dispersalSummary)
~~~
{:.language-r}

Calculate Centers of Activity ([Simpfendorfer, C. A., M. R. Heupel, and R. E. Hueter. 2002.](https://doi.org/10.1139/f01-191))

~~~
?COA

COAdata <- COA(att_bluesharks, timestep=3600, split=TRUE)
warnings()
~~~
{:.language-r}



