#####
# Data processing step.
# We will be doing the data aggregation steps in this script.
#####


# Set up ------------------------------------------------------------------

# To work with dates in R
# install.packages("lubridate")
library(lubridate)

# Read in data and verify -------------------------------------------------

# Check the data files
dir('data_01_raw')

# Read in the parking ticket csv data that we dumped from the MYSQL data base
# ptDat <- read.csv("data_01_raw/parkingtickets.csv", header=TRUE,
#                   stringsAsFactors=FALSE)

# Save it as an rds file for easy reading
# saveRDS(ptDat, "data_01_raw/parkingtickets.rds")

# Read in the data
ptDat <- readRDS("data_01_raw/parkingtickets.rds")

# Verify the data. We know it should have ~1.6 million rows
dim(ptDat)
names(ptDat)
str(ptDat)

# Fix up the data set -----------------------------------------------------

# Some minor things we have to do to have the data nice in R

# The last column seems to be all the same
unique(ptDat$fine)
ptDat <- subset(ptDat, select=-fine)
dim(ptDat)
names(ptDat)

# The first column seems to be the row number
identical(c(1:nrow(ptDat)), ptDat$id) # This returns TRUE
ptDat <- subset(ptDat, select=-id)
dim(ptDat)
names(ptDat)

# Now some columns should be read as dates! Let us convert to R's date objects
class(ptDat$datetime)
# Test conversion to POSIX date object
ymd_hms(head(ptDat$datetime), tz="America/Vancouver")
# Do it for the entire data set
ptDat$datetime <- ymd_hms(ptDat$datetime, tz="America/Vancouver")
class(ptDat$datetime)

# The "date" column is also just character. Convert to date object
class(ptDat$date)
# Test conversion
ymd(head(ptDat$date), tz="America/Vancouver")
# Do it for the entire data set
ptDat$date <- ymd(ptDat$date, tz="America/Vancouver")
class(ptDat$date)

# Leave the time as a character column.
# We may change it to a lubridate time object later for the data analysis.

# Check out the make_denorm column
unique(ptDat$make_denorm)
# This seems like it should be a factor
ptDat$make_denorm <- factor(ptDat$make_denorm)
summary(ptDat$make_denorm)
levels(ptDat$make_denorm)

# Check out the possible offences
unique(ptDat$offence_denorm)
# This should be a factor, too!
ptDat$offence_denorm <- factor(ptDat$offence_denorm)
summary(ptDat$offence_denorm)
levels(ptDat$offence_denorm)

# What is record id? make_id? offence_id?
# Seems like the primary keys of different tables when the data was in a MYSQL
# data base
summary(ptDat$record_id)
summary(ptDat$make_id)
summary(ptDat$offence_id)
# These can all be dropped
ptDat <- subset(ptDat, select=-c(record_id, make_id, offence_id))

# What is details?
summary(ptDat$details)
unique(ptDat$detailsm, na.rm=TRUE)
# Well, we can drop this column as well. There is nothing of interest!
ptDat <- subset(ptDat, select=-details)

# Our "cleaned" data set.
names(ptDat)

# Save it! Save it as a csv file and a rds file.
dir.
saveRDS(ptDat, "data_02_clean/parkingtickets_clean.rds")
write.csv(ptDat, "data_02_clean/parkingtickets_clean.csv", row.names=FALSE)

# OK! Now lets do some data munging

# Data munging begins.. ---------------------------------------------------