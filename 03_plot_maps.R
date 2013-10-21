
# Set up! -----------------------------------------------------------------

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

# For working with dates
if(!require(stringr)) {
  install.packages("stringr", repos="http://cran.rstudio.com/")
  require(stringr)
}

# Map Time! ---------------------------------------------------------------

# Load parking ticket data
ptDat <- readRDS("data_02_clean/parkingtickets_clean.rds")

# Load geodata for the addresses
# FROM http://www.gpsvisualizer.com/geocoder/
geo <- read.csv("data_03_maps/geocoded_bing.csv", stringsAsFactors=TRUE)
geo <- subset(geo, select=c("latitude", "longitude", "name"))
names(geo) <- c("lat", "lon", "address")

geo$address <- str_replace(geo$address, pattern=", Vancouver, BC, Canada", "")

# Test with 1000
geoTst <- geo[1:1000,]
sum(!geoTst$address %in% ptDat$address)

# Merge back to pt data
ptDat2 <- merge(ptDat, geoTst, sort=FALSE)
# Drop all non valid entries
ptDat2 <- subset(ptDat2, subset=!is.na(lon)) 
dim(ptDat2)

# Download the map
# map_van <- get_map(c(lon=-123.1000, lat=49.2500), zoom=11, maptype="watercolor")
map_van <- get_map(c(lon=-123.1000, lat=49.2500), zoom=11, maptype="1")

# Test
ggmap(map_van)

# Plot points and 2d density
ggmap(map_van) +
  geom_point(aes(x=lon, y=lat, col=offence_denorm),
             data=ptDat2) +
  geom_density2d(aes(x=lon, y=lat), data=ptDat2)

# How about a hexbin plot
ggmap(map_van) +
  geom_hex(aes(x=lon, y=lat),
             data=ptDat2, alpha=0.7, bins=100) +
  scale_fill_gradient(low="gray80", high="red")


# Bubble plot!
# First, sum up the number of points per unique address
ptTmpBubble1 <- ddply(ptDat2, ~address+lon+lat, summarize,
                      total_tickets=length(offence_denorm))

# Attempt 1
ggmap(map_van) +
  geom_point(aes(x=lon, y=lat, size=sqrt(total_tickets/pi),
                 colour=sqrt(total_tickets/pi)), 
             alpha=0.5,
             data=ptTmpBubble1) +
  scale_size_continuous(range=c(1,10), guide="none")

# Try focusing on Downtown core
map_dt <- get_map(c(lon=-123.1211, lat=49.2842), zoom=14, maptype='roadmap')
ggmap(map_dt) +
  geom_point(aes(x=lon, y=lat, size=sqrt(total_tickets/pi),
                 colour=sqrt(total_tickets/pi)), alpha=0.5,
             data=ptTmpBubble1) +
  scale_size_continuous(range=c(1,10), guide="none")


# Make a floating pie chart thingy?
ptTmpBubble2 <- ddply(ptDat2, ~address+lon+lat, summarize,
                      numOffences=table(offence_denorm),
                      offence=names(table(offence_denorm)))


ggplot(aes(x=x,y=y)) + 
  geom_point(aes(size=z)) + 
  stat_spoke(aes(angle=r*2*pi, radius=3*z))