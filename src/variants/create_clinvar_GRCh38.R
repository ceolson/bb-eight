# Arjun Manrai
# NHLBI BDC

# libraries
library(RSQLite)
library(tidyverse)

# helper functions
filter.geneinfo <- function(panel, df) {
  panel <- paste0(panel,':')
  s  <- paste0('GENEINFO=',paste0(panel,collapse = '|GENEINFO='))
  df <- df %>%
    filter(grepl(s,INFO))
  return(df)
}

annotate.clnsig <- function(info) {
  pattern <- "CLNSIG=[^;]*;"
  clnsig <- str_extract(info,pattern)
  clnsig <- substr(clnsig,8,nchar(clnsig)-1)
  return(clnsig)
}

onehot.clnsig <- function(df) {
  df <- df %>%
    mutate(VUS = ifelse(CLNSIG=='Uncertain_significance',1,0)) %>%
    mutate(Pathogenic = ifelse(CLNSIG=='Pathogenic' | CLNSIG=='Pathogenic/Likely_pathogenic',1,0)) %>%
    mutate(LikelyPathogenic = ifelse(CLNSIG=='Likely_pathogenic',1,0)) %>%
    mutate(Conflicting = ifelse(CLNSIG=='Conflicting_interpretations_of_pathogenicity',1,0))
  return(df)
}

# main
# download GRCh38 from https://www.ncbi.nlm.nih.gov/genome/guide/human/
src.directory <- '../../data/clinvar/'
clinvar <- read_tsv(paste0(src.directory,'GRCh38_latest_clinvar.vcf'),
                 comment='#',
               col_names = c('CHROM','POS','ID','REF',
                             'ALT','QUAL','FILTER','INFO'))
panel <- c('MYH7','TNNT2','MYBPC3','TPM1','MYL3','TNNI3','MYL2','ACTC1')
clinvar <- filter.geneinfo(panel,clinvar)
clinvar$CLNSIG <- annotate.clnsig(clinvar$INFO)
clinvar <- onehot.clnsig(clinvar)
clinvar <- clinvar %>%
  mutate_all(type.convert) %>%
  mutate_if(is.double,as.integer)

# merge rsids from ex. vcf to create merged lookup table
#f = read_tsv('ex_nwd.vcf',
#             col_names=c('CHROM','POS','RSID','REF','ALT','QUAL','FILTER','INFO','FORMAT','GT'))
#f$POS = as.integer(f$POS)
#clinvar$CHROM <- paste0('chr',clinvar$CHROM)
#merged.clinvar <- as_tibble(merge(clinvar,f,by = c('CHROM','POS','REF','ALT'),
#                        all.x = FALSE,all.y = FALSE))
#merged.clinvar <- merged.clinvar %>%
#  select(CHROM,POS,REF,ALT,RSID,VUS,Pathogenic,LikelyPathogenic,Conflicting)

# summarize
#clinvar %>% group_by(CLNSIG) %>% summarise(n=n(),pct=100*n/nrow(clinvar)) %>% arrange(desc(n))

# store as SQLite db
remove_existing_db <- 1 # warning this will delete previous db!
if (remove_existing_db) {
  file.remove("../../data/prebuilt-dbs/clinvar_grch38.db")
}
conn <- dbConnect(RSQLite::SQLite(), "../../data/prebuilt-dbs/clinvar_grch38.db")
dbWriteTable(conn, "clinvar", clinvar)
dbListTables(conn) # double check table was created
dbDisconnect(conn)
