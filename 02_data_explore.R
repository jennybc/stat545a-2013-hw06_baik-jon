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
if(!require(lubridate)) {
  install.packages("lubridate", repos="http://cran.rstudio.com/")
  require(lubridate)
}

# For plotting pretty plots
if(!require(ggplot2)) {
  install.packages("ggplot2", repos="http://cran.rstudio.com/")
  require(ggplot2)
}

# For data aggregation
if(!require(plyr)) {
  install.packages("plyr", repos="http://cran.rstudio.com/")
  require(plyr)
}

# For plotting on maps!
if(!require(ggmap)) {
  install.packages("ggmap", repos="http://cran.rstudio.com/")
  require(ggmap)
}

# For text manipulation!
if(!require(stringr)) {
  install.packages("stringr", repos="http://cran.rstudio.com/")
  require(stringr)
}

# For plotting improvements!
if(!require(scales)) {
  install.packages("scales", repos="http://cran.rstudio.com/")
  require(scales)
}

# Read in the data
ptDat <- readRDS("data_02_clean/parkingtickets_clean.rds")
dim(ptDat)
str(ptDat)
names(ptDat)

# For saving image files
ggsave2 <- function(name, plot, width, height) {
  ggsave(filename=paste0("figures/", name, ".svg"), plot=plot,
         width=width, height=height)
  ggsave(filename=paste0("figures/", name, ".png"), plot=plot,
         width=width, height=height)
}

# Explore the clean data --------------------------------------------------

names(ptDat)
dir.create("figures")

# 01 - Frequency of offences ----------------------------------------------

# Lets see the frequency of the offences
# ggplot(data=ptDat) + 
#   geom_bar(aes(x=offence_denorm))

# Well, that was ugly. Let's try flipping the axes
gg1 <- ggplot(data=ptDat) +
  geom_bar(aes(x=offence_denorm)) +
  coord_flip() + 
  ylab("Count") +
  xlab("Offence")

# Save figures
ggsave2("01_offence-freq", gg1, 10, 5)

# OK, it looks like in our data set, the most common ticket by far is "Expired Meter".
# Parking in a "No Stopping" area also has a LOT of tickets!

# 02 - Make of cars -------------------------------------------------------

# Are drivers of certain car makes more prone to getting parking tickets?
# Do parking authorities target particular markes of cars?
# ggplot(data=ptDat) + 
#   geom_bar(aes(x=make_denorm)) + 
#   coord_flip()

# Lets try the plot again
gg2 <- ggplot(data=ptDat) + 
  geom_bar(aes(x=make_denorm2)) + 
  coord_flip() +
  ylab("Count") +
  xlab("Vehicle Make")

# Save figures
ggsave2("02_make-freq", gg2, 10, 10)

# 03 - Type of offences ---------------------------------------------------

# Colour the above barplot by the offence?
col <- rainbow(16)
col.index <- ifelse(seq(col) %% 2, 
                    seq(col), 
                    (seq(ceiling(length(col)/2), length.out=length(col)) %% length(col)) + 1)
mixed <- col[col.index]

# Lets try the plot again
gg3 <- ggplot(data=ptDat) + 
  geom_bar(aes(x=make_denorm2, fill=offence_denorm), 
           colour=alpha(colour="black", alpha=0.4)) + 
  coord_flip() + 
  scale_fill_hue("Offence", l=60) +
  ylab("Count") +
  xlab("Vehicle Make")

# Try percentage?
gg4 <- ggplot(data=ptDat) + 
  geom_bar(aes(x=make_denorm2, fill=offence_denorm), 
           colour=alpha(colour="black", alpha=0.4), position="fill") + 
  coord_flip() +
  scale_fill_hue("Offence", l=60) +
  ylab("Count") +
  xlab("Vehicle Make") +
  scale_y_continuous(labels = percent_format())

# Save
ggsave2("03_make-freq-colOffence", gg3, 10, 10)
ggsave2("03_make-perc-colOffence", gg4, 10, 10)

# 04 - By year? Month? ----------------------------------------------------

# How has the number of tickets been per year in our data? Per month?
names(ptDat)
ptDatYear <- ddply(ptDat, ~year, summarize, freq=length(year))

