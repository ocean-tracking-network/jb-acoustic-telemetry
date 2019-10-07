######################################################
Neaten = function(RecLog, StNam){
  require(lubridate)
  # This function reads in, and trims the receiver log.
  #   It then converts dateTimeUTC to a POSIX dateTime object,
  #   and shortens the transmitter code to the last 5 digits
  #   and calls it Tag.
  
  # Select some columns with actual data in them
  StNam = RecLog[,c(1:3,8)]
  # Rename first column 
  names(StNam)[1] <- "dateTimeUTC"
  
  # Make dateTimeUTC a POSIXlt object
  StNam$DT = symd_hms(StNam$dateTimeUTC, tz="UTC")    
  
  # Make new variable Tag as last 5 characters in Transmitter
  StNam$Tag = as.factor(substr(as.character(StNam$Transmitter), 10,14))
  
  return(StNam)
}

MoveEdgeList = function(MoveT){
  # This function makes a dataframe containing a list of edges when given
  # the table of movements between stations.
  #
  # MoveT - Movement table obtained by table(FromStation,ToStation)
  #
  n=length(MoveT[,1])
  # Should check to make sure matrix has dim = (n,n)
  dim(MoveT)==c(n,n)
  
  # Make data frame with dummy first row.  Delete it later!
  df = data.frame(from=0, to=0, weight=0)  
  # Add movements between nodes
  for (i in 1:n){
    for (j in 1:n){
      if (MoveT[i,j]>0) {
        from = rownames(MoveT)[i]
        to = colnames(MoveT)[j]
        weight = as.numeric(MoveT[i,j])
        df = rbind(df,c(from,to,weight))
      } 
      if (MoveT[i,j]==0 & i==j) {
        from = rownames(MoveT)[i]
        to = colnames(MoveT)[j]
        weight = as.numeric(MoveT[i,j])
        df = rbind(df,c(from,to,weight))
      }
    }
  }
  df = df[-1,]
  return(Edges=df) 
}

MoveEdgeList.nm = function(MoveT){
  # This function makes a dataframe containing a list of edges when given
  # the table of movements between stations.
  #
  # MoveT - Movement table obtained by table(FromStation,ToStation)
  #
  # This version deals with non-square tables, and remembers zero weights
  n=length(MoveT[,1]) # Number of Rows
  m=length(MoveT[1,]) # Number of Cols

  # Make data frame with dummy first row.  Delete it later!
  df = data.frame(from=0, to=0, weight=0)  
  # Add movements between nodes
  for (i in 1:n){
    for (j in 1:m){
      if (MoveT[i,j]>0) {
        from = rownames(MoveT)[i]
        to = colnames(MoveT)[j]
        weight = as.numeric(MoveT[i,j])
        df = rbind(df,c(from,to,weight))
      } 
      if (MoveT[i,j]==0 & i==j) {
        from = rownames(MoveT)[i]
        to = colnames(MoveT)[j]
        weight = as.numeric(MoveT[i,j])
        df = rbind(df,c(from,to,weight))
      }
    }
  }
  df = df[-1,]
  return(Edges=df) 
}

MoveEdgeList.nm.nz = function(MoveT){
  # This function makes a dataframe containing a list of edges when given
  # the table of movements between stations.
  #
  # MoveT - Movement table obtained by table(FromStation,ToStation)
  #
  #  This version .nm.nz can deal with non-square tables, 
  #     and produces no zero weights
  #
  n=length(MoveT[,1]) # Number of Rows
  m=length(MoveT[1,]) # Number of Cols
  
  # Make data frame with dummy first row.  Delete it later!
  df = data.frame(from=0, to=0, weight=0)  
  # Add movements between nodes
  for (i in 1:n){
    for (j in 1:m){
      if (MoveT[i,j]>0) {
        from = rownames(MoveT)[i]
        to = colnames(MoveT)[j]
        weight = as.numeric(MoveT[i,j])
        df = rbind(df,c(from,to,weight))
      } 
    }
  }
  df = df[-1,]
  return(Edges=df) 
}

