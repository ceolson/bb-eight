library(stringr)
library(tidyverse)

#dataset <- 'HVH' # HVH, JHS, MESA, FHS...etc.
#src.directory <- paste0(dataset)

num.variants <- 2572
num.ind <- 50

G <- matrix(nrow=num.ind,ncol=num.variants)

f = read_tsv('ex_nwd.vcf',
             col_names=c('CHROM','POS','RSID','REF','ALT','QUAL','FILTER','INFO','FORMAT','GT'))
r = f$RSID
g = unlist(strsplit(f$GT,'|'))
g = as.integer(g[-which(g == '|')])
genotypes <- g[c(TRUE,FALSE)] + g[c(FALSE,TRUE)]
G[i,] <- genotypes
