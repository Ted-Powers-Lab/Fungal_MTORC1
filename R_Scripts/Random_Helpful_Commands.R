df_in <- data.frame(
  ID = c(1, 1, 2, 2, 2),
  Category = c("A", "A", "B", "B", "B"),
  Value = c("apple", "banana", "orange", "grape", "kiwi")
)

# Combine 'Value' column into a single string per 'ID' and 'Category' group
df_combined <- df_in %>%
  group_by(ID, Category) %>%
  summarise(Combined_Value = paste0(Value, collapse = ", ")) %>%
  ungroup()

print(df_combined)
