#if (!requireNamespace("RSQLite", quietly=TRUE)) install.packages("RSQLite")
#require(RSQLite)
#if (!requireNamespace("data.table", quietly=TRUE)) install.packages("data.table")
#require(data.table)

# using 'here' instead of setwd
library(here)
#loc_scripts <- "E:/pcpp/PCPP"
source(here("0_PathsAndSettings.R"))

dat <- read.csv(here("EO_x_landowner/intersect.csv"), stringsAsFactors = FALSE)
dat1 <- table(dat$SNAME,dat$ProLandType)
dat1.margin <- margin.table(dat1,1)

dat1.prop <- prop.table(dat1)
dat1.prop <-as.data.frame.matrix(prop.table(dat1,1))

dat3 <- as.data.frame(xtabs(Shape_Area~ProLandType+SNAME, data=dat))
dat3a <- acast(dat3, SNAME~ProLandType, value.var="Freq")
dat3a <- format(dat3a, digits=1) # reformat to one decimal place
#dat3a <- as.data.frame(dat3a)
dat3a$V1 <- as.numeric(dat3a$V1)
dat3a$`Conservation Easement` <- as.numeric(dat3a$`Conservation Easement`)
dat3a$`Farm Easement` <- as.numeric(dat3a$`Farm Easement`)
dat3a$Federal <- as.numeric(dat3a$Federal)
dat3a$Local <- as.numeric(dat3a$Local)
dat3a$Private <- as.numeric(dat3a$Private)
dat3a$State <- as.numeric(dat3a$State)

dat3a.prop <- as.data.frame.matrix(prop.table(dat3a,1))
