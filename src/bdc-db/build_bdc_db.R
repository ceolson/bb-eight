#!/usr/bin/env Rscript

library(stringr)
library(tidyverse)

gen.src <- '../../g'
clin.src <- '../../p'

source('combine_geno.R')
source('pic-sure-extract_pheno.R')
source('bdc_db.R')
