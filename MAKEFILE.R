# The make file

# The outputs
outputs <- c(dir("data_02_clean"),
             dir("figures"))
# data_03_maps is also raw data!

# Quick make?
# Some of the intermediate files takes a LONG time to process
# (e.g. 15 minutes)
# Do you want to leave these files?
quick <- TRUE
if(quick) {
  outputs <- outputs[!outputs %in% c("ptDatPlateSum.rds", "ptDatPlateSum.csv",
                                     "ptDatPlateSumMake.rds", "ptDatPlateSumMake.csv")]
}

# Remove files
file.remove(outputs)

# NOTE: THIS MAY TAKE A LONG TIME IF quick==FALSE !!!
source("01_filterReorder.R")
source("02_aggregatePlot.R")

