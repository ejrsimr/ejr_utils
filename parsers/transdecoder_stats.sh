#!/usr/bin/bash
# ejr: 2022-06-23
# calculate statistics for Transdecoder output

# input is the name of the FASTA file Transdecoder was run on
FILE=$1

fastatools histogram -gc ${FILE} > ${FILE}.gchist
fastatools histogram -gc ${FILE}.transdecoder.cds > ${FILE}.cds.gchist

fastatools histogram -len ${FILE}> ${FILE}.lenhist
fastatools histogram -len ${FILE}.transdecoder.cds > ${FILE}.cds.lenhist


grep ">" ${FILE}.transdecoder.cds | perl -p -e 's/.+type:(.+?) .*/$1/' | sort | uniq -c | awk 'BEGIN{print "type\tcount"} {print $2 "\t" $1}' > ${FILE}.cds_types.txt

# run R stats app

transdecoder_stats_figures.R ${FILE}
