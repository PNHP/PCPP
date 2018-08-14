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

#set paths
counties <- "W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/BONAP/bonap.gdb/counties_us"
bonap_data <- "W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/BONAP/bonap_data.csv"
output_folder <- "W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/BONAP/Maps/"
image_folder <- 'W:/Heritage/Heritage_Projects/1495_PlantConservationPlan/bonap/bonap_originals'

#open counties with arcbridge
arc.check_product()
county_open <- arc.open(counties)
county_select <- arc.select(county_open)
county_lyr <- arc.data2sf(county_select)
county_lyr$COUNTYNS <- as.integer(county_lyr$COUNTYNS)

bonap <- read.csv(file=bonap_data, header=TRUE, sep=",")

county_bonap <- merge(county_lyr, bonap, by='COUNTYNS')

bonap_maps <- list.files(path = image_folder, pattern='\\.tif$')
bonap_maps <- gsub('\\.tif$', '', bonap_maps)
bonap_maps <- gsub(' ', '_', bonap_maps)
bonap_maps <- gsub('-', '_', bonap_maps)
bonap_maps <- gsub('var.', 'var', bonap_maps, fixed=TRUE)
bonap_maps <- gsub('ssp.', 'ssp', bonap_maps, fixed=TRUE)

cols <- c("Not present in state"="yellow4",
          "Present in state"="green4",
          "Present, not rare"="green1",
          "Present, rare"="yellow",
          "Present in state and exotic"="blue",
          "Exotic and present"="cyan2",
          "Noxious"="magenta",
          "Eradicated"="grey30",
          "Native, but adventive in state"="grey70",
          "Extirpated (historic)"="red")

# start loop for all species columns
for(b in bonap_maps){
  # select species column and only include if species is present not rare (PNR) or present rare (PR)
  column <- county_bonap %>%
    select(b)
  column[[b]] <- gsub("SNP","Not present in state", column[[b]])
  column[[b]] <- gsub("SP","Present in state", column[[b]])
  column[[b]] <- gsub("PNR","Present, not rare", column[[b]])
  column[[b]] <- gsub("PR","Present, rare", column[[b]])
  column[[b]] <- gsub("SPE","Present in state and exotic", column[[b]])
  column[[b]] <- gsub("PE","Exotic and present", column[[b]])
  column[[b]] <- gsub("NOX","Noxious", column[[b]])
  column[[b]] <- gsub("RAD","Eradicated", column[[b]])
  column[[b]] <- gsub("SNA","Native, but adventive in state", column[[b]])
  column[[b]] <- gsub("EXT","Extirpated (historic)", column[[b]])
  
  ggplot(column) +
    geom_sf(mapping=aes(fill=column[[b]]),lwd=0.25,color="grey40") +
    scale_colour_manual(values=cols, aesthetics = c("fill")) +
    labs(title=gsub('_',' ',b),
         subtitle="Range within Contigious United States")+
    theme(axis.line = element_blank(),
          panel.grid.major = element_line(colour='transparent'),
          panel.grid.minor = element_line(colour='transparent'),
          panel.border = element_blank(),
          panel.background = element_blank(),
          axis.text.x=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.x=element_blank(),
          axis.ticks.y=element_blank(),
          legend.title=element_blank(),
          legend.box.margin=margin(0,0,-25,-50),
          legend.text=element_text(size=9),
          legend.key.size=unit(.8,"line"),
          plot.title=element_text(size=12,hjust=0.5,face=c("bold.italic")),
          plot.subtitle=element_text(size=8,hjust=0.5))+
    guides(fill = guide_legend(reverse=TRUE))+
    ggsave(paste0(output_folder,b,".png"), width=7.5, height=4, dpi=500)
  }


