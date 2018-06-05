if (!requireNamespace("arcgisbinding", quietly=TRUE)) install.packages("arcgisbinding")
require(arcgisbinding)
if (!requireNamespace("sp", quietly=TRUE)) install.packages("sp")
require(sp)
if (!requireNamespace("rgdal", quietly=TRUE)) install.packages("rgdal")
require(rgdal)
if (!requireNamespace("rgeos", quietly=TRUE)) install.packages("rgeos")
require(rgeos)

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
