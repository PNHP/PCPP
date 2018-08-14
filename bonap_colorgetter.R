#---------------------------------------------------------------------------------------------
# Name:     bonap_colorgetter.R
# Purpose:  uses RGB values from bonap species range map images to determine species presence
#           in all US counties. Calculates Pennsylvania responsibility values for all species
#           based on the sum of species presence area within pennsylvania versus total species
#           presence area.
# Author:   Molly Moore
# Created:  2018-06-12
# Updates:  Updated to include Bonap image downloader
#
# To Do List/Future Ideas:
#           - copy rasters into geodatabase in R - currently has to be done in Arc
#           - develop method/math for determining edge of range species
#---------------------------------------------------------------------------------------------

# install and load necessary packages
if (!requireNamespace("arcgisbinding", quietly=TRUE)) install.packages("arcgisbinding")
require(arcgisbinding)
if (!requireNamespace("raster", quietly=TRUE)) install.packages("raster")
require(raster)
if (!requireNamespace("sf", quietly=TRUE)) install.packages("sf")
require(sf)
if (!requireNamespace("dplyr", quietly=TRUE)) install.packages("dplyr")
require(dplyr)
if (!requireNamespace("RCurl", quietly=TRUE)) install.packages("RCurl")
require(RCurl)
if (!requireNamespace("data.table", quietly=TRUE)) install.packages("data.table")
require(data.table)
if (!requireNamespace("rgdal", quietly=TRUE)) install.packages("rgdal")
require(rgdal)

# set path to bonap image folder, image geodatabase, county centroids.
image_folder <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/bonap/bonap_originals'
image_gdb <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/bonap/bonap_rasters.gdb'
county_centroids <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/bonap/bonap.gdb/county_centroids'
et <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/PCPP_ET_2018.csv'
url_base <- 'http://bonap.net/MapGallery/County/'
projection_file <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/BONAP/bonap_projection'

#####################################################################################################################
## Downloading files ################################################################################################
#####################################################################################################################

et_download <- read.csv(et)
snames <- et_download$SNAME
not_downloaded <- data.frame(species=character())
for(s in snames){
  u <- paste(paste0(url_base, s), "png", sep=".")
  u <- gsub(' ','%20',u)
  if(url.exists(u)==TRUE){
    download.file(u, paste0(paste(image_folder,s, sep='/'),".tif"), mode='wb')
  }
  else{
    print(paste0(s, " was not available for download"))
    nd <- data.frame(species=s)
    not_downloaded <- rbind(not_downloaded, nd)
  }
}

not_down <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/bonap/maps_not_downloaded.csv'
write.csv(not_downloaded, not_down)

# create list of species from file names. sub in underscores and exclude extension to match file name in GDB.
bonap_maps <- list.files(path = image_folder, pattern='\\.tif$')
bonap_maps <- gsub('\\.tif$', '', bonap_maps)
for(s in bonap_maps){
  file.copy(paste0(projection_file,".tfwx"), paste0(image_folder,"/",s,".tfwx"), overwrite=TRUE)
  file.copy(paste0(projection_file,".tif.aux.xml"), paste0(image_folder,"/",s,".tif.aux.xml"), overwrite=TRUE)
  file.copy(paste0(projection_file,".tif.xml"), paste0(image_folder,"/",s,".tif.xml"), overwrite=TRUE)
}

#####################################################################################################################
## Color Getting ####################################################################################################
#####################################################################################################################

# print start time for color loop
print(paste0("color gettin': ", Sys.time())) 

# open r-arc connection, load county centroid layer and change to sp
arc.check_product()
counties <- arc.open(county_centroids)
county_tbl <- arc.select(counties)
counties_shape <- arc.data2sp(county_tbl)

bonap_maps <- gsub(' ', '_', bonap_maps)
bonap_maps <- gsub('-', '_', bonap_maps)
bonap_maps <- gsub('var.', 'var', bonap_maps, fixed=TRUE)
bonap_maps <- gsub('ssp.', 'ssp', bonap_maps, fixed=TRUE)

