#---------------------------------------------------------------------------------------------
# Name: test_natserv_Uid_getter.R
# Purpose: 
# Author: Christopher Tracey
# Created: 2016-09-20
# Updated: 2016-09-21
#
# Updates:
# insert date and info
# * 2016-08-17 - got the code to remove NULL values from the keys to work; 
#                added the complete list of SGCN to load from a text file;
#                figured out how to remove records where no occurences we found;
#                make a shapefile of the results  
#
# To Do List/Future Ideas:
# * 
#-------
library('dplyr')
library('devtools')
library('natserv')

#http://services.natureserve.org/docs/schemas/biodiversityDataFlow/1/1/documentation_comprehensiveSpecies_v1.1.xml
# need to set an environment varible for the NatureServe key
Sys.setenv(NATURE_SERVE_KEY="72ddf45a-c751-44c7-9bca-8db3b4513347")


loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)


db <- dbConnect(SQLite(), dbname = databasename)
# ET plants
SQLquery_ET <- paste("SELECT SNAME ","FROM et_plants")
splist<- dbGetQuery(db, statement=SQLquery_ET )

datalist = list() #creates an empty list

for (SGCN in splist){
  #ERROR HANDLING
  possibleError <- tryCatch(
    nam <- ns_search(SGCN),
    error=function(e) e
  )
  if(inherits(possibleError, "error")) next
  #REAL WORK
  nam <- ns_search(SGCN)
  #nam$sgcn <- SGCN
  datalist[[SGCN]] <- nam
  print(SGCN) #just for tracking progress
}  #end for

species_list <- bind_rows(datalist)


ns_datalist = list() #creates an empty list
for (i in 1:length(species_list$globalSpeciesUid)){
  delayedAssign("do.next", {next})
  tryCatch(ns_datalist[i] <- ns_data(uid=species_list$globalSpeciesUid[i]), finally=print(species_list$globalSpeciesUid[i]), error=function(e) force(do.next))
}  
  
NS_species_list <- bind_rows(ns_datalist)