# Plot bar chart
gg5 <- ggplot(data=ptDatYear) +
  geom_bar(aes(x=as.factor(year), y=freq), stat="identity") +
  ylab("Count") +
  xlab("Year")
# Note that the data for 2008 goes from Jan 1 ~ Sept 25

# Save
ggsave2("04_year-totals", gg5, 5, 4)

# Now for month
ptDatMonth <- ddply(ptDat, ~month, summarize, freq=length(month))

# Plot bar chart
gg6 <- ggplot(data=ptDatMonth) + 
  geom_bar(aes(x=as.factor(month), y=freq), stat="identity") +
  ylab("Count") +
  xlab("Month")

# Save
ggsave2("04_month-totals", gg6, 6, 4)


# Need to find monthly MEANS instead, due to missing data!
ptDatMonthMean <- ddply(ptDat, ~year+month, summarize, 
                        sum=length(year)/length(unique(year)))
ptDatMonthMean <- ddply(ptDatMonthMean, ~month, summarize, 
                        mean=mean(sum))

# Mean tickets
gg7 <- ggplot(data=ptDatMonthMean) + 
  geom_bar(aes(x=as.factor(month), y=mean), stat="identity") +
  ylab("Mean Count") +
  xlab("Month")

# Save
ggsave2("04_month-avg", gg7, 6, 4)

# Try by year and month
ptDatYearMonth <- ddply(ptDat, ~year+month, summarize,
                        freq=length(year))
ptDatYearMonth$year_month <- 1:nrow(ptDatYearMonth)

# Plot bars
gg8 <- ggplot(data=ptDatYearMonth) +
  geom_bar(aes(x=as.factor(month), y=freq), stat="identity") +
  facet_wrap(~year) +
  ylab("Count") +
  xlab("Month")

# Save
ggsave2("04_year-month-total", gg8, 6, 4)

# Plot lines
gg9 <- ggplot(data=ptDatYearMonth) +
  geom_path(aes(x=year_month, y=freq), lwd=1.25) +
  xlab("Month") +
  ylab("Count") +
  scale_x_continuous(breaks=1:nrow(ptDatYearMonth),
                     labels=paste0(ptDatYearMonth$year, 
                                   sprintf("%02d", ptDatYearMonth$month))) +
  theme(axis.text.x=element_text(angle=45, vjust=1, hjust=1))

# Save
ggsave2("04_year-month-line", gg9, 10, 4)

# 05 - Tickets by day of the week? ----------------------------------------

# How about parking tickets by day of the week?
# Lets reverse the factor order first to make it look nice when we flip
ptDat$wday <- factor(ptDat$wday,
                     levels=rev(levels(ptDat$wday)))

gg10 <- ggplot(data=ptDat) +
  geom_bar(aes(x=wday)) +
#   coord_flip() + 
  ylab("Count") +
  xlab("Day of Week")

# Save
ggsave2("05_weekday-bar", gg10, 6, 4)

# By month?
gg11 <- ggplot(data=ptDat) + 
  geom_bar(aes(x=wday)) +
  facet_wrap(~month) +
  coord_flip() + 
  ylab("Count") +
  xlab("Day of Week")

# Save
ggsave2("05_weekday-bar-byMonth", gg11, 6, 6)

# # By year?
# ggplot(data=ptDat) + 
#   geom_bar(aes(x=wday)) +
#   facet_wrap(~year) + 
#   coord_flip()
# 
# # Year and month?
# ggplot(data=ptDat) + 
#   geom_bar(aes(x=wday)) +
#   facet_grid(year~month) +
#   coord_flip()


# 06 - Take a look at holidays --------------------------------------------

# Again, lets reverse the factor levels
ptDat$holiday_name <- factor(ptDat$holiday_name, 
                             levels=rev(levels(ptDat$holiday_name)))

# Parking tickets on vacations
# ggplot(data=subset(ptDat, subset=!is.na(holiday_name))) +
#   geom_bar(aes(x=holiday_name, y=..count..)) +
#   coord_flip()

# By year?
# ggplot(data=subset(ptDat, subset=!is.na(holiday_name))) +
#   geom_bar(aes(x=holiday_name, y=..count..)) +
#   facet_wrap(~year) +
#   coord_flip()

