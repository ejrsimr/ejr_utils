#!/usr/bin/bash
# run script with input FASTA file as only parameter

source "/home/ejr/anaconda3/etc/profile.d/conda.sh"
conda activate raxml
TRIMAL="trimal"
MUSCLE="/n/apps/CentOS7/bin/muscle"
PHYUTILITY="/n/projects/ejr/src/phyutility/phyutility"
NEXUS2PHYLIP="/n/projects/ejr/src/Alignment_formatting/nexus2phylip.pl"
RAXML="raxml-ng"
# Number of threads for RAxML
THREADS=16
# Number of iterations for RAxML
ITER=500
# random number generator seed
SEED=12345

# align sequences
${MUSCLE} -in ${1} -out ${1}.aln
# trim alignment to remove low information content amino acids
${TRIMAL} -automated1 -in ${1}.aln -out ${1}.trimal.aln
# convert alignment to phylip format for RAxML
${PHYUTILITY} -concat -in ${1}.trimal.aln -out ${1}.concatenated.aln
${NEXUS2PHYLIP} ${1}.concatenated.aln > ${1}.concatenated.phylip



# output will be: RAxML_bestTree.${i}
# Run RAxML
#${RAXML} --bootstrap --msa ${1}.concatenated.phylip --model PROTGTR+G --prefix Girardia --threads 16 --seed ${SEED}

#${RAXML} --bsconverge --bs-trees Girardia.raxml.bootstraps --prefix Girardiabs --seed ${SEED} --threads 16 --bs-cutoff 0.01

${RAXML} --bs-trees Girardia.raxml.bootstraps --msa ${1}.concatenated.phylip --model PROTGTR+G --prefix Girardia --threads 16 --seed ${SEED}

# REFERENCE
#A. Stamatakis: "RAxML Version 8: A tool for Phylogenetic Analysis and Post-Analysis of Large Phylogenies". 
#Bioinformatics (2014) 30 (9): 1312-1313.
