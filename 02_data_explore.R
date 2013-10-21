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

# For calculating the day of Easter (Good Friday)
# library(timeDate)

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


# 01 - Frequency of offences ----------------------------------------------

# Lets see the frequency of the offences
ggplot(data=ptDat) + 
  geom_bar(aes(x=offence_denorm))

# Well, that's ugly. Let's try flipping the axes
ggplot(data=ptDat) +
  geom_bar(aes(x=offence_denorm)) +
  coord_flip()

# OK, it looks like in our data set, the most common ticket by far is "Expired Meter".
# Parking in a "No Stopping" area also has a LOT of tickets!


# 02 - Make of cars -------------------------------------------------------

# Are drivers of certain car makes more prone to getting parking tickets?
# Do parking authorities target particular markes of cars?
ggplot(data=ptDat) + 
  geom_bar(aes(x=make_denorm)) + 
  coord_flip()

# Lets try the plot again
ggplot(data=ptDat) + 
  geom_bar(aes(x=make_denorm2)) + 
  coord_flip()


# 03 - Type of offences ---------------------------------------------------

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



# 04 - By year? Month? ----------------------------------------------------

# How has the number of tickets been per year in our data? Per month?
names(ptDat)
ptDatYear <- ddply(ptDat, ~year, summarize, freq=length(year))

# Plot bar chart
ggplot(data=ptDatYear) +
  geom_bar(aes(x=as.factor(year), y=freq), stat="identity")
# Note that the data for 2008 goes from Jan 1 ~ Sept 25

# Now for month
ptDatMonth <- ddply(ptDat, ~month, summarize, freq=length(month))

# Plot bar chart
ggplot(data=ptDatMonth) + 
  geom_bar(aes(x=as.factor(month), y=freq), stat="identity")

# Try by year and month
ptDatYearMonth <- ddply(ptDat, ~year+month, summarize,
                        freq=length(year))

# Plot bars
ggplot(data=ptDatYearMonth) +
  geom_bar(aes(x=as.factor(month), y=freq), stat="identity") +
  facet_wrap(~year)
# Plot lines
ggplot(data=ptDatYearMonth) +
  geom_path(aes(x=month, y=freq)) +
  facet_wrap(~year)


# 05 - Tickets by day of the week? ----------------------------------------

# How about parking tickets by day of the week?
# Lets reverse the factor order first to make it look nice when we flip
ptDat$wday <- factor(ptDat$wday,
                     levels=rev(levels(ptDat$wday)))

ggplot(data=ptDat) +
  geom_bar(aes(x=wday)) +
  coord_flip()

# By month?
ggplot(data=ptDat) + 
  geom_bar(aes(x=wday)) +
  facet_wrap(~month) +
  coord_flip()

# By year?
ggplot(data=ptDat) + 
  geom_bar(aes(x=wday)) +
  facet_wrap(~year) + 
  coord_flip()

# Year and month?
ggplot(data=ptDat) + 
  geom_bar(aes(x=wday)) +
  facet_grid(year~month) +
  coord_flip()


# 06 - Take a look at holidays --------------------------------------------

# Again, lets reverse the factor levels
ptDat$holiday_name <- factor(ptDat$holiday_name, 
                             levels=rev(levels(ptDat$holiday_name)))

ggplot(data=subset(ptDat, subset=!is.na(holiday_name))) +
  geom_bar(aes(x=holiday_name, y=..count..)) +
  facet_wrap(~year) +
  coord_flip()

# What the? Where is New Years and Christmas?
ptDat[ptDat$month==1 & ptDat$day==1,]
ptDat[ptDat$month==12 & ptDat$day==25,]



# 07 - Average tickets per day? Per month? --------------------------------

# What is the average number of tickets per day?
# First calculate the number of tickets per day
ptDatMeanDay <- ddply(ptDat, ~date, summarize, daily_sum=length(date))

# Daily mean
ptDatMeans <- data.frame(type=c("overall_mean",
                                "weekday_mean",
                                "weekend_mean"), value=0, stringsAsFactors=TRUE)
ptDatMeans$value[1] <- mean(ptDatMeanDay$daily_sum)

ptDatMeans$value[2] <- mean(ptDatMeanDay$daily_sum[wday(ptDatMeanDay$date, 
                                                        label=TRUE) %in% 
                                                     c("Sun","Sat")])
ptDatMeans$value[3] <- mean(ptDatMeanDay$daily_sum[!wday(ptDatMeanDay$date, 
                                                         label=TRUE) %in% 
                                                     c("Sun","Sat")])

# Weekday means
ptDatMeanWeekday <- ddply(ptDat, ~wday, summarize, mean=length(date)/length(unique(date)))

# Do the same plot as above, but this time add lines for overall mean, weekday mean, 
# weekend mean
ggplot(data=subset(ptDat, subset=!is.na(holiday_name))) +
  geom_bar(aes(x=holiday_name, y=..count..)) +
  geom_hline(aes(yintercept=value, colour=type), 
             linetype="dashed", data=ptDatMeans) +
  scale_colour_manual(values=c("black", "blue", "red"),
                      labels=c("Overall", "Weekday", "Weekend")) +
  facet_wrap(~year) +
  ylim(0, 1100) +
  coord_flip()
