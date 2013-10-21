# Assumes your wd is in the root of the project
unique_address <- readRDS("data_03_maps/unique_addresses.rds")
length(unique_address)
str(unique_address)

# For geocodes
if(!require(ggmap)) {
  install.packages("ggmap", repos="http://cran.rstudio.com")
  require(ggmap)
}

# You can only run 2500 queries a day from GOOGLE's API!
# DAY 1!
geo_address1 <- geocode(location=unique_address[1:2500],
                        override_limit=TRUE)

saveRDS(geo_address1, "geo1.rds")

# DAY 2!
geo_address2 <- geocode(location=unique_address[2501:5000],
                        override_limit=TRUE)

saveRDS(geo_address2, "geo2.rds")

# DAY 3!
geo_address3 <- geocode(location=unique_address[5001:7500],
                        override_limit=TRUE)

saveRDS(geo_address3, "geo3.rds")

# DAY 4!
geo_address4 <- geocode(location=unique_address[7501:10000],
                        override_limit=TRUE)

saveRDS(geo_address4, "geo4.rds")

# DAY 5!!
geo_address5 <- geocode(location=unique_address[10001:length(unique_address)],
                        override_limit=TRUE)

saveRDS(geo_address5, "geo5.rds")

# Done

geo_address <- rbind(geo_address1,
                     geo_address2,
                     geo_address3,
                     geo_address4,
                     geo_address5)

saveRDS(geo_address, "geo_address_final.rds")