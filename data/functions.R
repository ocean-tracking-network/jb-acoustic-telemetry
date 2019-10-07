#Jake Brownscombe's functions for analysing telemetry data:


#Moveinfo is for dataframes that do not have tagging locations included. 
#Requires lat,lon, datetime (posix object),Transmitter
MoveInfo <- function(a){
  library(geosphere)
  p <- a[c("lon", "lat")]
  p1dist <- distGeo(p)
  p1dist <- data.frame(p1dist)
  p1dist$nrow <- 1:length(p1dist$p1dist)
  p1dist$nrow <- p1dist$nrow+1
  a$nrow <- 1:length(a$lat)
  p1dist$Transmitter <- a$Transmitter
  p1dist$Transmitter2 <- a$Transmitter[match(p1dist$nrow, a$nrow)]
  p1dist$datetime <- a$datetime
  p1dist$datetime2 <- a$datetime[match(p1dist$nrow, a$nrow)]
  p1dist$dist2 <- ifelse(p1dist$Transmitter==p1dist$Transmitter2, p1dist$p1dist, 0)
  p1dist$timediff <- ifelse(p1dist$Transmitter==p1dist$Transmitter2,as.numeric(p1dist$datetime2-p1dist$datetime),0)
  p1dist$speed <- ifelse(p1dist$Transmitter==p1dist$Transmitter2, round(p1dist$dist/p1dist$timediff,5),0)
  p1dist$speed[is.na(p1dist$speed)]<-0
  head(p1dist)
  a$dist <- p1dist$dist2[match(a$nrow, p1dist$nrow)]
  a$timediff <- p1dist$timediff[match(a$nrow, p1dist$nrow)]
  a$speed <- p1dist$speed[match(a$nrow, p1dist$nrow)]
  a$dist[is.na(a$dist)]<-0
  a$timediff[is.na(a$timediff)]<-0
  a$speed[is.na(a$speed)]<-0
  a$nrow <- NULL
  MoveInfodf <<- as.data.frame(a)
  message("MoveInfodf dataframe returned with time, distance, and speed:") 
  return(head(MoveInfodf))
  
}



#Data filtering. You might consider removing:
#1.detections before tags were deployed
#2.repeat detections (those that occured less than the min tag delay)
#3.single detections, requiring multiple detections in a given time period (min_lag)
#4.detections that indicate unrealistic movement speeds.


#first calculate minimum lag that occured between detections:
min_lag <- function (det) 
{
  dtc <- data.table::as.data.table(det)
  dtc[, `:=`(ord, 1:.N)]
  data.table::setkey(dtc, Transmitter, Receiver, datetime)
  dtc[, `:=`(min_lag, pmin(diff(c(NA, as.numeric(datetime))), 
                           diff(c(as.numeric(datetime), NA)), na.rm = TRUE)), 
      by = c("Transmitter", "Receiver")]
  setkey(dtc, ord)
  drop_cols <- "ord"
  dtc <- dtc[, !drop_cols, with = FALSE]
  return(as.data.frame(dtc))
}


