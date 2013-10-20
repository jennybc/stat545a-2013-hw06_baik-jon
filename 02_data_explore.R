#####
# We need to get an idea of the data before we continue. This script will not
# be automatically run, as this is for myself, and not for the report.
# This script is for me to peer into the data and explore some ideas, as well as
# formulate hypotheses about the data. The report will contain the "best" or
# most interesting ideas, probably stemming from exploring in this script.
# In short, this is my test file!
#####


# Set up ------------------------------------------------------------------

# For working with dates
library(lubridate)

# For plotting pretty plots
library(ggplot2)

# For data aggregation
library(plyr)

# Read in the data
ptDat <- readRDS("data_02_clean/parkingtickets_clean.rds")
dim(ptDat)
str(ptDat)
names(ptDat)

# Explore the clean data --------------------------------------------------

names(ptDat)

# Easy Mode:

# 01
# Lets see the frequency of the offences
ggplot(data=ptDat) + 
  geom_bar(aes(x=offence_denorm))

# Well, that's ugly. Let's try flipping the axes
ggplot(data=ptDat) +
  geom_bar(aes(x=offence_denorm)) +
  coord_flip()

# OK, it looks like in our data set, the most common ticket by far is "Expired Meter".
# Parking in a "No Stopping" area also has a LOT of tickets!

# 02
# Are drivers of certain car makes more prone to getting parking tickets?
# Do parking authorities target particular markes of cars?
ggplot(data=ptDat) + 
  geom_bar(aes(x=make_denorm)) + 
  coord_flip()

# Lets try the plot again
ggplot(data=ptDat) + 
  geom_bar(aes(x=make_denorm2)) + 
  coord_flip()

# 03
# Colour the above barplot by the offence?
# Lets try the plot again

# Lets try the plot again
ggplot(data=ptDat) + 
  geom_bar(aes(x=make_denorm2, fill=offence_denorm)) + 
  coord_flip()

# Try percentage?
ggplot(data=ptDat) + 
  geom_bar(aes(x=make_denorm2, fill=offence_denorm), position="fill") + 
  coord_flip()

# 04
# How has the number of tickets been per year in our data? Per month?
names(ptDat)
ptDatYear <- table(year(ptDat$date))
# Make into data frame for plotting
ptDatYear <- data.frame(ptDatYear)
names(ptDatYear) <- c("year", "freq")

# Plot bar chart
ggplot(data=ptDatYear) +
  geom_bar(aes(x=year, y=freq), stat="identity")
# Note that the data for 2008 goes from Jan 1 ~ Sept 25

# Now for month
ptDatMonth <- table(month(ptDat$date))
# Make into data frame for plotting
ptDatMonth <- data.frame(ptDatMonth)
names(ptDatMonth) <- c("month", "freq")

# Plot bar chart
ggplot(data=ptDatMonth) + 
  geom_bar(aes(x=month, y=freq), stat="identity")

# Try by year and month
ptDatYearMonth <- ddply(ptDat, ~year(date)+month(date),
                        freq=length(plate))