source(file = "~/GitHub/Fungal_MTORC1/R_Scripts/Library_Script.R")



# Read in the Taxonomy Information (2 Files)

Genome_Information <- read_tsv(file = "~/GitHub/Fungal_MTORC1/Tables/Complete_Eukaryote_Genome_Information.tsv")
# May need to redo the Taxon Information as it is lacking
Taxon_Information <- read_tsv(file = "~/GitHub/Fungal_MTORC1/Tables/Kingdom_Information_Eukaryotes.tsv")



