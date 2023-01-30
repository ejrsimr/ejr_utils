#!/n/apps/CentOS7/bin/Rscript --vanilla
library(tidyverse)
library(cowplot)
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} 

fasta <- args[1]

# 5 plots
lenhist <- read_tsv(paste0(fasta, ".lenhist"))
gchist <- read_tsv(paste0(fasta, ".gchist"))
cds_lenhist <- read_tsv(paste0(fasta, ".cds.lenhist"))
cds_gchist <- read_tsv(paste0(fasta, ".cds.gchist"))
cds_types <- read_tsv(paste0(fasta, ".cds_types.txt"))

p1 <- ggplot(lenhist, aes(x=Bin, y=Count)) +
  geom_bar(stat='identity') +
  theme_cowplot() +
  ggtitle("Transcript Length Histogram") +
  xlab("Length") +
  ylab("Count")

p2 <- ggplot(cds_lenhist, aes(x=Bin, y=Count)) +
  geom_bar(stat='identity') +
  theme_cowplot() +
  ggtitle("CDS Length Histogram") +
  xlab("Length") +
  ylab("Count")


p3 <- ggplot(gchist, aes(x=Bin, y=Count)) +
  geom_bar(stat='identity') +
  theme_cowplot() +
  ggtitle("Transcript %GC Histogram") +
  xlab("%GC") +
  ylab("Count")

p4 <- ggplot(cds_gchist, aes(x=Bin, y=Count)) +
  geom_bar(stat='identity') +
  theme_cowplot() +
  ggtitle("CDS %GC Histogram") +
  xlab("%GC") +
  ylab("Count")

p5 <- ggplot(cds_types, aes(x=type, y=count))+
  geom_bar(stat='identity') +
  theme_cowplot() +
  ggtitle("CDS Types") +
  xlab("Type") +
  ylab("Count")


g1 <- plot_grid(p1, p3, p2, p4, p5, labels = c('A', 'B', 'C', 'D', 'E'), ncol=2)

ggsave(paste0(fasta,".transdecoder_stats.png"), g1)
