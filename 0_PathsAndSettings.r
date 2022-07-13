# Purpose: to define a set of consistently used objects for a full PCPP Run
#   run. The goal is to avoid redundancy and improve consistency among scripts.

if (!requireNamespace("here", quietly=TRUE)) install.packages("here")
require(here)
if (!requireNamespace("reshape2", quietly=TRUE)) install.packages("reshape2")
require(reshape2)

# Set input paths ----
working_directory <- "H:/Scripts/PCPP"
output_directory <- paste(working_directory,"output",sep="/")
databasename <- "PlantConservationPlan.sqlite"
graphics_path <- "output/images/"
loc_eo <- "W:/Heritage/Heritage_Data/Biotics_datasets.gdb"  # arc geodatabase directory for EOs and SFs

# set options   
options(useFancyQuotes = FALSE)
options(scipen=999)
# Latex Formating Variables  ##  not sure if this is needed anymore.

# functions
