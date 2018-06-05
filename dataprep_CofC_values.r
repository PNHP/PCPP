library(xlsx)
library(RSQLite)
library(tidyr)
library(data.table)

setwd("P:/Conservation Programs/Natural Heritage Program/Projects/Active projects/1495 DCNR Plant Conservation Plan/Project Materials and Data/data")

# path to the PNHP Element Tracking list
C_path <- "P:/Conservation Programs/Natural Heritage Program/Projects/Active projects/1495 DCNR Plant Conservation Plan/Project Materials and Data/data"
# name of et file in excel format
C_file <- "ET_FQI_crosswalk_2017-03-16_toNatureServe_ks.csv"

C <- read.csv(paste(C_path,C_file,sep="/"),stringsAsFactors=FALSE )
# subset data frame
keeps <- c("ELEMENT.SUBNATIONAL.ID","ELCODE","SCIENTIFIC.NAME","AP.1","CP.1","GP.1","PD.1","RV.1","PI","NOTES")
C <- C[keeps]

setnames(C, old=c("AP.1","CP.1","GP.1","PD.1","RV.1"), new=c("AP","CP","GP","PD","RV"))


# replace with NA
C[C=="#N/A"] <- NA
C[C==""] <- NA