# What the? Where is New Years and Christmas?
ptDat[ptDat$month==1 & ptDat$day==1,]
ptDat[ptDat$month==12 & ptDat$day==25,]

# What days do the holidays land on?
table(ptDat$holiday_name, ptDat$wday)

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
ptDatMeanWeekday <- ddply(ptDat, ~wday, summarize, 
                          mean=length(date)/length(unique(date)))

# Looks like the old plot, eh?
ptDatMeanWeekday$wday <- factor(ptDatMeanWeekday$wday,
                                levels=rev(levels(ptDatMeanWeekday$wday)))

ggplot(data=ptDatMeanWeekday) +
  geom_bar(aes(x=wday, y=mean), stat='identity')

# 08 - How do holidays compare to overall means? --------------------------

# Do the same plot as above, but this time add lines for overall mean, weekday mean, 
# weekend mean
gg12 <- ggplot(data=subset(ptDat, subset=!is.na(holiday_name))) +
  geom_bar(aes(x=holiday_name, y=..count..)) +
  geom_hline(aes(yintercept=value, colour=type), 
             linetype="dashed", data=ptDatMeans) +
  scale_colour_manual(guide='legend',
                      values=c("black", "blue", "red"),
                      labels=c("Overall", "Weekday", "Weekend")) +
  facet_wrap(~year) + 
  ylim(0, 1100) +
  coord_flip()
# Since the legend isn't working properly,
# Black is Overall
# Blue is Weekday
# Red is Weekend

# Save
ggsave2("08_holiday-vs-avgs", gg12, 8, 5)

# Average monthly tickets (not really worth exploring, since we can get totals...)

# 09 - Worst offenders ----------------------------------------------------

# Do we have any repeat offenders?
ptDatPlateSum <- ddply(ptDat, ~plate, summarize,
                       sum=length(plate))

# This took a long time, let us save this one!
saveRDS(ptDatPlateSum, "data_02_clean/ptDatPlateSum.rds")
write.csv(ptDatPlateSum, "data_02_clean/ptDatPlateSum.csv")

dim(ptDatPlateSum)
head(ptDatPlateSum)

# Use hadley's sorting function
ptDatPlateSum <- arrange(ptDatPlateSum, desc(sum))
head(ptDatPlateSum)
# WOW! Who gets 1000 tickets??

# For plotting boxplots
ptDatPlateSum$all <- "All Plates"

# ggplot(data=ptDatPlateSum) +
#   geom_histogram(aes(x=sum), binwidth=1)

# ggplot(data=ptDatPlateSum) +
#   geom_boxplot(aes(x=all, y=sum))

# ggplot(data=ptDatPlateSum) +
#   geom_violin(aes(x=all, y=sum))

# Can we see what cars these people drive?
make_plate <- data.frame(make=ptDat$make_denorm, plate=ptDat$plate)
make_plate <- unique(make_plate)

ptDatPlateSum2 <- merge(x=ptDatPlateSum, y=make_plate, by="plate", all=TRUE, sort=FALSE)
head(ptDatPlateSum2)

# What the heck?
subset(ptDatPlateSum2, subset=plate=="INCMPT") 
head(subset(ptDatPlateSum2, subset=plate!="INCMPT"), n=100)
# Oh, that makes sense. For these other plates, different ticketing officers may record
# different car makes.

# Let us investigate the people with more than 100 parking tickets!
hiPlates <- subset(ptDatPlateSum, subset=sum>=100)$plate
subset(ptDatPlateSum2, subset=plate %in% hiPlates)

ptDatPlateBin50 <- cut(ptDatPlateSum$sum, breaks=seq(0, 1100, 50))
ptDatPlateBin50 <- factor(ptDatPlateBin50)
table(ptDatPlateBin50)

ptDatPlateBin <- cut(ptDatPlateSum$sum, breaks=c(0:19, seq(20, 50, 5), 
                                                 seq(100, 1100, 50)))
ptDatPlateBin <- factor(ptDatPlateBin)
table(ptDatPlateBin)

# Plot a histogram of those plates with <= 25 parking tickets
# This is how many percent of the data?
platePerc <- paste0(round(sum(ptDatPlateSum$sum <=25)/nrow(ptDatPlateSum), 5) * 100, "%")

