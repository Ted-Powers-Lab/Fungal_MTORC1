


# Read in the library script
source(file = "~/GitHub/Fungal_MTORC1/R_Scripts/Library_Script.R")


# Read in the Taxonomy information
taxonomy_information <- read_csv(file = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs/Complete_Taxonomy_Information.csv")
taxonomy_information <- taxonomy_information %>% rename("Organism Taxonomic ID" = "Taxid")

# Read in the Potential AKTs
potential_akts <- read_csv(file = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs/Most_Likely_AKT_Proteins.csv")

potential_akts <- left_join(potential_akts, taxonomy_information, by="Organism Taxonomic ID")




