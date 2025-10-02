


# Read in the library script
source(file = "~/GitHub/Fungal_MTORC1/R_Scripts/Library_Script.R")


# Read in the Taxonomy information
taxonomy_information <- read_csv(file = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs/Complete_Taxonomy_Information.csv")
taxonomy_information <- taxonomy_information %>% rename("Organism Taxonomic ID" = "Taxid")

# Read in the Potential AKTs
potential_akts <- read_csv(file = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs/Most_Likely_AKT_Proteins.csv")

potential_akts <- left_join(potential_akts, taxonomy_information, by="Organism Taxonomic ID")

#potential_gad8s <- read_csv(file = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs/Most_Likely_GAD8_Proteins.csv")
#potential_gad8s <- left_join(potential_gad8s, taxonomy_information, by = "Organism Taxonomic ID")

simplified_potential_akts <- potential_akts %>% select(-sig_acc, -sig_desc, -start, -stop, -e_value) %>% distinct(tar, .keep_all = TRUE)