gg13 <- ggplot(ptDatPlateSum) +
  geom_histogram(aes(x=sum), binwidth=1) +
  xlim(0,25) +
  annotate("text", x=20, y=4e+05, label=paste(platePerc, "of the data"))
# 0.9969815 or about 99.698% of the data

# Save
ggsave2("09_plate-totals", gg13, 6, 5)

# 10 - Time of offence ----------------------------------------------------

names(ptDat)

# Lets see if there are particular peak hours
ggplot(data=ptDat) +
  geom_bar(aes(x=as.factor(hour)))

# Re order factors for this plot
ptDat$offence_denorm <- factor(ptDat$offence_denorm,
                               levels=rev(levels(ptDat$offence_denorm)))
ptDat$wday <- factor(ptDat$wday,
                     levels=rev(levels(ptDat$wday)))

# Try colouring by type of offence
ggplot(data=ptDat) +
  geom_bar(aes(x=as.factor(hour), fill=offence_denorm))
# Ugh, hard to read

# Colour by day of week
ggplot(data=ptDat) +
  geom_bar(aes(x=as.factor(hour), fill=wday))

# How about we get the proportions
ggplot(data=ptDat) +
  geom_bar(aes(x=as.factor(hour), fill=wday), position="fill")

# Try facetting?
# Colour by day of week
ggplot(data=ptDat) +
  geom_bar(aes(x=as.factor(hour), fill=wday)) +
  facet_wrap(~month)

# Map Time! ---------------------------------------------------------------
tmp <- data.frame(address=unique(ptDat$address),
                  city="Vancouver",
                  province="BC",
                  country="Canada")
write.csv(tmp, "data_03_maps/unique_addresses.csv", row.names=FALSE)


# 01 - Testing ------------------------------------------------------------

length(unique(ptDat$address))
unique_address <- paste0(unique(ptDat$address), ", Vancouver, BC, Canada")
dir.create("data_03_maps")

# Save the addresses so we can download the geo-codes (takes a day!)
write.csv(unique_address, "data_03_maps/unique_addresses.txt", row.names=FALSE)
saveRDS(unique_address, "data_03_maps/unique_addresses.rds")

# Test with 100
geo_address <- geocode(head(unique_address, n=100))

# Merge back to pt data
geo_address <- cbind(address=unique(ptDat$address)[1:100], geo_address)
ptTmp <- ptDat
ptTmp <- merge(ptTmp, geo_address, sort=FALSE)
ptTmp <- subset(ptTmp, subset=!is.na(lon))
dim(ptTmp)

# Download the map
map_van <- get_map(c(lon=-123.1000, lat=49.2500), zoom=11, maptype='roadmap')

# Plot points
ggmap(map_van) +
  geom_point(aes(x=lon, y=lat, col=offence_denorm),
             data=ptTmp) +
  geom_density2d(aes(x=lon, y=lat), data=ptTmp)

# This is kind of bad, we are having overlapping points

# Bubble plot!
# First, sum up the number of points per unique address
ptTmpBubble1 <- ddply(ptTmp, ~address+lon+lat, summarize,
                      total_tickets=length(offence_denorm))

# Attempt 1
ggmap(map_van) +
  geom_point(aes(x=lon, y=lat, size=sqrt(total_tickets/pi)), alpha=0.5,
             data=ptTmpBubble1) +
  scale_size_continuous(range=c(1,10), guide="none")

# Try focusing on Downtown core
map_dt <- get_map(c(lon=-123.1211, lat=49.2842), zoom=14, maptype='roadmap')
ggmap(map_dt) +
  geom_point(aes(x=lon, y=lat, size=sqrt(total_tickets/pi)), alpha=0.5,
             data=ptTmpBubble1) +
  scale_size_continuous(range=c(1,10), guide="none")

ptTmpBubble2 <- ddply(ptTmp, ~address+lon+lat, summarize,
                      numOffences=table(offence_denorm),
                      offence=names(table(offence_denorm)))


ggplot(aes(x=x,y=y)) + 
  geom_point(aes(size=z)) + 
  stat_spoke(aes(angle=r*2*pi, radius=3*z))