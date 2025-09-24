source(file = "~/GitHub/Fungal_MTORC1/R_Scripts/Library_Script.R")



# Read in the Taxonomy Information (2 Files)

Genome_Information <- read_tsv(file = "~/GitHub/Fungal_MTORC1/Tables/Fungi_Genome_Information.tsv")

Genome_Information <- Genome_Information %>% rename("acc" = "Assembly Accession",
                                                    "Organism_Name" = "Organism Name",
                                                    "Species taxid" = "Organism Taxonomic ID")
Genome_Information <- Genome_Information %>% select(acc, Organism_Name, "Species taxid")





# May need to redo the Taxon Information as it is lacking
# This will be done on the cluster using the ncbi dataset program

Taxon_Information <- read_tsv(file = "~/GitHub/Fungal_MTORC1/Tables/taxonomy_summary.tsv")

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








# Read in the csvs for Fungal Tco89 and for Fungal RAPTOR
# Rename the specific columns as needed (tidyverse method)
# Also going to select for the maximum value for each just to remove any stragglers
# These results will be in a "cleaned" output dataframe
# This will have the downside of missing copied events but for the most part we are ignoring that
# 

RawFungTCO <- read_csv(file = "~/GitHub/Fungal_MTORC1/Tables/PF01452_Combined.csv")

FungTCO <- RawFungTCO %>% rename("full_e_tco" = "full_e",
                                 "full_score_tco" = "full_score",
                                 "full_bias_tco" = "full_bias",
                                 "dom_e_tco" = "dom_e",
                                 "dom_score_tco" = "dom_score",
                                 "dom_bias_tco" = "dom_bias",
                                 "tar_tco" = "tar") %>%
  slice_max(order_by = full_score_tco, by=acc) %>%
  filter(full_score_tco >= 30)


FungTCO <- left_join(FungTCO, Genome_Information, by = "acc")
FungTCO <- left_join(FungTCO, Taxon_Information[c("Group name", "Domain/Realm name", "Kingdom name", "Phylum name", "Class name", "Order name", "Family name", "Genus name", "Species taxid")], by = "Species taxid")


RawFungRAPTOR <- read_csv(file = "~/GitHub/Fungal_MTORC1/Tables/RAPTOR_Fungal.csv")

FungRAPTOR <- RawFungRAPTOR %>% rename("full_e_RAPTOR" = "full_e",
                         "full_score_RAPTOR" = "full_score",
                         "full_bias_RAPTOR" = "full_bias",
                         "dom_e_RAPTOR" = "dom_e",
                         "dom_score_RAPTOR" = "dom_score",
                         "dom_bias_RAPTOR" = "dom_bias",
                         "tar_RAPTOR" = "tar") %>%
  slice_max(order_by = full_score_RAPTOR, by=acc)%>%
  filter(full_score_RAPTOR >= 100)






FungRAPTOR <- left_join(FungRAPTOR, Genome_Information, by = "acc")
FungRAPTOR <- left_join(FungRAPTOR, Taxon_Information[c("Group name", "Domain/Realm name", "Kingdom name", "Phylum name", "Class name", "Order name", "Family name", "Genus name", "Species taxid")], by = "Species taxid")







CombinedFungalData <- full_join(FungTCO[c("tar_tco", "full_e_tco", "full_score_tco", "full_bias_tco", "dom_e_tco", "dom_score_tco", "dom_bias_tco", "acc")], FungRAPTOR, by = "acc")
CombinedFungalData <- CombinedFungalData %>%
  mutate(ProteinPresence = case_when(!is.na(full_score_RAPTOR) & !is.na(full_score_tco) ~ "TCO and RAPTOR",
                                     !is.na(full_score_RAPTOR) & is.na(full_score_tco) ~ "RAPTOR Only",
                                     is.na(full_score_RAPTOR) & !is.na(full_score_tco) ~ "TCO Only",
                                     is.na(full_score_RAPTOR) & is.na(full_score_tco) ~ "None",
                                     .default = "None"))%>%
  relocate("Organism_Name", 
           "Group name", 
           "Domain/Realm name", 
           "Kingdom name", 
           "Phylum name", 
           "Class name", 
           "Order name", 
           "Family name", 
           "Genus name", 
           "Species taxid", 
           "acc", 
           "query")%>%
  select(-hmm_acc, -tar_acc)%>%
  drop_na("Organism_Name")


  
