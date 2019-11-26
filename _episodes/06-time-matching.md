---
title: "Matching Detections to Times"
teaching: 15
exercises: 0
questions:
- "What is time matching?"
- "How do we perform time matching?"
objectives:
- "Explain time matching."
- "Step through the process of matching detections with times."
keypoints:
- "Time matching links station deployment information to verify that all detections fall within the deployment period."
- "Generate a dataset for the station info in order to group detections."
---

## Assigning DateTimes to Receivers

We'll join all the detections to station names, then filter out based on deploy and recovery date of the receiver and the detection timestamp.

~~~
det_file <- file.path('data', 'detections.csv')
rcv_file <- file.path('data', 'deployments.csv')

dets <- read_otn_detections(det_file)
Rxdeploy <- read_otn_deployments(rcv_file)


dets_with_stations <- left_join(
  dets %>% rename(
    deploy_long_det = deploy_long,
    deploy_lat_det = deploy_lat
  ), 
  Rxdeploy, by=c("station"))
dets_with_stations <- dets_with_stations %>% 
  filter(detection_timestamp_utc >= deploy_date_time, detection_timestamp_utc <= recover_date_time)


~~~
{:.language-r}
