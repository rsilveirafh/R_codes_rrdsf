# Arranging data downloaded from TRY (try-db.org)
# Ricardo Silveira-Filho, January/2019
# ricardodasilveira@gmail.com
# https://github.com/rsilveirafh/R_Codes_RSF

#Setting the Working Directory
setwd("your/wd/here")

# Loading the try database, usually a *.txt file
# The "quoting" argument have to be disabled, mainly for larger files
# To find out the "fileEncoding": install the readr package
install.packages("readr", dependencies = TRUE)

# Run the following command: guess_encoding("file.txt", n_max = 1000)
library(readr)
guess_encoding("try.txt", n_max=1000)

# Replace the encoding characteristics into the following:
try_all <- read.delim("try.txt", fileEncoding= "ISO-8859-1", sep = "\t", stringsAsFactors = FALSE, quote = "")

# Install the packages "dplyr", "tidyr" and "stringr" using install.packages()
library(dplyr)
library(tidyr)
library(stringr)

# Selecting important columns, transforming data.frame to tibble
t <- try_all %>% 
   dplyr::select(ObservationID, AccSpeciesName, TraitID, TraitName, DataID, DataName, OrigValueStr, OrigUnitStr, StdValue, UnitName) %>%
   arrange(ObservationID, AccSpeciesName) %>%
   as_tibble()

# The "standard" numeric values are in the StdValue column
# Creating a new column with StdValue values
t$correct_value <- t$StdValue
t$correct_value[t$correct_value==""] <- NA
# Criando uma nova coluna com as unidades de medida relativas a StdValue
# Os NA precisam ser adicionados posteriormente por se tratar de uma variavel <chr>
# Creating a new column with measure units relative to StdValue
# NAs need to be added later because it is a <chr> variable
t$correct_unit <- t$UnitName
t$correct_unit[t$correct_unit==""] <- NA

# Adding the values from OrigValue to correct_value
# Legend -> If there is NA in correct_value, replace it with the values of OrigValueStr
t$correct_value[is.na(t$correct_value)] <- t$OrigValueStr[is.na(t$correct_value)] 
# Same for measurement units
t$correct_unit[is.na(t$correct_unit)] <- t$OrigUnitStr[is.na(t$correct_unit)]

# Are there traits with more than 1 measure unit?
DuplTraitsUnit <- table(t$correct_unit, t$TraitName)
DuplTraitsUnit[apply(DuplTraitsUnit > 0, 1, sum) > 1,]
#*** Check manually, automatize later

# Plant growth form tem medida em branco e grama
# Plant growth form has blank measures and g
# Fixing it
t$TraitName[str_detect(t$TraitName, "Plant growth form") & str_detect(t$correct_unit, "")] <- "Plant growth form categorical"
t$TraitName[str_detect(t$TraitName, "Plant growth form") & str_detect(t$correct_unit, "g")] <- "Plant growth form continuous"

t %>%
   filter(str_detect(TraitName, "Plant growth form")) %>% 
   count(TraitName)


t$TraitName[str_detect(t$TraitName, "Plant growth form") & str_detect(t$correct_unit, "g")]

# Creating a folder named "Result"
if (dir.exists("Result/") == FALSE) {dir.create("Result/")}

# Object containing the measure units of the Traits
UnitTraits <- t %>%
   dplyr::select(TraitID, TraitName, correct_unit) %>%
   subset(TraitID != "") %>%
   arrange(TraitID) %>%
   distinct()
write.csv(UnitTraits, "Result/UnitTraits.csv")

# Object containing the other measurement units
UnitEnv <- t %>%
   filter(TraitName == "") %>%
   dplyr::select(DataName, correct_unit) %>%
   arrange(DataName) %>%
   rename(EnvName = DataName) %>%
   distinct()
write.csv(UnitEnv, "Result/UnitEnv.csv")

# Number of species for each trait
write.csv(apply(table(t$AccSpeciesName, t$TraitName(!is.na())) > 0, 2, sum), "Result/TraitSpeciesNumber.csv")

# Organizing according to ObservationID
LatLong <- t %>% 
   dplyr::select(ObservationID, AccSpeciesName, DataName, correct_value) %>%
   filter(DataName %in% c("Latitude", "Longitude")) %>%
   distinct() %>%
   spread(DataName, correct_value)
write.csv(LatLong, "Result/LatLong.csv")

# If ObservationID has 2 lines with equal TraitName, make two different columns

# Arrange Traits by ObservationID
TraitsByObservationID <- t %>%
   dplyr::select(ObservationID, AccSpeciesName, TraitName, correct_value) %>%
   subset(TraitName != "") %>%
   distinct() %>%
   mutate(id=1:n()) %>%
   spread(TraitName, correct_value) %>%
   group_by(ObservationID) %>%
   summarise_all(funs(first(na.omit(.)))) %>%
   arrange(ObservationID) %>%
   dplyr::select(-id)
write.csv(TraitsByObservationID, "Result/TraitsByObservationID.csv")   

# Adding LatLong into the try_final object
try_final <- merge(TraitsByObservationID, LatLong) %>% arrange(ObservationID)
write.csv(try_final, "try_final.csv")



