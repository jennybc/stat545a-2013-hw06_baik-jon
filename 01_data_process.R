#####
# Data cleaning step.
# Some light data cleaning: Remove unwanted columns, make sure the columns
# are the right types.
#####


# Set up ------------------------------------------------------------------

# To help us work with dates in R.
if(!require(lubridate)) {
  install.packages("lubridate", repos="http://cran.rstudio.com")
  require(lubridate)
}

# For working with strings
if(!require(stringr)) {
  install.packages("stringr", repos="http://cran.rstudio.com")
  require(stringr)
}

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
# Set the time zone for our dates
vanTz <- "America/Vancouver"

class(ptDat$datetime)
# Test conversion to POSIX date object
ymd_hms(head(ptDat$datetime), tz=vanTz)
# Do it for the entire data set
ptDat$datetime <- ymd_hms(ptDat$datetime, tz=vanTz)
class(ptDat$datetime)

# The "date" column is also just character. Convert to date object
class(ptDat$date)
# Test conversion
ymd(head(ptDat$date), tz=vanTz)
# Do it for the entire data set
ptDat$date <- ymd(ptDat$date, tz=vanTz)
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


# Fix the factor levels
ptDat$offence_denorm <- factor(ptDat$offence_denorm,
                               levels=names(sort(table(ptDat$offence_denorm),
                                                 decreasing=FALSE)))
ptDat$make_denorm <- factor(ptDat$make_denorm,
                            levels=names(sort(table(ptDat$make_denorm),
                                              decreasing=FALSE)))

# Some very rare appearances. Let us make a new category that groups makes of cars
# that appear 10 or less times
summary(ptDat$make_denorm)

tab.make <- table(ptDat$make_denorm)

make2 <- factor(ptDat$make_denorm,
                levels=c("Other",
                         names(tab.make)[-which(tab.make <= 10)]))

summary(make2)
make2[is.na(make2)] <- "Other"
summary(make2)

# Add to data frame
ptDat$make_denorm2 <- make2
rm(make2)
rm(tab.make)

# Add "Year", "Month", "Day", "Day of Week", "Hour" variables to our data set
ptDat$year <- year(ptDat$date)
ptDat$month <- month(ptDat$date)
ptDat$day <- day(ptDat$date)
ptDat$wday <- wday(ptDat$date, label=TRUE, abbr=FALSE)
ptDat$hour <- hour(ptDat$datetime)

# Add Holidays, use reference http://www.labour.gov.bc.ca/esb/facshts/stats.htm
# Get the years of our data
ptYears <- unique(ptDat$year)

# New years, 01-01
holiday1 <- ymd(paste0(ptYears,"0101"))

# Good Friday
# I found out that this holiday is based on moon phases. This is a hard holiday
# to determine programmatically

# Can use the timeDate package
# holiday2 <- GoodFriday(ptYears)
# holiday2 <- ymd(as.character(holiday2))

# Instead of using an external package, I will just hard code it.
(holiday2 <- ymd(sprintf("%s%s%s",
                         ptYears,
                         c("04", "03", "04", "04", "03"),
                         c("09", "25", "14", "06", "21"))))

# Victoria Day
# Monday preceding May 25
VictoriaDay <- function(year) {
  require(lubridate)
  
  d <- ymd(paste0(year,"0524"))
  
  for(i in 1:length(d)) {
    while(wday(d[i])!=2) {
      d[i] <- d[i] - days(1)
    }
  }
  
  return(d)
}
holiday3 <- VictoriaDay(ptYears)

# Canada Day
holiday4 <- ymd(paste0(ptYears, "0701"))
# The stat holiday will be on Monday if Canada Day is on a Sunday, according to 
# the website
holiday4[wday(holiday4)==1] <- holiday4[wday(holiday4)==1] + days(1)

# BC Day, first Monday of August
holiday5 <- ymd(paste0(ptYears, "0801"))
for(i in 1:length(holiday5)) {
  while(wday(holiday5[i]) != 2) {
    holiday5[i] <- holiday5[i] + days(1)
  }
}

# Labour day
# First Monday of September
holiday6 <- ymd(paste0(ptYears, "0901"))
for(i in 1:length(holiday6)) {
  while(wday(holiday6[i]) != 2) {
    holiday6[i] <- holiday6[i] + days(1)
  }
}

# Thanksgiving
# We need to egt the second Monday of October
holiday7 <- ymd(paste0(ptYears, "1001"))
for(i in 1:length(holiday7)) {
  if(wday(holiday7[i])==2) {
    holiday7[i] <- holiday7[i] + weeks(1)
  } else {
    while(wday(holiday7[i]) != 2) {
      holiday7[i] <- holiday7[i] + days(1)
      if(wday(holiday7[i])==2) holiday7[i] <- holiday7[i] + weeks(1)
    }
  }
}

# Remembrance day, 11-11
holiday8 <- ymd(paste0(ptYears, "1111"))


# Christmas, 12-25
holiday9 <- ymd(paste0(ptYears, "1225"))

# Change time zone

tz(holiday1) <- vanTz
tz(holiday2) <- vanTz
tz(holiday3) <- vanTz
tz(holiday4) <- vanTz
tz(holiday5) <- vanTz
tz(holiday6) <- vanTz
tz(holiday7) <- vanTz
tz(holiday8) <- vanTz
tz(holiday9) <- vanTz

# Holidays
holidays <- c(holiday1, holiday2, holiday3, holiday4, holiday5, 
              holiday6, holiday7, holiday8, holiday9)
hour(holidays) <- 0

# Get the parking tickets data from the holidays
ptDat$holiday <- FALSE
ptDat$holiday[ptDat$date %in% holidays] <- TRUE

ptDat$holiday_name <- NA
ptDat$holiday_name[ptDat$date %in% holiday1] <- "New Years"
ptDat$holiday_name[ptDat$date %in% holiday2] <- "Good Friday"
ptDat$holiday_name[ptDat$date %in% holiday3] <- "Victoria Day"
ptDat$holiday_name[ptDat$date %in% holiday4] <- "Canada Day"
ptDat$holiday_name[ptDat$date %in% holiday5] <- "B.C. Day"
ptDat$holiday_name[ptDat$date %in% holiday6] <- "Labour Day"
ptDat$holiday_name[ptDat$date %in% holiday7] <- "Thanksgiving"
ptDat$holiday_name[ptDat$date %in% holiday8] <- "Remembrance Day"
ptDat$holiday_name[ptDat$date %in% holiday9] <- "Christmas"
ptDat$holiday_name <- factor(ptDat$holiday_name,
                             levels=c("New Years", "Good Friday",
                                      "Victoria Day", "Canada Day",
                                      "B.C. Day", "Labour Day",
                                      "Thanksgiving", "Remembrance Day",
                                      "Christmas"))

# Our "cleaned" data set.
names(ptDat)

# Save it! Save it as a csv file and a rds file.
dir.create("data_02_clean")
saveRDS(ptDat, "data_02_clean/parkingtickets_clean.rds")
write.csv(ptDat, "data_02_clean/parkingtickets_clean.csv", row.names=FALSE)

# OK! Now lets do some exploring (in the next script)
