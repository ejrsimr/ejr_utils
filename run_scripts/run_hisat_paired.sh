#!/usr/bin/env bash

#  /n/projects/ejr/src/hisat2-2.1.0/hisat2-build -p 64 genome.fa genome.fa
# SAMPLESFILE shoudl be in format SAMPLE FASTQs FASTQs
# FASTQs are separated by ","
# run_hisat.sh index samplesfile

THREADS=48
INDEX=$1
SAMPLES=$2
CMD="/n/projects/ejr/src/hisat2-2.1.0/hisat2"
TMP=`mktemp -d -p /scratch/ejr`


# read in two columns from each line of samples file
cat ${SAMPLES} | while read line
do
    COLS=()

for val in $line
do
    COLS+=("${val}")
done

${CMD} \
-x ${INDEX} \
--fr \
--dta \
-p ${THREADS} \
-1 ${COLS[1]} \
-2 ${COLS[2]} \
| samtools view -F 4 -@ 4 -u - \
| samtools sort -m 8G -@ 4 -T temp -O bam -o ${TMP}/${COLS[0]}_hisat2.bam

# copy counts file to current directory
cp ${TMP}/${COLS[0]}_hisat2.bam ${COLS[0]}_hisat2.bam

done
