
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

# For working with interactive maps
if(!require(scales)) {
  install.packages("scales", repos="http://cran.rstudio.com/")
  require(scales)
}

# For saving image files
ggsave2 <- function(name, plot, width, height) {
  ggsave(filename=paste0("figures/", name, ".svg"), plot=plot,
         width=width, height=height)
  ggsave(filename=paste0("figures/", name, ".png"), plot=plot,
         width=width, height=height)
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
# 
# # Test with 1000
# geoTst <- geo[1:1000,]
# sum(!geoTst$address %in% ptDat$address)
# 
# # Merge back to pt data
# ptGeo <- merge(ptDat, geoTst, sort=FALSE)
# # Drop all non valid entries
# ptGeo <- subset(ptGeo, subset=!is.na(lon)) 
# dim(ptGeo)

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


# First Plot --------------------------------------------------------------

# Check the factor order for offence_denorm
if(levels(ptGeo$offence_denorm)[1]!="Expired Meter")
  ptGeo$offence_denorm <- factor(ptGeo$offence_denorm,
                                 levels=rev(levels(ptGeo$offence_denorm)))

# Download the map
# map_van <- get_map(c(lon=-123.1000, lat=49.2500), zoom=11, maptype="watercolor")
van_coord <- c(lon=-123.1100, lat=49.2500)
map_van <- get_map(van_coord, source="cloudmade", maptype=15434,
                   api_key="81abbf2fd13e4ee489477503d0e07495",
                   zoom=12)
# Test
# ggmap(map_van)

# Plot the density
ggm00 <- ggmap(map_van) +
  geom_hex(aes(x=lon, y=lat), bins=120, alpha=0.9, colour=alpha('white',0.1),
           data=ptGeo) +
  ylab("Latitude") +
  xlab("Longitude") +
  scale_fill_gradient2("Frequency", midpoint=12500,
                      low="black", mid="orangered3", high="orangered")

ggsave2("maps_ptVan", ggm00, 10, 10)

# First, to reduce overplotting, do not plot over any of the points
ptGeoTmp1 <- ddply(ptGeo, ~address+offence_denorm, summarize,
                   lon=unique(lon),
                   lat=unique(lat))

# Plot points
ggm01 <- ggmap(map_van) +
  geom_point(aes(x=lon, y=lat, col=offence_denorm),
             data=ptGeoTmp1) +
  facet_wrap(~offence_denorm) +
  ylab("Latitude") +
  xlab("Longitude") + 
  scale_color_discrete("Offence")

ggsave2("maps_byOffence", ggm01, 17, 13)

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
# VanMap <-gvisMap(head(topLoc, n=25), "latLong", "tip",
#                  options=list(showTip=TRUE, showLine=FALSE, enableScrollWheel=TRUE,
#                               mapType='hybrid', useMapTypeControl=TRUE))

# plot(VanMap)
# print(VanMap, "chart", file="11_top25.html")