
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

# For working with interactive maps
if(!require(googleVis)) {
  install.packages("googleVis", repos="http://cran.rstudio.com/")
  require(googleVis)
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


# TESTING -----------------------------------------------------------------

# Test with 1000
geoTst <- geo[1:1000,]
sum(!geoTst$address %in% ptDat$address)

# Merge back to pt data
ptGeo <- merge(ptDat, geoTst, sort=FALSE)
# Drop all non valid entries
ptGeo <- subset(ptGeo, subset=!is.na(lon)) 
dim(ptGeo)

# Download the map
# map_van <- get_map(c(lon=-123.1000, lat=49.2500), zoom=11, maptype="watercolor")
van_coord <- c(lon=-123.1000, lat=49.2500)
map_van <- get_map(van_coord, source="cloudmade", maptype=15434,
                   api_key="81abbf2fd13e4ee489477503d0e07495",
                   zoom=12)

# Test
# ggmap(map_van)

# Plot points and 2d density
ggmap(map_van) +
  geom_point(aes(x=lon, y=lat, col=offence_denorm),
             data=ptGeo) +
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
dt_coord <- c(lon=-123.1211, lat=49.2842)
map_dt <- get_map(dt_coord, zoom=14,  source="cloudmade", maptype=15434,
                  api_key="81abbf2fd13e4ee489477503d0e07495",)
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


# Now with all data -------------------------------------------------------

# Test with 1000
sum(!geo$address %in% ptDat$address)

# Merge back to pt data
ptGeo <- merge(ptDat, geo, sort=FALSE)
dim(ptGeo)

# How many non entries do we have?
# dim(subset(ptGeo, subset=is.na(lon)) )

# Save
write.csv(ptGeo, "data_03_maps/geocoded_parkingtickets.csv", row.names=FALSE)
saveRDS(ptGeo, "data_03_maps/geocoded_parkingtickets.rds")

# googleVis ---------------------------------------------------------------

# Example
# Hurricane Andrew (1992) storm track with Google Maps
# data(Andrew)
# head(Andrew)
# AndrewMap <- gvisMap(Andrew, "LatLong" , "Tip", 
#                      options=list(showTip=TRUE, showLine=TRUE, enableScrollWheel=TRUE,
#                                   mapType='terrain', useMapTypeControl=TRUE))
# plot(AndrewMap)

# My turn
topLoc <- ddply(ptGeo, ~address, summarize,
                numTickets=length(address),
                latLong=paste0(lat,":",lon)[1],
                address=address[1])
# Sort
topLoc <- arrange(topLoc, desc(numTickets))
# Get tool tip
topLoc$tip <- paste0("Rank: ", 1:nrow(topLoc),
                     "<BR>Address: ", topLoc$address,
                     "<BR>Number of tickets: ", topLoc$numTickets)

# Save
write.csv(topLoc, "data_03_maps/topParkingLocations.csv", row.names=FALSE)
saveRDS(topLoc, "data_03_maps/topParkingLocations.rds")

# Try it out
VanMap <-gvisMap(head(topLoc, n=25), "latLong", "tip",
                 options=list(showTip=TRUE, showLine=FALSE, enableScrollWheel=TRUE,
                              mapType='hybrid', useMapTypeControl=TRUE))

# plot(VanMap)
# print(VanMap, "chart", file="11_top25.html")