#if (!requireNamespace("RSQLite", quietly=TRUE)) install.packages("RSQLite")
#require(RSQLite)
#if (!requireNamespace("data.table", quietly=TRUE)) install.packages("data.table")
#require(data.table)

# using 'here' instead of setwd
library(here)
#loc_scripts <- "E:/pcpp/PCPP"
source(here("0_PathsAndSettings.R"))

dat <- read.csv(here("EO_x_landowner/intersect_20180711.csv"), stringsAsFactors = FALSE)
dat1 <- table(dat$SNAME,dat$ProLandType)
dat1.margin <- margin.table(dat1,1)

dat1.prop <- prop.table(dat1)
dat1.prop <-as.data.frame.matrix(prop.table(dat1,1))

#dat2 <- aggregate(dat$Shape_Area, by=list(dat$SNAME,dat$ProLandType), FUN=sum)
#dat2a <- table(dat2$Group.1,dat2$Group.2)

dat3 <- as.data.frame(xtabs(Shape_Area~ProLandType+SNAME, data=dat))
dat3a <- acast(dat3, SNAME~ProLandType, value.var="Freq")
dat3a <- format(dat3a, digits=1) # reformat to one decimal place

dat3a.prop <- as.data.frame.matrix(prop.table(dat3a,1))
