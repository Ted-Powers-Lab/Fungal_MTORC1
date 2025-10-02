
# Read in the standard library script

source(file = "~/GitHub/Fungal_MTORC1/R_Scripts/Library_Script.R")


file_list <- list.files(path = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs",
                       pattern = "\\.*csv",
                       full.names = TRUE)

list_of_tibbles <- map(file_list, read_csv, show_col_types = FALSE)
list_of_tibbles
filtered_tibbles <- keep(list_of_tibbles, ~nrow(.x) > 1)
filtered_tibbles

Combined_data <- bind_rows(filtered_tibbles)

write_csv(Combined_data, file = "~/GitHub/AKT_Research/CSV_Files/Combined_CSVs/Combined_AKT_Potential.csv")