CompleteGraphPhylum <- CombinedFungalData %>% group_by(`Phylum name`, ProteinPresence)%>%
  summarize(count = n())%>%
  rename("Number_of_Organisms" = count) %>%
  ggplot(aes(x = Number_of_Organisms, y = `Phylum name` , fill = ProteinPresence))+
  geom_bar(stat = "identity", position = "dodge")+
  theme_bw()+
  ggtitle("Presence of Tco89 and RAPTOR/KOG1 in Fungi")+
  ylab("Phylum Name")+
  xlab("Number of Organisms")

CompleteGraphPhylum


CompleteGraphClass <- CombinedFungalData %>% group_by(`Class name`, ProteinPresence)%>%
  summarize(count = n())%>%
  rename("Number_of_Organisms" = count) %>%
  ggplot(aes(x = Number_of_Organisms, y = `Class name` , fill = ProteinPresence))+
  geom_bar(stat = "identity", position = "dodge")+
  theme_bw()+
  ggtitle("Presence of Tco89 and RAPTOR/KOG1 in Fungi")+
  ylab("Class Name")+
  xlab("Number of Organisms")


CompleteGraphClassNoNA <- CombinedFungalData %>% drop_na(`Class name`) %>% 
  group_by(`Class name`, ProteinPresence)%>%
  summarize(count = n())%>%
  rename("Number_of_Organisms" = count) %>%
  ggplot(aes(x = Number_of_Organisms, y = `Class name` , fill = ProteinPresence))+
  geom_bar(stat = "identity", position = "dodge")+
  theme_bw()+
  ggtitle("Presence of Tco89 and RAPTOR/KOG1 in Fungi")+
  ylab("Class Name")+
  xlab("Number of Organisms")


CompleteGraphClassNoNA

FilteredOnlyAscomycota <- CombinedFungalData %>% filter(`Phylum name` == "Ascomycota")%>%
  group_by(`Class name`, ProteinPresence)%>%
  summarize(count = n())%>%
  rename("Number_of_Organisms" = count) %>%
  ggplot(aes(x = Number_of_Organisms, y = `Class name`, fill = ProteinPresence))+
  geom_bar(stat = "identity", position = "dodge")+
  theme_bw()+
  ggtitle("Presence of Tco89 and RAPTOR/KOG1 in Fungi")+
  ylab("Class Names")+
  xlab("Number of Organisms")


FilteredOnlyAscomycota





ggsave("~/GitHub/Fungal_MTORC1/Charts/CompleteGraphPhylum.png",
       plot = CompleteGraphPhylum,
       height = 12,
       width = 16,
       dpi = 600)

ggsave("~/GitHub/Fungal_MTORC1/Charts/CompleteGraphClass.png",
       plot = CompleteGraphClass,
       height = 12,
       width = 16,
       dpi = 600)

ggsave("~/GitHub/Fungal_MTORC1/Charts/CompleteGraphClassNoNA.png",
       plot = CompleteGraphClassNoNA,
       height = 12,
       width = 16,
       dpi = 600)

ggsave("~/GitHub/Fungal_MTORC1/Charts/FilteredAscomycota.png",
       plot = FilteredOnlyAscomycota,
       height = 12,
       width = 16,
       dpi = 600)



OnlyTCO89 <- CombinedFungalData %>% filter(`ProteinPresence` == 'TCO and RAPTOR')
write_csv(OnlyTCO89, file = "~/GitHub/Fungal_MTORC1/Tables/TCO89_And_RAPTOR_Table_Fungi.csv")
write_csv(CombinedFungalData, file = "~/GitHub/Fungal_MTORC1/Tables/Complete_Master_Table_Fungi.csv")








# Do we want to get rid of scores below a certain threshold?








