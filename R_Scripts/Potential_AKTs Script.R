



source(file = "~/GitHub/Fungal_MTORC1/R_Scripts/Library_Script.R")


# Load in some information to tie the target proteins to a species
additional_info <- read_csv(file = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs/Combined_AKT_Potential.csv")

# Load in the list of files
file_list_of_tibbles_tsv <- list.files(path = "~/GitHub/AKT_Research/CSV_Files/Combined_TSVs",
                                  pattern = "\\.*tsv",
                                  full.names = TRUE)
# Read in the csvs and append them to a list
# Add in a header row for each of the files
list_of_tibbles <- map(file_list_of_tibbles_tsv, read_tsv, show_col_types = FALSE)
new_column_names <- c("tar", "seq_md5", "seq_length", "Analysis",
                      "sig_acc", "sig_desc", "start", "stop",
                      "e_value", "status", "date", "ipr_acc", "ipr_desc")

renamed_list_setnames <- map(list_of_tibbles, ~ setNames(.x, new_column_names))
#Remove any empty csv files as they are unneeded.
filtered_tibbles <- keep(renamed_list_setnames, ~nrow(.x) > 1)

Combined_data <- bind_rows(filtered_tibbles)
#Remove some extraneous rows
Combined_data <- select(Combined_data, -c(14, 15))

# Keep the raw data for future usage
raw_data <- Combined_data
# Remove some unneeded/redundant columns
Combined_data <- group_by(Combined_data, tar) %>%
  select(-seq_md5, -date, -status, -ipr_acc, -ipr_desc)

# This assigns all of the values in the sig_desc to a new column
# This is later used for finding most likely AKT proteins
Potentials <- Combined_data %>% group_by(tar)%>%
  summarise(All_Domains = paste0(sig_desc, collapse = ", "))%>%
  ungroup()

# Combine the potential data to the combined master data
Combined_data <- left_join(Combined_data, Potentials, by = "tar")
# Order things alphabetically for further filtering
Combined_data <- Combined_data[order(Combined_data$All_Domains),]
Combined_data %>% group_by(All_Domains)%>%summarise(n_of_obs = n()) %>% view()

Combined_data %>% group_by(All_Domains)%>% summarise(Number_of_obs = n()) %>% view()


Result <- Combined_data %>% filter(All_Domains == "PH domain, Protein kinase C terminal domain, Protein kinase domain") %>% view()
Result <- left_join(Result, additional_info[c("tar", "acc", "Organism Name", "Organism Taxonomic ID")], by = "tar")
Result <- Result %>% distinct()


write_csv(Result, file = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs/Most_Likely_AKT_Proteins.csv")

# Even more filtering work with conditionals checking the ranges the different domains fall
