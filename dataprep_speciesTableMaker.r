if (!requireNamespace("RSQLite", quietly=TRUE)) install.packages("RSQLite")
require(RSQLite)

loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)

db <- dbConnect(SQLite(), dbname = databasename)
SQLquery_ET <- paste("SELECT SNAME, SCOMNAME, ELCODE, ELSUBID, GRANK, SRANK, GRANK_rounded, SRANK_rounded, temp_taxostatus"," FROM et_plants")
data_ET <- dbGetQuery(db, statement = SQLquery_ET )

SQLquery_taxonomy <- paste("SELECT ELEMENT_SUBNATIONAL_ID, ELCODE, CLASS, TAX_ORDER, FAMILY, GLOBAL_NAME, GLOBAL_COMNAME, PA_NAME, PA_COMNAME, CLASSIFICATION_COM, ORIGIN, REGULARITY, DIST_CONFIDENCE, CURR_PRESENCE_ABSENCE" , " FROM taxo")
data_taxonomy <- dbGetQuery(db, statement = SQLquery_taxonomy )

data_ET <- merge(data_ET, data_taxonomy[c("ELCODE","CLASS","FAMILY","ORIGIN")], by="ELCODE") # all.x=TRUE
data_ET <- data_ET[(data_ET$CLASS=="Dicotyledoneae"|data_ET$CLASS=="Pinopsida"|data_ET$CLASS=="Ginkgoopsida"|data_ET$CLASS=="Monocotyledoneae"|data_ET$CLASS=="Lycopodiopsida"|data_ET$CLASS=="Ophioglossopsida"),]

data_ET_native <- data_ET[tolower(data_ET$ORIGIN)!="exotic",]
data_ET_exotic <- data_ET[tolower(data_ET$ORIGIN)=="exotic",]

# create a table of granks by sranks
gt_ranks <- read.csv("reference_data/g_t_ranks.csv", stringsAsFactors=FALSE)
data_ET_native <- merge(data_ET_native,gt_ranks,by.x="GRANK_rounded", by.y="rank", all.x=TRUE)
gt_ranks <- NULL
gs_matrix <- as.data.frame.matrix(table(data_ET_native$rank_combo,data_ET_native$SRANK_rounded))
gs_matrix <- cbind(rownames(gs_matrix), gs_matrix)
colnames(gs_matrix)[1] <- "rank"

# various bits of taxonomic interest
cnt_varieties <- NROW(data_ET_native$SNAME[data_ET_native$SNAME %like% " var. "]) 
cnt_subspecies <- NROW(data_ET_native$SNAME[data_ET_native$SNAME %like% " ssp. "])
cnt_hybrids <- NROW(data_ET_native$SNAME[data_ET_native$SNAME %like% " x "])

# create a table of the largest families
family_X_spp <- as.data.frame(table(data_ET_native$FAMILY))
colnames(family_X_spp)[1] <- "Family"
family_X_spp <- family_X_spp[order(-family_X_spp$Freq),]
#pie(family_X_spp$Freq,labels=family_X_spp$Family)

# create a table of the families with the largest number of rare species
family_X_rarity <- as.data.frame.matrix(table(data_ET_native$FAMILY,data_ET_native$rank_combo))

