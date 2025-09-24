source(file = "~/GitHub/Fungal_MTORC1/R_Scripts/Library_Script.R")


Genome_Information <- read_tsv(file = "~/GitHub/Fungal_MTORC1/Tables/Complete_NCBI_Table_Information_No_Filter.tsv")

Genome_Information <- Genome_Information %>% rename("acc" = "Assembly Accession",
                                                    "Organism_Name" = "Organism Name",
                                                    "Species taxid" = "Organism Taxonomic ID")
Genome_Information <- Genome_Information %>% select(acc, Organism_Name, "Species taxid")



Taxon_Information <- read_tsv(file = "~/GitHub/Fungal_MTORC1/Tables/taxonomy_summary_Stramenopiles.tsv")

Taxon_Information <- Taxon_Information %>% rename("Organism_Name" = "Species name") %>%
  select("Group name", 
         "Domain/Realm name", 
         "Kingdom name", 
         "Phylum name", 
         "Class name", 
         "Order name", 
         "Family name",
         "Genus name",
         "Organism_Name",
         "Species taxid") %>%
  drop_na("Organism_Name") %>%
  distinct()


RawStramTCO <- read_csv(file = "~/GitHub/Fungal_MTORC1/Tables/TCO89_Stramenopiles_Combined.csv")

StramTCO <- RawStramTCO %>% rename("full_e_tco" = "full_e",
                                 "full_score_tco" = "full_score",
                                 "full_bias_tco" = "full_bias",
                                 "dom_e_tco" = "dom_e",
                                 "dom_score_tco" = "dom_score",
                                 "dom_bias_tco" = "dom_bias",
                                 "tar_tco" = "tar") %>%
  slice_max(order_by = full_score_tco, by=acc) %>%
  filter(full_score_tco >= 30)

# Literally no results for TCO89 in Stramenopiles

StramTCO <- left_join(StramTCO, Genome_Information, by = "acc")
StramTCO <- left_join(StramTCO, Taxon_Information[c("Group name", "Domain/Realm name", "Kingdom name", "Phylum name", "Class name", "Order name", "Family name", "Genus name", "Species taxid")], by = "Species taxid")


RawStramRAPTOR <- read_csv(file = "~/GitHub/Fungal_MTORC1/Tables/RAPTOR_Stramenopiles_Combined.csv")

StramRAPTOR <- RawStramRAPTOR %>% rename("full_e_RAPTOR" = "full_e",
                                       "full_score_RAPTOR" = "full_score",
                                       "full_bias_RAPTOR" = "full_bias",
                                       "dom_e_RAPTOR" = "dom_e",
                                       "dom_score_RAPTOR" = "dom_score",
                                       "dom_bias_RAPTOR" = "dom_bias",
                                       "tar_RAPTOR" = "tar") %>%
  slice_max(order_by = full_score_RAPTOR, by=acc)%>%
  filter(full_score_RAPTOR >= 100)


StramRAPTOR <- left_join(StramRAPTOR, Genome_Information, by = "acc")
StramRAPTOR <- left_join(StramRAPTOR, Taxon_Information[c("Group name", "Domain/Realm name", "Kingdom name", "Phylum name", "Class name", "Order name", "Family name", "Genus name", "Species taxid")], by = "Species taxid")


CombinedStramData <- full_join(StramTCO[c("tar_tco", "full_e_tco", "full_score_tco", "full_bias_tco", "dom_e_tco", "dom_score_tco", "dom_bias_tco", "acc")], StramRAPTOR, by = "acc")
CombinedStramData <- CombinedStramData %>%
  mutate(ProteinPresence = case_when(!is.na(full_score_RAPTOR) & !is.na(full_score_tco) ~ "TCO and RAPTOR",
                                     !is.na(full_score_RAPTOR) & is.na(full_score_tco) ~ "RAPTOR Only",
                                     is.na(full_score_RAPTOR) & !is.na(full_score_tco) ~ "TCO Only",
                                     is.na(full_score_RAPTOR) & is.na(full_score_tco) ~ "None",
                                     .default = "None"))%>%
  relocate("Organism_Name", "Group name", "Domain/Realm name", "Kingdom name", "Phylum name", "Class name", "Order name", "Family name", "Genus name", "Species taxid", "acc", "query")%>%
  select(-hmm_acc, -tar_acc)%>%
  drop_na("Organism_Name")




CombinedStramData %>% group_by(`Phylum name`, ProteinPresence)%>%
  summarize(count = n())%>%
  rename("Number_of_Organisms" = count) %>%
  ggplot(aes(x = `Phylum name`, y = Number_of_Organisms, fill = ProteinPresence))+
  geom_bar(stat = "identity", position = "dodge")+
  theme_minimal()+
  ggtitle("Presence of Tco89 and RAPTOR/KOG1 in Fungi")+
  ylab("Number of Organisms per Phylum")
