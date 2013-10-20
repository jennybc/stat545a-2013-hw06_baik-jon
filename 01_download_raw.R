#####
# Running this script is optional.
# Since github does not allow file larger than 100 MB, I decided to add these larger
# files to my dropbox. 
# This function allows the user to download all the data that I started with from
# my dropbox.
#####

# Function for downloading files from Dropbox
# Adapted from http://thebiobucket.blogspot.ca/2013/04/download-files-from-dropbox.html
# This function is specialized to download my raw data
dl_from_dropbox <- function(x, key, toFolder) {
  require(RCurl)
  bin <- getBinaryURL(paste0("https://dl.dropboxusercontent.com/u/", key, "/raw_data/", x),
                      ssl.verifypeer = FALSE)
  
  if(!missing(toFolder)) setwd(toFolder)
  
  con <- file(x, open = "wb")
  writeBin(bin, con)
  close(con)
  message(noquote(paste(x, "read into", getwd())))
}

# Run this to create a folder called "raw_data"
# First set working directory!!
dir.create("raw_data")

# Now download the raw data!

# The readme, ~4 KB
dl_from_dropbox("readme.txt", "14072013", "raw_data/")

# MYSQL data base dump, ~241 MB
dl_from_dropbox("parkingtickets.sql", "14072013", "raw_data/")

# SQLite data base, ~188 MB
dl_from_dropbox("parkingtickets.sqlite", "14072013", "raw_data/") 

# Script to convert MYSQL data base dump to SQLite data base, ~2KB
dl_from_dropbox("mysql2sqlite.sh", "14072013", "raw_data/")