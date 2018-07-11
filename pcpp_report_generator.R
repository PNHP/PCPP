if (!requireNamespace("RSQLite", quietly=TRUE)) install.packages("RSQLite")
require(RSQLite)
if (!requireNamespace("knitr", quietly=TRUE)) install.packages("knitr")
require(knitr)

loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)

############## develop datasets ##########################

db <- dbConnect(SQLite(), dbname = databasename)
# ET plants
SQLquery_ET <- paste("SELECT SNAME,SCOMNAME,SRANK,GRANK,ELSUBID,ELCODE,`SRANK.CHANGE.DATE`,`SRANK.REVIEW.DATE`,`TRACKING.STATUS` , `USESA` , `PA.STATUS` , `PBSSTATUS` , `PBS.DATE` , `PBSQUAL` , `SENSITV_SP` , `AQUATIC.INDICATOR` , `ER.RULE` , `In.ER.` , `GRANK_rounded` , `SRANK_rounded` , `temp_taxostatus` ","FROM et_plants")
data_ET <- dbGetQuery(db, statement=SQLquery_ET )
data_ET <- data_ET[which(substr(data_ET$ELCODE,1,1)!="N"),] # subset out bryophytes and lichens
source(paste(loc_scripts, "dataprep_speciesTableMaker.r", sep = "/"))

# IUCN redlist
SQLquery_IUCN <- paste("SELECT SNAME, `Red.List.status`, `Red.List.criteria`, `Population.trend`, PA_present","FROM redlist")
dataRedlist <- dbGetQuery(db, statement = SQLquery_IUCN )
# CCVI
SQLquery_ccvi <- paste("SELECT SNAME, score","FROM ccvi ")
data_ccvi <- dbGetQuery(db, statement = SQLquery_ccvi )
# IndexHerb
SQLquery_IndexHerb <- paste("SELECT NamOrganisation, NamOrganisationAcronym, IhhTotals ","FROM IndexHerb ")
data_IndexHerb <- dbGetQuery(db, statement = SQLquery_IndexHerb )
# acknowledgements
SQLquery_acknowledgements <- paste("SELECT firstname, lastname ","FROM acknowledgements ")
data_acknowledgements <- dbGetQuery(db, statement = SQLquery_acknowledgements )
data_acknowledgements$name <- paste(data_acknowledgements$firstname,data_acknowledgements$lastname,sep=" ")
data_acknowledgements <- paste(data_acknowledgements$name, collapse=", ") 

dbDisconnect(db)


##############  report generation  #######################
setwd(output_directory)
print("Generating the PDF report...") # report out to ArcGIS
daytime <-gsub("[^0-9]", "", Sys.time() )    # makes a report time variable
knit("../pcpp_report_new.rnw", output=paste("pcppReport",daytime, ".tex",sep=""))
call <- paste0("pdflatex -halt-on-error -interaction=nonstopmode ","pcppReport",daytime,".tex")
system(call)
system(paste0("biber ","pcppReport",daytime))
system(call) # 2nd run to apply citation numbers

#delete excess files from the pdf creation
fn_ext <- c(".tex",".log",".aux",".out",".toc",".blg",".bbl",".bcf",".run.xml")
for(i in 1:NROW(fn_ext)){
  fn <- paste("pcppReport",daytime, fn_ext[i],sep="")
  if (file.exists(fn)){ 
    file.remove(fn)
  }
}
setwd(working_directory)


# create and open the pdf
#pdf.path <- paste(working_directory, paste("pcppReport_",daytime,".pdf",sep=""), sep="/")
#system(paste0('open "', pdf.path, '"'))


