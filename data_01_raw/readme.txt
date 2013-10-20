Files:
  parkingtickets.sql.gz
    Compressed MYSQL data base dump of parking tickets data (see below for more info)
  
  parkingtickets.rds
    Data frame of table containing parking tickets information (~1.6 million rows)

  parkingtickets.csv (not included)
    The table of interest as a CSV file (~240 MB, not included due to github limits)
    This file can be downloaded from my dropbox: https://dl.dropboxusercontent.com/u/14072013/stat545a-hw06_largeFiles/parkingtickets.csv

---

Original data source: 
  http://www.vancouversun.com/parking/basic-search.html

Description (excerpt from site):
  This database contains information on all 1.6 million parking tickets issued in the City 
of Vancouver between Jan. 1, 2004 and Sept. 25, 2008. You can use this database to find 
out how many tickets a particular vehicle has received or to get an idea what your 
chances of getting caught for illegal parking are on any street in the city. To search 
the database, type in a license plate number to see a list of all tickets issued to that 
vehicle or type in a street address range to see all tickets issued on those city blocks. 

Please note: This database only includes municipal parking offences, such as expired 
meters, stopping in no-stopping zones or parking in a residential spot without a 
permit. Fines received in off-street parking lots -- whether owned by the city or a 
private company -- are not included.

---

MYSQL dump of data set from:
  http://www.davidgrant.ca/vancouver_sun_parking_tickets_website_screen_scraper

Description (excerpt from site):
  When the Vancouver Sun came out with their Vancouver parking tickets database I 
immediately had some burning questions, like, did the meter maids work on holidays? 
Do the work less in the evening than during the day? I found it difficult to answer 
these questions using their interface, so I decided to screen scrape all 1.6 million 
parking tickets in to my own MySQL database. This was a bit challenging as they made 
it difficult to screen scrape the data but eventually it could be done simply by 
first getting an AppKey, a hidden value inside the HTML source and then doing queries
using that AppKey as a parameter. It took about a week to get all 1.6 million tickets 
downloaded. By using Django, it was easy to get them in to a database and view the 
results. Initially I just put all the data in to one table, then later I decided to 
normalize the data a bit which was interesting as I decided to do that in pure SQL 
which I hadn't done before. I did the scraping itself using a combination of 
BeautifulSoup, lxml, and mechanize.

github link to code for scraping parking ticket data:
  https://github.com/dgrant/vancouver-parking-tickets

---

Comments:
  I installed MYSQL to access the MYSQL data base dump. I exported the table of interest
as a csv file, resulting in a ~240 MB file (not pushed to github). I read this as a
data frame into R, and then saved it as a binary RDS file (~30 MB).