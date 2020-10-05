#!/usr/bin/env Rscript

library(stringr)

dataset <- 'MESA'
src.directory <- paste0('../project-files/',dataset)
dir.create(dataset,showWarnings=FALSE)
out.directory <- paste0(dataset,'/')

filenames <- list.files(src.directory, pattern="NWD.*\\.vcf.gz$", full.names=T)
filenames_to_use <- filenames

for (i in 1:length(filenames_to_use)) {
    filename <- filenames[i]
    pattern <- "NWD[0-9]*."
    NWD <- str_extract(filename,pattern)
    NWD <- substr(NWD,1,nchar(NWD)-1)
    command <- paste0('bcftools view -R regions_grch38.tsv ',filename,' | grep "^[^#;]" > ',out.directory,NWD,'.vcf')
    system(command,wait=TRUE)
    print(paste0(i," of ",length(filenames_to_use)," done"))
}
