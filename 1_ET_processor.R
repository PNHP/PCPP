if (!requireNamespace("RSQLite", quietly=TRUE)) install.packages("RSQLite")
require(RSQLite)
if (!requireNamespace("data.table", quietly=TRUE)) install.packages("data.table")
require(data.table)
if (!requireNamespace("arcgisbinding", quietly=TRUE)) install.packages("arcgisbinding")
require(arcgisbinding)

loc_scripts <- "H:/Scripts/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)

# path to most current PNHP ET
et_path <- "W:\\Heritage\\Heritage_Data\\Biotics_datasets.gdb\\ET"
arc.check_product()
et_open <- arc.open(et_path)
et <- arc.select(et_open)

# subset to vascular and nonvascular plants
et_plants <- et[(substr(et$ELCODE,1,1)=="P")|(substr(et$ELCODE,1,1)=="N"), ]
et <- NULL # delete the ET dataframe as its not longer needed

# added rounded ranks to list
rounded_grank <- read.csv("reference_data/rounded_grank.csv",stringsAsFactors=FALSE) 
rounded_srank <- read.csv("reference_data/rounded_srank.csv",stringsAsFactors=FALSE) 
et_plants <- merge(x=et_plants, y=rounded_grank, by="GRANK", all.x=TRUE)
et_plants <- merge(x=et_plants, y=rounded_srank, by="SRANK", all.x=TRUE)
rounded_grank <- NULL
rounded_srank <- NULL

# The following section identifies which species and subspecific taxa are present in the state and subsets the list to be just those
# find potential overlapping taxa due to subspecies/variabties
specname <- as.character(et_plants$SNAME)
specname1 <- sub("^(.*? .*?) .*", "\\1", specname)
spec_dup <- specname1[duplicated(specname1)]
spec_dup <- spec_dup[!grepl(" x", spec_dup)] #get rid of hybrids
spec_dup <- sort(spec_dup)
spec_dup <- unique(spec_dup)

spec_sspvar <- specname[specname %like% " var. "|specname %like% " ssp. " ] ### what does this do?

# sees what records we have in Biotics
eo_ptreps <- paste(loc_eo,"eo_ptreps",sep="/") ## EO point reps to get a list of species we have records for in biotics
eo_ptreps <- arc.open(eo_ptreps)
eo_ptreps_plants <- arc.select(eo_ptreps, fields=c('ELCODE','SNAME','SCOMNAME','ELSUBID'), where_clause="ELCODE LIKE 'P%'") 
eo_ptreps <- NULL
biotics_records <- unique(eo_ptreps_plants)
biotics_records <- biotics_records[order(biotics_records$SNAME),]

# if the species is in biotics label it as so
et_plants$temp_taxostatus[et_plants$SNAME %in% biotics_records$SNAME] <- "in biotics"

# find the species that are not in biotics, but they have a subsp or variety
spec_sspvar_noBiotics <- et_plants$SNAME[((et_plants$SNAME %like% " var. "|et_plants$SNAME %like% " ssp. ") & is.na(et_plants$temp_taxostatus) & (et_plants$EO_TRACK!="Y"|et_plants$EO_TRACK!="W") ) ]
only_subspecific_taxa <- spec_sspvar_noBiotics[!(sub("^(.*? .*?) .*", "\\1", spec_sspvar_noBiotics) %in% et_plants$SNAME )]
spec_sspvar_noBiotics <- setdiff(spec_sspvar_noBiotics, only_subspecific_taxa )
spec_sspvar_noBiotics <- as.character(spec_sspvar_noBiotics) # droplevels 
spec_sspvar_noBiotics <- na.omit(spec_sspvar_noBiotics)

# if the species is 
et_plants$temp_taxostatus[et_plants$SNAME %in% spec_sspvar_noBiotics] <- "subspecific taxa, effective duplicate"

#subset out the duplicates and use this from now on!
et_plants <- et_plants[which(et_plants$temp_taxostatus!="subspecific taxa, effective duplicate"|is.na(et_plants$temp_taxostatus)),]

#####################################
#get taxonomic information
taxo <- read.csv("reference_data/taxonomy.csv",stringsAsFactors=FALSE)
keeps <- c("ELEMENT_SUBNATIONAL_ID","ELCODE","CLASS","TAX_ORDER","FAMILY","GLOBAL_NAME","GLOBAL_COMNAME","PA_NAME","PA_COMNAME","CLASSIFICATION_COM","ORIGIN","REGULARITY","DIST_CONFIDENCE","CURR_PRESENCE_ABSENCE")
taxo <- taxo[keeps]

# write to the SQLite db
db <- dbConnect(SQLite(), dbname = databasename)
dbWriteTable(db, "et_plants",et_plants, overwrite=TRUE)
dbWriteTable(db, "taxo", taxo, overwrite=TRUE)
dbDisconnect(db)