# start loop
for(bonap in bonap_maps){
  # load in species raster from GDB
  map <- arc.open(paste(image_gdb,bonap,sep="/"))
  map <- arc.raster(map)
  map <- as.raster(map)
  
        #map <- readGDAL(paste0(image_folder,"/",bonap,".tif"))
        #crs(map) <- "+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs"
        #extent(map) <- extent(-2375340, 3008685, -2562062, 742518)

  # extract RGB values to county centroid points
  result <- extract(map, counties_shape)
  merge <- cbind(county_tbl, result)
  
  # create column and fill with species presence value based on RGB values
  merge$bonap <- ifelse(merge$Band_1 == 173 & merge$Band_2 == 142 & merge$Band_3 == 0, 'SNP',
          ifelse(merge$Band_1 == 0 & merge$Band_2 == 128 & merge$Band_3 == 0, 'SP',
          ifelse(merge$Band_1 == 0 & merge$Band_2 == 255 & merge$Band_3 == 0, 'PNR',
          ifelse(merge$Band_1 == 255 & merge$Band_2 == 255 & merge$Band_3 == 0, 'PR',
          ifelse(merge$Band_1 == 0 & merge$Band_2 == 0 & merge$Band_3 == 235, 'SPE',
          ifelse(merge$Band_1 == 0 & merge$Band_2 == 255 & merge$Band_3 == 255, 'PE',
          ifelse(merge$Band_1 == 255 & merge$Band_2 == 0 & merge$Band_3 == 255, 'NOX',
          ifelse(merge$Band_1 == 66 & merge$Band_2 == 66 & merge$Band_3 == 66, 'RAD',
          ifelse(merge$Band_1 == 0 & merge$Band_2 == 221 & merge$Band_3 == 145, 'SNA',
          ifelse(merge$Band_1 == 255 & merge$Band_2 == 165 & merge$Band_3 == 0, 'EXT', 'color not found'
          ))))))))))
  
  # change column name and join to country table
  colnames(merge)[colnames(merge)=='bonap'] <- bonap
  county_tbl <- cbind(county_tbl, merge[ncol(merge)])
}

# print end time for color getter
print(paste0("color gettin' finished: ", Sys.time())) 

# write bonap species presence data to .csv and geodatabase table
out_bonap <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/bonap/bonap_data.csv'
write.csv(county_tbl, out_bonap)
arc.write(path = 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/bonap/bonap.gdb/bonap', data = county_tbl, overwrite = TRUE)

#####################################################################################################################
## GET RESPONSIBILITY VALUES ########################################################################################
#####################################################################################################################

# create empty dataframe that will store species responsibility values
resp <- data.frame(species=character(), pa_proportion=integer())

# start loop for all species columns
for(bonap in bonap_maps){
  # select species column and only include if species is present not rare (PNR) or present rare (PR)
  column <- county_tbl %>%
              select(bonap, PA, area_km2) %>%
              filter_(paste0(bonap, "=='PNR'|",bonap,"=='PR'"))
 
   # sum area of counties by PA grouping
  s <- tapply(column$area_km2, column$PA, FUN=sum)
  
  # calculate proportion and if value is NA, change value to 0
  val <- round(s[2]/(s[1]+s[2]), digits=3)
  if(is.na(val)==TRUE){
    val <- 0
  }
  
  # add row with species name and responsibility value to responsibility df
  r <- data.frame(species=bonap, resp=val)
  resp <- rbind(resp, r)
}

# clear row names
rownames(resp) <- c()

# format species name to match species names in ET
resp$species <- gsub("_"," ", resp$species)
resp$species <- gsub("var ", "var. ", resp$species)
resp$species <- gsub("spp ", "spp. ", resp$species)

# read in ET and join with responsibility df
et <- read.csv(et)
species_resp <- merge(x=resp, y=et, by.x="species", by.y="SNAME", all.x=TRUE)

# write ET with responsibility values to .csv
out_responsibility <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/bonap/species_responsibility.csv' 
write.csv(species_resp, out_responsibility)

# print finish time
print(paste0("finish time: ", Sys.time())) 

