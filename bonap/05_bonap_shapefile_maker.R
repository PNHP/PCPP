if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
require(ggplot2)
if (!requireNamespace("ggmap", quietly = TRUE)) install.packages("ggmap")
require(ggmap)
if (!requireNamespace("arcgisbinding", quietly = TRUE)) install.packages("arcgisbinding")
require(arcgisbinding)
if (!requireNamespace("sf", quietly = TRUE)) install.packages("sf")
require(sf)
if (!requireNamespace("dplyr", quietly=TRUE)) install.packages("dplyr")
require(dplyr)
if (!requireNamespace("rgdal", quietly=TRUE)) install.packages("rgdal")
require(rgdal)
if (!requireNamespace("stringr", quietly=TRUE)) install.packages("stringr")
require(stringr)

counties <- "W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/BONAP/bonap.gdb/counties_us"
bonap_data <- "W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/BONAP/bonap_data.csv"

bonap1 <- read.csv(file=bonap_data, header=TRUE, sep=",")
bonap1 <- bonap1 %>%
          select(COUNTYNS,NAME,PA,Lupinus_perennis,Baptisia_tinctoria)

gnames <- list("Lupinus_perennis", "Baptisia_tinctoria")

arc.check_product()
counties <- arc.open(counties)
counties <- arc.select(counties)
spcounties1 <- arc.data2sp(counties)

for(i in gnames){
  sp_counties <- bonap1 %>%
                  select(COUNTYNS,NAME,PA,i)
  sp_counties$COUNTYNS <- str_pad(sp_counties$COUNTYNS, 8, pad="0")
  map1 <- merge(spcounties1,sp_counties,by="COUNTYNS")
  ##insert dissolve step
  ##map1 <- map1[which(map1$code=="PR"|map1$code=="PNR"|map1$code=="EXT"),]
  ##map1 <- map1[order(map1$code),]
  ##map1_lu <- as.data.frame(unique(map1@data$code))
  ##colnames(map1_lu) <- "code"
  ##map1_dissove <- gUnaryUnion(map1, id = map1@data$code)
  ##row.names(map1_dissove) = as.character(1:length(map1_dissove))
  ##map1_dissove <- SpatialPolygonsDataFrame(map1_dissove,map1_lu) 
  ##map1_dissove <- cbind(map1_dissove, GNAME=gnames[i])
  ##colnames(map1_dissove@data)[2] <- "GNAME"
  writeOGR(map1, dsn="W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/BONAP/Shapefiles", i, driver="ESRI Shapefile")
}

