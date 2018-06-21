# beanplot maker

##### get last obs dates for each EO and make a graph
eo_lastobs <- sp.eo_ptreps_plants@data # convert to a data frame
db <- dbConnect(SQLite(), dbname = databasename)
SQLquery_et <- paste("SELECT ELCODE, GRANK, SRANK, `TRACKING.STATUS`"," FROM et_plants ")
data_et <- dbGetQuery(db, statement = SQLquery_et )
dbDisconnect(db)
eo_lastobs <- merge(eo_lastobs, data_et, by="ELCODE")  # merge in grank, srank, etc
eo_lastobs <- eo_lastobs[which(eo_lastobs$TRACKING.STATUS=="Y"|eo_lastobs$TRACKING.STATUS=="W"),]
eo_lastobs$lastobsyear <- substr(eo_lastobs$LASTOBS,1,4) # should updrage the methods to use lubridate
eo_lastobs$lastobsyear <- as.numeric(eo_lastobs$lastobsyear)
eo_lastobs <- eo_lastobs[which(!is.na(eo_lastobs$lastobsyear)),]

rounded_grank <- read.csv("reference_data/rounded_grank.csv",stringsAsFactors=FALSE) 
rounded_srank <- read.csv("reference_data/rounded_srank.csv",stringsAsFactors=FALSE) 
eo_lastobs <- merge(x=eo_lastobs, y=rounded_grank, by.x="GRANK", by.y="G.RANK", all.x=TRUE)
eo_lastobs <- merge(x=eo_lastobs, y=rounded_srank, by.x="SRANK", by.y="S.RANK", all.x=TRUE)
rounded_grank <- NULL
rounded_srank <- NULL
gt_ranks <- read.csv("reference_data/g_t_ranks.csv", stringsAsFactors=FALSE)
eo_lastobs <- merge(eo_lastobs,gt_ranks,by.x="Rounded.G.RANK", by.y="rank", all.x=TRUE)
gt_ranks <- NULL