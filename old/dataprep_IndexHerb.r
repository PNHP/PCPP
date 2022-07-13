if (!requireNamespace("RSQLite", quietly=TRUE)) install.packages("RSQLite")
require(RSQLite)
if (!requireNamespace("arcgisbinding", quietly=TRUE)) install.packages("arcgisbinding")
require(arcgisbinding)

loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)

# download the herbariunm file from Index Herbaria
# http://sweetgum.nybg.org/science/ih/herbarium_list.php?NamOrganisation=&AddPhysCity=&AddPhysState=Pennsylvania&AddPhysCountry=&IhhCollections_tab=&sortBy=NamOrganisation&rownum=21

urlHerb <- "http://sweetgum.nybg.org/science/ih/herbarium_list.csv.php?NamOrganisation=&AddPhysCity=&AddPhysState=Pennsylvania&AddPhysCountry=&IhhCollections_tab=&sortBy=NamOrganisation&rownum=21"

download.file(url=urlHerb, "reference_data/IndexHerbariorum_PA.csv" )

IndexHerb <- read.csv("reference_data/IndexHerbariorum_PA.csv", stringsAsFactors=FALSE)


IndexHerb$IhhTotals <- as.numeric(gsub(" ", "", IndexHerb$IhhTotals, fixed = TRUE))



# write to the SQLite db
db <- dbConnect(SQLite(), dbname = databasename)
dbWriteTable(db, "IndexHerb",IndexHerb, overwrite=TRUE)
dbDisconnect(db)



