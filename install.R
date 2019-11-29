install.packages("devtools")

# XTractomatic - match locations in time and space w/ model data via ERDDAP
#devtools::install_github("rmendels/xtractomatic")

# VTrack and ATT - Tools for Telemetry Analysis
devtools::install_github("rossdwyer/VTrack")
devtools::install_github("vinayudyawer/ATT")

# GLATOS - acoustic telemetry package that does filtering, vis, array simulation, etc.
install.packages('remotes')
library(remotes)
install_url("https://gitlab.oceantrack.org/GreatLakes/glatos/repository/master/archive.zip",
            build_opts = c("--no-resave-data", "--no-manual"))

# Sensible Working Directory Manager
install.packages("here")
