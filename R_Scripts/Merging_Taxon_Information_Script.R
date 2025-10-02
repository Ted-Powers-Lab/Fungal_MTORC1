


source(file = "~/GitHub/Fungal_MTORC1/R_Scripts/Library_Script.R")


# Read in the list of taxonomy tsvs

file_list <- list.files(path = "~/GitHub/AKT_Research/CSV_Files/Combined_TSVs/Taxonomy_Information",
                        pattern = "\\.*tsv",
                        full.names = TRUE)

list_of_tibbles <- map(file_list, read_tsv, show_col_types = FALSE)
Combined_taxonomy_data <- bind_rows(list_of_tibbles)
Combined_taxonomy_data <- Combined_taxonomy_data %>% select(-Query, -Authority, -Rank, -Basionym, -`Basionym authority`, -`Curator common name`, -`Has type material`, -`Scientific name is formal`)
Combined_taxonomy_data %>% filter(Taxid == 412133 )




write_csv(Combined_taxonomy_data, file = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs/Complete_Taxonomy_Information.csv")

