if (!requireNamespace("taxize", quietly=TRUE)) install.packages("taxize")
require(taxize)
if (!requireNamespace("plyr", quietly=TRUE)) install.packages("plyr")
require(plyr)

species <- read.csv("maps_not_downloaded.csv", stringsAsFactors = FALSE, header = FALSE)

a <- synonyms(species$V1, db="itis")
b <- a

# turn list of dataframes into a dataframe
sapply(b, class)
x2 <- lapply(b, as.data.frame)
x3 <- bind_rows(x2)

x3$match <- x3$syn_name %in% species$V1
x3 <- x3[which( x3$match=="TRUE" ),]
x3 <- x3[which(!is.na(x3$acc_name) ),]
x3 <- unique(x3[c("acc_name","syn_name")])


write.csv(x3, "bonap_syn.csv")
