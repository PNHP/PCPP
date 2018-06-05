if (!requireNamespace("RSQLite", quietly=TRUE)) install.packages("RSQLite")
require(RSQLite)

loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep="/"))
setwd(working_directory)

# write to the SQLite db
db <- dbConnect(SQLite(), dbname = databasename)

SQLquery_ccvi <- paste("SELECT ELCODE, SNAME, score, date"," FROM ccvi ")
data_ccvi <- dbGetQuery(db, statement = SQLquery_ccvi )
