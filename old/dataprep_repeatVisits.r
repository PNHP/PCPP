# code to get a count of the repeat visits to particular EOs/SFs
if (!requireNamespace("plyr", quietly=TRUE)) install.packages("plyr")
require(plyr)

loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)

visits <- read.csv("PA_VisitData/plant_eo_and_visit_data_20180515.csv")

visits_sum <- count(visits, c('SNAME','EO_ID','SF_ID'))