CalculateStats = function(Move){
  # This function calcluates the number of movements between stations
  #   and the average time between movements, the standard deviation, and the 
  #   standard error
  # Calculate number of movements between stations
  (numObs = tapply((Move$DetectTime*0+1), 
                   Move$FromStation : Move$Station.Name, sum))
  # Calculate the average time of each type of movement (in minutes)
  (meanTimes = tapply(as.numeric(Move$DetectTime/60), 
                      Move$FromStation : Move$Station.Name, mean))
  # Calculate the standard deviation for time of each type of movement (in minutes)
  (sdTimes = tapply(as.numeric(Move$DetectTime/60), 
                    Move$FromStation : Move$Station.Name, sd))
  # Calculate the standard errors for time of each type of movement (in minutes)
  (seTimes = sdTimes / sqrt(numObs))
  
  return(list(numObs=numObs, meanTimes=meanTimes, sdTimes=sdTimes, seTimes=seTimes)) 
  }


MakeStNamFile = function(RecLogFile){
  tail(RecLogFile)
  StNam = unique(RecLogFile$Station.Name)
  # Use station name as the new file
  paste(StNam, "", sep="") # the name of the new file
  assign(paste(StNam, "", sep=""),Neaten(RecLogFile, StNam))
}

PlotSpatialGraph = function(Graph, ReceiverXY, v.color="skyblue", 
                            Title="Spatial Graph"){
  # Make list of station names
  Station = V(Graph)$name
  
  # Put the X,Y file in the right format (X,Y,Z, Station) and right order
  XYFile = ReceiverXY[ReceiverXY$Station==Station[1],]
  for (i in 2:length(Station)) {
    row = ReceiverXY[ReceiverXY$Station==Station[i],]
    XYFile = rbind(XYFile, row)
  } 
  
  Z = XYFile$X * 0 # Make Fake Depth Vector
  LocFile = XYFile[,c(7,8)]
  LocFile = cbind(LocFile, Z)
  
  # Now Plot Movegraph with spatial coordinates for vertices
  plot.igraph(Graph,
              layout=as.matrix(LocFile), 
              vertex.color="lightblue",
              vertex.size=V(Graph)$size,
              vertex.label.color="black",
              edge.color="gray",
              edge.width=E(Graph)$logweight,      
              vertex.label=V(Graph)$name, 
              vertex.label.cex = 1,
              edge.arrow.size=.5,
              edge.curved=TRUE,
              main=Title,
              add=TRUE, rescale=FALSE)
  
}
PlotSpatialGraphNoLabels = function(Graph, ReceiverXY, v.color="skyblue", 
                            Title="Spatial Graph"){
  # Make list of station names
  Station = V(Graph)$name
  
  # Put the X,Y file in the right format (X,Y,Z, Station) and right order
  XYFile = ReceiverXY[ReceiverXY$Station==Station[1],]
  for (i in 2:length(Station)) {
    row = ReceiverXY[ReceiverXY$Station==Station[i],]
    XYFile = rbind(XYFile, row)
  } 
  # Make blank labels
  nVerts = length(V(Graph))
  Labels = rep("",nVerts)
  Z = XYFile$X * 0 # Make Fake Depth Vector
  LocFile = XYFile[,c(7,8)]
  LocFile = cbind(LocFile, Z)
  
  # Now Plot Movegraph with spatial coordinates for vertices
  plot.igraph(Graph,
              layout=as.matrix(LocFile), 
              vertex.label.color="black",
              edge.color="gray",
              edge.width=E(Graph)$logweight,      
              vertex.label=Labels, 
              vertex.label.cex = 0,
              edge.arrow.size=.5,
              edge.curved=TRUE,
              main=Title)
  
}

PlotBipartiteGraph = function(BPGraph,Layout) {
  Type = bipartite.mapping(BPGraph)$type
  V(BPGraph)$color = ifelse(Type, "blue", "green") 
  plot.igraph(BPGraph,
            layout=Layout, 
            vertex.label.color="black",
            vertex.label.cex = .5,
            edge.color="black",
            edge.width=E(BPGraph)$logweight,      
            vertex.label=V(BPGraph)$name, 
            edge.arrow.size=.25,
            edge.curved=FALSE,
            main="Bipartite Graph: Tags=Green, Sites=Blue")
  }

TableOfShortDetects = function(FromTo, Cutoff=40){
  ShortDetect = subset(FromTo, as.numeric(FromTo$DetectTime) < Cutoff)
  table(From = as.character(ShortDetect$FromStation), 
        To = as.character(ShortDetect$Station.Name))
}

