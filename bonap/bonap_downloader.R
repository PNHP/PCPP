#---------------------------------------------------------------------------------------------
# Name:     bonap_downloader.R
# Purpose:  downloads .png map images from BONAP and creates projection files for each image 
#           based on template projection files.
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