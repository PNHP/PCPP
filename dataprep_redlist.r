# IUCN Redlist
library(RSQLite)

loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)


#import a csv export from the IUCN redlist
# http://www.iucnredlist.org/search/saved?id=91671
redlist <- read.csv(paste0(working_directory,"/reference_data/IUCNredlist/export-91671.csv"), stringsAsFactors=FALSE)

redlist$SNAME <- paste(redlist$Genus,redlist$Species,sep=" ")

redlist$PA_present <- redlist$SNAME %in% et_plants$SCIENTIFIC.NAME # get a list of redlist species that are one the PA ET.

# write to the SQLite db
db <- dbConnect(SQLite(), dbname = databasename)
dbWriteTable(db, "redlist",redlist, overwrite=TRUE)
dbDisconnect(db)

