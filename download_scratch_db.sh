#!/usr/bin/bash

mkdir /scratch/ejr/db
cd /scratch/ejr/db
wget ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/idmapping/idmapping_selected.tab.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_trembl.fasta.gz
wget ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz
wget http://current.geneontology.org/annotations/goa_uniprot_all.gaf.gz

gunzip *.gz
diamond makedb --in uniprot_trembl.fasta -o uniprot_trembl.fasta
diamond makedb --in uniprot_sprot.fasta -o uniprot_sprot.fasta