#apply filters described above:
DetFilter <- function (det, tf, mindelay=60, mindist=2000, maxspeed=3, minlag = "min_lag", show_plot = FALSE, ...) 
{  
  nr <- nrow(det)
  det$Transmitter <- as.character(det$Transmitter)
  det$Receiver <- as.character(det$Receiver)
  det$nrow <- 1:length(det$datetime)
  p <- data.frame(nrow=det$nrow+1)
  p$Transmitter <- det$Transmitter
  p$Receiver <- det$Receiver
  det$Transmitteroff <- p$Transmitter[match(det$nrow, p$nrow)]
  det$Receiveroff <- p$Receiver[match(det$nrow, p$nrow)]
  det$Transmitteroff[1]="none"
  det$Receiveroff[1]="none"
  
  if("Tagdate" %in% names(det)) { 
  det$Pre_tag_filter <- ifelse(det$datetime >= det$Tagdate, 1,0)
  message(paste0("Pre tag filter identified ", nr - sum(det$Pre_tag_filter), 
                 " (", round((nr - sum(det$Pre_tag_filter))/nr * 100, 2), 
                 "%) of ", nr, " detections as potentially false (before tag deployment)")) }
  else {message("No Tagging information currently available. Pre_tag_filter not applied")}

  det$Min_tag_delay_filter <- ifelse(det$Transmitteroff==det$Transmitter,
                                     ifelse(det$timediff<mindelay,0,1),1)
  message(paste0("Min tag delay filter identified ", nr - sum(det$Min_tag_delay_filter), 
                 " (", round((nr - sum(det$Min_tag_delay_filter))/nr * 100, 2), 
                 "%) of ", nr, " detections as duplicates (multiple detections within min tag delay)"))
  
  det$Min_tag_delay_distance_filter <- ifelse(det$Transmitteroff==det$Transmitter,
                                     ifelse(det$dist>mindist & det$timediff<mindelay,0,1),1)
  message(paste0("Min tag delay distance filter identified ", nr - sum(det$Min_tag_delay_distance_filter), 
                 " (", round((nr - sum(det$Min_tag_delay_distance_filter))/nr * 100, 2), 
                 "%) of ", nr, " detections as potentially false duplicates (multiple detections within min tag delay across large distances)"))
  
  det$Min_tag_delay_receiver_filter <- ifelse(det$Transmitteroff==det$Transmitter,
                                              ifelse(det$Receiveroff==det$Receiver,
                                              ifelse(det$timediff<mindelay,0,1),1),1)
  message(paste0("Min tag delay receiver filter identified ", nr - sum(det$Min_tag_delay_receiver_filter), 
                 " (", round((nr - sum(det$Min_tag_delay_receiver_filter))/nr * 100, 2), 
                 "%) of ", nr, " detections as potentially false (duplicates at the same receiver)"))
  
  det$Speed_time_filter <- ifelse(det$speed<maxspeed | det$speed>maxspeed & det$dist<mindist,1,0)
  message(paste0("Speed time filter identified ", nr - sum(det$Speed_time_filter), 
                 " (", round((nr - sum(det$Speed_time_filter))/nr * 100, 2), 
                 "%) of ", nr, " detections as potentially false (too fast)"))
  
  library(dplyr)
  det2 <- det %>% filter(Min_tag_delay_receiver_filter==1) %>% as.data.frame()
  
  library(data.table)
  if (!(minlag %in% names(det2))) {
    det2 <- min_lag(det2)
  }
  
  det2$min_lag_filter <- ifelse(!is.na(det2$min_lag) & det2$min_lag <= tf,1,0)
  det$min_lag_filter <- det2$min_lag_filter[match(det$nrow, det2$nrow)]
  det$min_lag <- det2$min_lag[match(det$nrow, det2$nrow)]
  det$min_lag_filter[is.na(det$min_lag_filter)] <-1
  det$min_lag[is.na(det$min_lag)] <-0
  
  message(paste0("Min lag filter identified ", nr - sum(det$min_lag_filter), 
                 " (", round((nr - sum(det$min_lag_filter))/nr * 100, 2), 
                 "%) of ", nr, " detections as potentially false (single detection within set tf)"))
  
  det$Receiveroff <- det$Transmitteroff <- det$nrow <- NULL
  return(det)
}








#detection events filter (from Glatos):

Events <- function (det, station="station", period = Inf, 
          condense = TRUE) 
{ library(data.table)
  detections <- data.table::as.data.table(det)
  if (!is.logical(condense)) 
    stop("input argument 'condense' must be either TRUE or FALSE (unquoted).")
  missingCols <- setdiff(c("FishID", "datetime", 
                           "lat", "lon"), names(detections))
  if (length(missingCols) > 0) {
    stop(paste0("Detections dataframe is missing the following ", 
                "column(s):\n", paste0("       '", missingCols, "'", 
                                       collapse = "\n")), call. = FALSE)
  }
  if (!("POSIXct" %in% class(detections$datetime))) {
    stop(paste0("Column 'datetime' in the detections dataframe", 
                "must be of class 'POSIXct'."), call. = FALSE)
  }
  FishID <- datetime <- time_diff <- arrive <- depart <- event <- lat <- lon <- NULL
  data.table::setnames(detections, station, "station")
  data.table::setkey(detections, FishID, datetime)
  detections[, `:=`(time_diff, c(NA, diff(as.numeric(datetime)))), 
             by = c("FishID", "station")]
  detections[, `:=`(arrive, as.numeric((station != data.table::shift(station, 
                                                                          fill = TRUE)) | (time_diff > period))), by = FishID]
  detections[, `:=`(depart, as.numeric((station != data.table::shift(station, 
                                                                          fill = TRUE, type = "lead")) | (data.table::shift(time_diff, 
                                                                                                                            fill = TRUE, type = "lead") > period))), by = FishID]
  detections[, `:=`(event, cumsum(arrive))]
  Results = detections[, .(individual = FishID[1], location = station[1], 
                           mean_latitude = mean(lat, na.rm = T), mean_lonitude = mean(lon, 
                                                                                              na.rm = T), first_detection = datetime[1], 
                           last_detection = datetime[.N], num_detections = .N, 
                           res_time_sec = diff(as.numeric(range(datetime)))), 
                       by = event]
  if (condense) {
    message(paste0("The event filter distilled ", nrow(detections), 
                   " detections down to ", nrow(Results), " distinct detection events."))
    EventSum <<- as.data.frame(Results)
    message("Returned EventSum with summarised detection events")
  }
  else {
    message(paste0("The event filter identified ", max(detections$event, 
                                                       na.rm = TRUE), " distinct events in ", nrow(detections), 
                   " detections."))
    message("Returned EventData with detection events added")
    data.table::setnames(detections, "station", station)
    EventData <- as.data.frame(detections)
    EventData$time_diff=NULL
    EventData <<- EventData
  }
}




multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
