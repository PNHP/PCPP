library(xlsx)
library(RSQLite)

loc_scripts <- "E:/pcpp/PCPP"
source(paste(loc_scripts, "0_PathsAndSettings.R", sep = "/"))
setwd(working_directory)

# path to the PNHP Element Tracking list
et_path <- "P:/Conservation Programs/Natural Heritage Program/Data Management/Biotics Database Areas/Element Tracking/current element lists"
# name of et file in excel format
et_file <- "2018-03-29 complete EST.xlsx"
# name tof the sheet that the ET is on
et_sheet <- "Query Output"

et <- read.xlsx(paste(et_path, et_file, sep="/"), sheetName=et_sheet)

# subset to vascular and nonvascular plants
et_plants <- et[(substr(et$ELCODE,1,1)=="P")|(substr(et$ELCODE,1,1)=="N"), ]

# delete un-needed columns
et_plants$SWG.STATUS <- NULL
et_plants$SWG.COMMENTS <- NULL

# added rounded ranks to list
rounded_grank <- read.csv("reference_data/rounded_grank.csv",stringsAsFactors=FALSE) 
rounded_srank <- read.csv("reference_data/rounded_srank.csv",stringsAsFactors=FALSE) 
et_plants <- merge(x=et_plants, y=rounded_grank, by="G.RANK", all.x=TRUE)
et_plants <- merge(x=et_plants, y=rounded_srank, by="S.RANK", all.x=TRUE)



# find potential overlapping taxa due to subspecies/variabties
specname <- as.character(et_plants$SCIENTIFIC.NAME)
specname1 <- sub("^(.*? .*?) .*", "\\1", specname)
spec_dup <- specname1[duplicated(specname1)]
spec_dup <- spec_dup[!grepl(" x", spec_dup)] #get rid of hybrids
spec_dup <- sort(spec_dup)
spec_dup <- unique(spec_dup)

et_plants$dup <- duplicated(sub("^(.*? .*?) .*", "\\1", specname))

###  make a list of taxa we only care about at the species level!

lump_species <- c("Acaulon muticum","Alnus incana","Anemone virginiana","Arabis shortii","Arisaema triphyllum","Asclepias incarnata","Athyrium filix-femina","Aureolaria flava","Blepharostoma trichophyllum","Boehmeria cylindrica","Calamagrostis canadensis","Caltha palustris","Calycanthus floridus","Calypogeia fissa","Calypogeia muelleriana","Calystegia silvatica","Calystegia spithamaea","Cardamine parviflora","Carex atlantica","Carex canescens","Carex crinita","Carex debilis","Carex granularis","Carex laxiculmis","Carex stipata","Carex tonsa","Cephalozia bicuspidata","Cephaloziella divaricata","Cephaloziella rubella","Chamaedaphne calyculata","Chenopodium album","Chenopodium strictum","Chiloscyphus pallescens","Chiloscyphus polyanthos","Cicuta maculata","Cladonia macilenta","Collema undulatum","Conyza canadensis","Coptis trifolia","Cornus amomum","Cuscuta gronovii","Diplophyllum apiculatum","Dryopteris filix-mas","Dumortiera hirsuta","Echinochloa crusgalli","Elymus canadensis","Elymus virginicus","Equisetum hyemale","Erigeron strigosus","Eupatorium album","Eupatorium sessilifolium","Euthamia graminifolia","Fragaria vesca","Fragaria virginiana","Fraxinus americana","Galium circaezans","Gentiana andrewsii","Geum canadense","Geum laciniatum","Gymnocolea inflata","Herbertus aduncus","Hierochloe hirta","Houstonia purpurea","Hygroamblystegium tenax","Hypnum cupressiforme","Juncus effusus","Juncus tenuis","Juniperus communis","Lactuca canadensis","Lactuca floridana","Lathyrus palustris","Leptochloa fascicularis","Lespedeza capitata","Liatris scariosa","Lilium canadense","Lindernia dubia","Linum medium","Lobelia spicata","Lolium perenne","Lonicera dioica","Lophocolea cuspidata","Luzula acuminata","Lycopodium clavatum","Melampyrum lineare","Metzgeria furcata","Milium effusum","Monarda fistulosa","Nardia geoscyphus","Odontoschisma denudatum","Oenothera fruticosa","Osmunda regalis","Oxalis dillenii","Panicum amarum","Paspalum floridanum","Pellaea glabella","Persicaria amphibia","Phaeoceros laevis","Phlox divaricata","Phlox maculata","Platanthera flava","Polanisia dodecandra","Polygala senega","Polygala verticillata","Polygonatum biflorum","Polygonum aviculare","Polytrichum commune","Potamogeton alpinus","Potentilla norvegica","Proserpinaca palustris","Prunella vulgaris","Pteridium aquilinum","Ranunculus abortivus","Ranunculus hispidus","Ranunculus sceleratus","Rhus aromatica","Riccardia multifida","Rorippa palustris","Rosa carolina","Rubus idaeus","Rudbeckia fulgida","Rudbeckia hirta","Sagittaria graminea","Sagittaria latifolia","Salix humilis","Salsola kali","Scapania curta","Scapania irrigua","Scapania paludicola","Scapania undulata","Schistidium apocarpum","Scutellaria elliptica","Silene caroliniana","Solidago canadensis","Solidago gigantea","Solidago rugosa","Solidago simplex","Solidago ulmifolia","Sphenopholis obtusata","Spiranthes lacera","Sporobolus compositus" ,"Stachys hyssopifolia","Stachys palustris","Symphyotrichum lanceolatum","Symphyotrichum novi-belgii","Symphyotrichum patens","Symphyotrichum pilosum", "Symphyotrichum puniceum","Teucrium canadense","Thaspium trifoliatum","Thelypteris palustris","Tilia americana","Torreyochloa pallida","Tortella inclinata","Triodanis perfoliata","Triosteum aurantiacum","Tritomaria exsectiformis","Urtica dioica","Verbena urticifolia","Veronica peregrina","Viola macloskeyi","Viola sagittata","Vitis cinerea","Vulpia octoflora","Xanthium strumarium","Zizania aquatica","Zizania palustris")

