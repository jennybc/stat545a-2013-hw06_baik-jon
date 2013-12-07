## Parking Ticket Data Analysis for Vancouver, B.C.

#### Helpful links

The [report published to RPubs](http://rpubs.com/jonnybaik/stat545a-2013-hw06_baik-jon)

The [report as appears in github repo](http://htmlpreview.github.com/?https://github.com/jonnybaik/stat545a-2013-hw06_baik-jon/blob/master/report/stat545a-2013-hw06_baik-jon.html) *this does not seem to work ... possibly because the HTML file is too large? this strategy certainly works elsewhere*

#### stat545a-2013-hw06_baik-jon


##### How to run:

Download a copy of this Github project.
Run [`MAKEFILE.R`](MAKEFILE.R) in R or Rscript to run. This will:
 * Delete intermediate data sets and all figures
 * Run the data cleaning and data aggregation, creating some intermediate data sets (in [data_02_clean](data_02_clean/) and [data_03_maps](data_03_maps))
 * Generate figures for the report (in the [figures](figures/) folder)
 * Stitch together an HTML report (in the [report](report/) folder)
 * Open the HTML report

**NOTE**: There is a large data processing step that takes quite a while (~20 to 30 minutes on my machine). 
If you want to skip this step, there is a setting in the `MAKEFILE.R` file - set `quick <- TRUE`. 
This will prevent one of the intermediate data sets from being deleted. This takes long to run because we 
are running the `ddply` function on a data set with over 1.6 million rows over several variables with many categories. You have been warned!

##### Data source

Original data source: [Vancouver Sun, Parking Ticket Database](http://www.vancouversun.com/parking/basic-search.html)

MYSQL data dump of entire database downloaded from: [Vancouver Sun Parking Tickets Website Screen Scraper](http://www.davidgrant.ca/vancouver_sun_parking_tickets_website_screen_scraper)

For those of you who do not have MYSQL or do not want to install it, a CSV version of table from the MYSQL data dump is [available via my Dropbox](https://dl.dropboxusercontent.com/u/14072013/stat545a-hw06_largeFiles/parkingtickets.csv).

##### Other notes

The parking tickets data set contained addresses for each parking ticket. In order to plot data onto maps,
I needed to look up the latitudes and longitudes of the addresses in the data. In the code, I extract the
unique addresses in the data set to make the [unique_addresses.csv](data_03_maps/unique_addresses.csv).
I provide code to look up the long/lat coordinates for these addresses using functions in the `ggmap` package,
but Google Map's API only allows 2500 lookups a day (while we have 10,430 unique addresses). This would take at 
least 4 days to retrieve all the unique addresses.

To geocode (i.e. find the long/lat coordinates) the addresses more quickly, I used 
[GPS Visualizer's Address Locator](http://www.gpsvisualizer.com/geocoder/).
This took about 6 hours to complete, and required registering for a (free) Bing maps API key.
I save you the trouble and provide the geocoded address data in [geocoded_bing.csv](data_03_maps/geocoded_bing.csv).
