# code to get a count of the repeat visits to particular EOs/SFs
if (!requireNamespace("plyr", quietly=TRUE)) install.packages("plyr")
require(plyr)
if (!requireNamespace("psych", quietly=TRUE)) install.packages("psych")
require(psych)



loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)

visits <- read.csv("PA_VisitData/plant_eo_and_visit_data_20180515.csv")

visits_sum <- count(visits, c('SNAME','EO_ID','SF_ID'))



db <- dbConnect(SQLite(), dbname = databasename)
# ET plants
SQLquery_ET <- paste("SELECT SNAME,`GRANK_rounded`,`SRANK_rounded` ","FROM et_plants")
data_ET <- dbGetQuery(db, statement=SQLquery_ET )



visitsXsp <- describeBy(visits_sum$freq, visits_sum$SNAME, mat = TRUE) 
visitsXsp <- merge(visitsXsp, data_ET, by.x="group1",by.y="SNAME")


visitsXeo <- describeBy(visits_sum$freq, visits_sum$EO_ID, mat = TRUE) 


table(visitsXsp$GRANK_rounded,visitsXsp$max)
