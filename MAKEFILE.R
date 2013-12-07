#####
# IMPORTANT
#####
# Quick make?
# Some of the intermediate files takes a LONG time to process
# (e.g. 15 minutes)
# Do you want to leave these files?
#############################################################
quick <- TRUE # quick <- FALSE  will delete all intermediate 
              #                 files. Will take a LONG time.
#############################################################

# The make file

# The outputs
outputs <- c(list.files("data_02_clean", full.names = TRUE),
             list.files("figures", full.names = TRUE))
# data_03_maps is also raw data!
if(quick) {
  retainForQuickRun <- c("data_02_clean/ptDatPlateSum.rds",
                         "data_02_clean/ptDatPlateSum.csv",
                         "data_02_clean/ptDatPlateSumMake.csv",
                         "data_02_clean/ptDatPlateSumMake.rds")
  outputs <- outputs[!(outputs %in% retainForQuickRun)]
}

# Remove files
file.remove(outputs)

# NOTE: THIS MAY TAKE A LONG TIME IF quick==FALSE !!!
# YOU HAVE BEEN WARNED!!!
source("01_data_process.R")
source("02_data_explore.R")
# PLOTTING MAPS!
# THIS FILE ALSO TAKES A LONG TIME TO RUN!
source("03_plot_maps.R")

# Knit the html file
knitr::knit2html(input="report/stat545a-2013-hw06_baik-jon.rmd", 
                 output="report/stat545a-2013-hw06_baik-jon.html",
                 stylesheet="css/jasonm23-markdown-css-themes/markdown7.css")

# Open the report locally
browseURL(url="report/stat545a-2013-hw06_baik-jon.html")