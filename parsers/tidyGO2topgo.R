#!/usr/bin/env Rscript

library(tidyverse)

df <- read_tsv("/n/sci/SCI-003983-SBSMED/smes_v2_hconf/GO/20190603/smest2go.txt")

topdf <- df %>%
    group_by(smest_id) %>%
    mutate(goterm = paste(goterm,collapse=", ")) %>%
    distinct()

write_tsv(topdf, "/n/sci/SCI-003983-SBSMED/smes_v2_hconf/GO/20190603/smest2topgo.txt")
