
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