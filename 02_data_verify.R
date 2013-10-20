# We downloaded the data as a MYSQL dump.
# Since we didn't want to install MYSQL just for the project, we decided to convert
# the dump into a SQLite data base.
# SQLite does not require a separate installation, and the drivers can be installed
# in R with the RSQLite package.

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

dbDisconnect(con)