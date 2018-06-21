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
if (!requireNamespace("ggplot2", quietly=TRUE)) install.packages("ggplot2")
require(ggplot2)
if (!requireNamespace("rmapshaper", quietly=TRUE)) install.packages("rmapshaper")
require(rmapshaper)

counties <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/BONAP'
bonap_data <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/bonap/bonap_data.csv'

theme_map <- function(...) {
  theme_minimal() +
    theme(
      text = element_text(family = "Ubuntu Regular", color = "#22211d"),
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      # panel.grid.minor = element_line(color = "#ebebe5", size = 0.2),
      panel.grid.major = element_line(color = "#ebebe5", size = 0.2),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "#f5f5f2", color = NA), 
      panel.background = element_rect(fill = "#f5f5f2", color = NA), 
      legend.background = element_rect(fill = "#f5f5f2", color = NA),
      panel.border = element_blank(),
      ...
    )
}

#arc.check_product()
#counties <- arc.open(county_centroids)
#county_tbl <- arc.select(counties)
#counties_shape <- arc.data2sf(county_tbl)

counties_shape <- readOGR(dsn=counties, layer = "counties")
counties_simp <- ms_simplify(counties_shape, keep=0.01, keep_shapes=TRUE)
bonap <- read.csv(bonap_data)

counties_fortify <- fortify(counties_simp, region="COUNTYNS")
counties_fortify$COUNTYNS <- as.integer(counties_fortify$id)
map_data <- counties_fortify %>% left_join(bonap, by = c("COUNTYNS", "COUNTYNS"))

map <- map_data[c("long", "lat", "Abies_balsamea", "group")]

p <- ggplot() + 
  geom_polygon(data=map, aes(x=long,y=lat,fill=Abies_balsamea), color="black", size=0.25)+
  coord_map()
p
ggsave(p, file='W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/BONAP/test.png', width=6.5,height=4.5, type="cairo-png")

