source(file = "~/GitHub/Fungal_MTORC1/R_Scripts/Library_Script.R")

# Need to add a "combined GAD8 potential csv list here


file_list_of_tibbles_tsv <- list.files(path = "~/GitHub/AKT_Research/CSV_Files/Combined_TSVs/GAD8",
                                       pattern = "\\.*tsv",
                                       full.names = TRUE)


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


Combined_data <- group_by(Combined_data, tar) %>%
  select(-seq_md5, -date, -status, -ipr_acc, -ipr_desc)


Potentials <- Combined_data %>% group_by(tar)%>%
  summarise(All_Domains = paste0(sig_desc, collapse = ", "))%>%
  ungroup()

Combined_data <- left_join(Combined_data, Potentials, by = "tar")
Combined_data <- Combined_data[order(Combined_data$All_Domains),]

Combined_data %>% group_by(All_Domains)%>% summarise(Number_of_obs = n()) %>% view()
