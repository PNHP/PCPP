if (!requireNamespace("taxize", quietly=TRUE)) install.packages("taxize")
require(taxize)
if (!requireNamespace("dplyr", quietly=TRUE)) install.packages("dplyr")
require(dplyr)

species <- read.csv("maps_not_downloaded.csv", stringsAsFactors = FALSE, header = FALSE)

a <- synonyms(species$V1, db="itis")
b <- a
b <- data.frame(matrix(unlist(b), byrow=T))

b1 <- data.frame(t(sapply(b,c)))
b1 <- ldply(b)
