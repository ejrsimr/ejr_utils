#!/usr/bin/env python3
# ejr: 2022-11-10
# lmd: 2022-11-17
# collection of functions for FASTA and sequence manipulation

import os
import sys
import re
from re import finditer

def main():
    print("It Ran")

###############################################################################
### Read FASTA filehandle into dictionary
###############################################################################
def read_fasta(fh):
    header = ""
    fasta = {}

    for line in fh:
        line = line.rstrip()
        # starts with handles blank lines better than line[0]
        if (line.startswith(">")):
            header = line[1:]
            fasta[header] = []
        else:
            fasta[header].append(line)
    # append is more efficient that string concatenation
    for header in fasta:
        fasta[header] = ''.join(fasta[header])

    return fasta

###############################################################################
### Add newlines every 80 characters for FASTA formatting
###############################################################################
def insert_newlines(string, every=80):
    lines = []

    for i in range(0, len(string), every):
        lines.append(string[i:i+every])

    return '\n'.join(lines)

###############################################################################
# Reverse Complement Sequence
###############################################################################
def reverse_complement(seq):
    # complement sequence
    bases = str.maketrans('AGCTagct','TCGAtcga')
    # reverse sequences; return
    return seq.translate(bases)[::-1]

###############################################################################
# Print FASTA Dictionary as FASTA to STDOUT
###############################################################################
def print_fasta(fasta):
    for header in fasta:
        print(">", header, sep="")
        print(insert_newlines(fasta[header]))

###############################################################################
# calculate GC content of sequence - returns percentage in decimal (e.g. 0.21)
###############################################################################    
def calc_gc(seq):
    useq = seq.upper()
    g = useq.count('G')
    c = useq.count('C')
    a = useq.count('A')
    t = useq.count('T')
    if g + c + a + t > 0: 
        perc_gc = (g + c) / (g + c + a + t)
    else:
        perc_gc = 0
    return(perc_gc)

###############################################################################
# Run MAIN
###############################################################################
if __name__ == "__main__":
    main()