DoNotLump <- c("Alnus viridis","Andromeda polifolia","Arabis hirsuta","Arabis laevigata","Aristida dichotoma","Aristida longespica","Artemisia campestris","Cardamine pratensis","Cerastium velutinum","Chaerophyllum procumbens","Cypripedium parviflorum","Dichanthelium commonsianum","Eleocharis obtusa","Eleocharis pauciflora","Eleocharis tenuis","Eupatorium rotundifolium","Juncus alpinoarticulatus","Lactuca hirsuta","Onosmodium molle","Paronychia fastigiata","Paspalum setaceum","Phlox subulata","Phragmites australis","Physalis pubescens","Polygonum punctatum","Polygonum ramosissimum","Prunus pumila","Pycnanthemum verticillatum","Ranunculus aquatilis","Sagittaria calycina","Schizachyrium scoparium","Sisyrinchium montanum","Solidago arguta","Solidago speciosa","Symphoricarpos albus" ,"Symphyotrichum laeve")



#get taxonomic information
taxo <- read.csv("reference_data/taxonomy.csv",stringsAsFactors=FALSE)
keeps <- c("ELEMENT_SUBNATIONAL_ID","ELCODE","CLASS","TAX_ORDER","FAMILY","GLOBAL_NAME","GLOBAL_COMNAME","PA_NAME","PA_COMNAME","CLASSIFICATION_COM","ORIGIN","REGULARITY","DIST_CONFIDENCE","CURR_PRESENCE_ABSENCE")
taxo <- taxo[keeps]

# write to the SQLite db
databasename <- "PlantConservationPlan.sqlite"
db <- dbConnect(SQLite(), dbname = databasename)
dbWriteTable(db, "et_plants",et_plants)
dbWriteTable(db, "taxo", taxo)
dbDisconnect(db)

# create a table of granks by sranks
gs_matrix <- as.data.frame.matrix(table(et_plants$Rounded.G.RANK,et_plants$Rounded.S.RANK))
gs_matrix <- cbind(rownames(gs_matrix), gs_matrix)
colnames(gs_matrix)[1] <- "rank"
