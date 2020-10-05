# Arjun Manrai
# Creates a regions file for bcftools from a sql db

library(RSQLite)
library(tidyverse)

prefix <- "../../data/"

# load SQL db
db.location <- paste0(prefix, "prebuilt-dbs/clinvar_grch38.db")
conn <- dbConnect(RSQLite::SQLite(), db.location)

res <- as_tibble(dbGetQuery(conn, "SELECT CHROM, POS
                              FROM clinvar"))

dbDisconnect(conn)

res$CHROM <- paste0('chr',res$CHROM)
res

out <- paste0(prefix,"clinvar/regions_grch38.tsv")
write_tsv(res, out, col_names = F)
