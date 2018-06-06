if (!requireNamespace("RSQLite", quietly=TRUE)) install.packages("RSQLite")
require(RSQLite)
if (!requireNamespace("knitr", quietly=TRUE)) install.packages("knitr")
require(knitr)

loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)

############## develop datasets ##########################

# table of g-s ranks
source("dataprep_ET_processor.R")

# IUCN redlist
db <- dbConnect(SQLite(), dbname = databasename)
SQLquery_IUCN <- paste("SELECT SNAME, `Red.List.status`, `Red.List.criteria`, `Population.trend`, PA_present"," FROM redlist ")
dataRedlist <- dbGetQuery(db, statement = SQLquery_IUCN )
#dataRedlist_sub <- dataRedlist[which(dataRedlist=="CR"|dataRedlist=="EN"|dataRedlist=="NT"),]

##############  report generation  #######################
setwd(output_directory)
print("Generating the PDF report...") # report out to ArcGIS
daytime <-gsub("[^0-9]", "", Sys.time() )    # makes a report time variable
#knit2pdf(paste(working_directory,"pcpp_report.rnw",sep="/"), output=paste("pcppReport",daytime, ".tex",sep=""))   #write the pdf
knit("../pcpp_report.rnw", output=paste("pcppReport",daytime, ".tex",sep=""))
call <- paste0("pdflatex -halt-on-error -interaction=nonstopmode ","pcppReport",daytime,".tex")
system(call)
system(call) # 2nd run to apply citation numbers

#delete excess files from the pdf creation
fn_ext <- c(".tex",".log",".aux",".out",".toc")
for(i in 1:NROW(fn_ext)){
  fn <- paste("pcppReport",daytime, fn_ext[i],sep="")
  if (file.exists(fn)){ 
    file.remove(fn)
  }
}

# create and open the pdf
#pdf.path <- paste(working_directory, paste("pcppReport_",daytime,".pdf",sep=""), sep="/")
#system(paste0('open "', pdf.path, '"'))

setwd(working_directory)
