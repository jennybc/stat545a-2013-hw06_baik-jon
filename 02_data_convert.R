#####
# Running this script is optional.
# It requires that we have the raw data in the "raw_data" directory.
# To download the raw_data, please run 01_download_raw.R
#####

# We downloaded the data as a MYSQL dump.
# Since we didn't want to install MYSQL just for the project, we decided to convert
# the dump into a SQLite data base.
# SQLite does not require a separate installation, and the drivers can be installed
# in R with the RSQLite package.

# First, verify the data

# install.packages("RSQLite", dependencies=TRUE)
library(RSQLite)

# Check the data set
ticket.db <- "raw_data/parkingtickets.sqlite"

# Create the connection to the file
con <- dbConnect("SQLite", ticket.db)

# List all the tables in the data base
dbListTables(con)

# List of possible offences
offences <- dbGetQuery(con, "SELECT * FROM parkingtickets_offence")
# The actual parking ticket data
# This one takes a little longer... up to around 30 seconds on my machine
tickets <- dbGetQuery(con, "SELECT * FROM parkingtickets_ticket")

# Check the data
str(offences)
offences

str(tickets)
dim(tickets) # WOW, 1.5 million rows. This'll be fun.
summary(tickets)
head(tickets)

# Check out the street names
unique(tickets$street_name)

# Looks like the parkingtickets_ticket is the most important data set.

# Disconnect
dbDisconnect(con)

# Let us convert ALL the tables into data frames and save them.

# Create the connection to the file
con <- dbConnect("SQLite", ticket.db)

# Get all the tables in the data base
(tables <- dbListTables(con))

# Create the directory
dir.create("data")

# Now go through all the tables and save them
for(i in 1:length(tables)) {
  # Read the data from data base
  tmp <- dbGetQuery(con, paste("SELECT * FROM", tables[i]))
  # Some of the data tables are empty! Only save if non-empty
  if(nrow(tmp)>0) {
    # Save the data as csv, to be read by programs outside of R
    write.csv(tmp, paste0("data/", tables[i], ".csv"), row.names=FALSE)
    # Save the data as an R binary file (rds)
    saveRDS(tmp, paste0("data/", tables[i], ".rds"))
  }
  # Lets check the progress
  print(sprintf("Finished %s of %s", i, length(tables)))
}

# Some of these are not useful
# Note that the "parkingtickets_ticket.csv, the largest data set, is too large to push
# to github (filesize 207 MB)!