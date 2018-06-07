if (!requireNamespace("arcgisbinding", quietly=TRUE)) install.packages("arcgisbinding")
require(arcgisbinding)
if (!requireNamespace("sp", quietly=TRUE)) install.packages("sp")
require(sp)
if (!requireNamespace("rgdal", quietly=TRUE)) install.packages("rgdal")
require(rgdal)
if (!requireNamespace("rgeos", quietly=TRUE)) install.packages("rgeos")
require(rgeos)
if (!requireNamespace("beanplot", quietly=TRUE)) install.packages("beanplot")
require(beanplot)



arc.check_product()

loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)

# load and report on EOs
## EO point reps
eo_ptreps <- paste(loc_eo,"eo_ptreps",sep="/")
eo_ptreps <- arc.open(eo_ptreps)
eo_ptreps_plants <- arc.select(eo_ptreps, fields=c('ELCODE','SNAME','SCOMNAME','ELSUBID','EO_ID','LASTOBS','SURVEYDATE','EORANK','PREC_BCD','EST_RA'), where_clause="ELCODE LIKE 'P%'"  ) # , sr=a
sp.eo_ptreps_plants <- arc.data2sp(eo_ptreps_plants)
## EO reps
eo_reps <- paste(loc_eo,"eo_reps",sep="/")
eo_reps <- arc.open(eo_reps)
eo_reps_plants <- arc.select(eo_reps, fields=c('ELCODE','SNAME','SCOMNAME','ELSUBID','EO_ID','LASTOBS','SURVEYDATE','EORANK','PREC_BCD','EST_RA'), where_clause="ELCODE LIKE 'P%'"  )
sp.eo_reps_plants <- arc.data2sp(eo_reps_plants)

# load and report on Source Features
## source points
srcpt <- paste(loc_eo,"eo_sourcept",sep="/")
srcpt <- arc.open(srcpt)
srcpt_plants <- arc.select(srcpt, fields=c('ELCODE','SNAME','SCOMNAME','ELSUBID','EO_ID','SF_ID','EST_RA','C_FEAT_TYPE'), where_clause="ELCODE LIKE 'P%'"  )
sp.srcpt_plants <- arc.data2sp(srcpt_plants)
## source lines
srcln <- paste(loc_eo,"eo_sourceln",sep="/")
srcln <- arc.open(srcln)
srcln_plants <- arc.select(srcln, fields=c('ELCODE','SNAME','SCOMNAME','ELSUBID','EO_ID','SF_ID','EST_RA','C_FEAT_TYPE'), where_clause="ELCODE LIKE 'P%'"  )
sp.srcln_plants <- arc.data2sp(srcln_plants)
## source polys
srcpy <- paste(loc_eo,"eo_sourcepy",sep="/")
srcpy <- arc.open(srcpy)
srcpy_plants <- arc.select(srcpy, fields=c('ELCODE','SNAME','SCOMNAME','ELSUBID','EO_ID','SF_ID','EST_RA','C_FEAT_TYPE'), where_clause="ELCODE LIKE 'P%'"  )
sp.srcpy_plants <- arc.data2sp(srcpy_plants)

# load in a county layer
county <- arc.open("W:/LYRS/Boundaries_Political/County Hollow.lyr" )
county <- arc.select(county)
sp.county <- arc.data2sp(county)
sp.county500m <- gBuffer(sp.county,byid=TRUE,width=5000)


# Spatial Join data to counties
join_srcpt <- over(sp.srcpt_plants, sp.county500m[,"COUNTY_NAM"])
sp.srcpt_plants$county <- join_srcpt$COUNTY_NAM

join_srcln <- over(sp.srcln_plants, sp.county500m[,"COUNTY_NAM"],returnList = TRUE)
join_srcln_coll <- sapply(join_srcln, paste, collapse=";", simplify = TRUE)
sp.srcln_plants$county <- join_srcln_coll
sp.srcln_plants$county <- gsub("c\\(", "",sp.srcln_plants$county)
sp.srcln_plants$county <- gsub("\\)", "",sp.srcln_plants$county)
sp.srcln_plants$county <- gsub("\"", "",sp.srcln_plants$county)

join_srcpy <- over(sp.srcpy_plants, sp.county500m[,"COUNTY_NAM"],returnList = TRUE)
join_srcpy_coll <- sapply(join_srcpy, paste, collapse=";", simplify = TRUE)
sp.srcpy_plants$county <- join_srcpy_coll
sp.srcpy_plants$county <- gsub("c\\(", "",sp.srcpy_plants$county)
sp.srcpy_plants$county <- gsub("\\)", "",sp.srcpy_plants$county)
sp.srcpy_plants$county <- gsub("\"", "",sp.srcpy_plants$county)


# write out the resutls
arc.write("P:/Conservation Programs/Natural Heritage Program/Projects/Active projects/1495 DCNR Plant Conservation Plan/Project Materials and Data/data/sp.srcpy_plants.shp",sp.srcpy_plants)
arc.write("P:/Conservation Programs/Natural Heritage Program/Projects/Active projects/1495 DCNR Plant Conservation Plan/Project Materials and Data/data/sp.srcpt_plants.shp",sp.srcpt_plants)
arc.write("P:/Conservation Programs/Natural Heritage Program/Projects/Active projects/1495 DCNR Plant Conservation Plan/Project Materials and Data/data/sp.srcln_plants.shp",sp.srcln_plants)


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


