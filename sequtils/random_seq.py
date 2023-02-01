#!/usr/bin/env python
# ejr: 2023-01-31
# lmd: 2023-02-01
# generate random sequences with a given gc content

import sys
import argparse
import signal
import random

###############################################################################
### MAIN
###############################################################################
def main():
    args = get_args()
    if args.a + args.t + args.g + args.c + args.u != 100:
       sys.exit("Base Pairs do not add up to 100") 
    if args.t > 0 and args.u > 0:
       sys.exit("Sequence can't contain both RNA and DNA nucleotides") 
    # we need to generate a 100 nucleotide string with proportions from args
    letters = ''.join("A"*args.a + "T"*args.t + "G"*args.g + "C"*args.c + "U"*args.u)
    fasta = generate_sequence(letters, args.l)
    print_fasta(fasta)

###############################################################################
### Generate random sequence with given nucleotide content
###############################################################################
def generate_sequence(letters, seqlen):
    # https://stackoverflow.com/questions/21205836/generating-random-sequences-of-dna
    # we are randomly selecting seqlen letters from letters string.
    header = "random_sequence"
    sequence = ''.join(random.choices(letters, k=seqlen))
    
    # we don't really have to format this as a fasta dictionary, but it will make
    # the code easier to reuse.
    fasta = {}
    fasta[header] = sequence
    return(fasta)

###############################################################################
### Get command-line arguments using argparse
###############################################################################
def get_args():
    parser = argparse.ArgumentParser(description="Generate Random Sequence. Base Pairs must add up to 100")
    parser.add_argument('-a', type = int, default = '25', help = 'Percentage A')
    parser.add_argument('-c', type = int, default = '25', help = 'Percentage C')
    parser.add_argument('-t', type = int, default = '25', help = 'Percentage T')
    parser.add_argument('-g', type = int, default = '25', help = 'Percentage G')
    parser.add_argument('-u', type = int, default = '0',  help = 'Percentage U')
    parser.add_argument('-l', type = int, default = '1000', help = 'Length of sequence to generate')
    args = parser.parse_args()

    return args

###############################################################################
# Print FASTA Dictionary as FASTA to STDOUT
###############################################################################
def print_fasta(fasta):
    for header in fasta:
        print(">", header, sep="")
        print(insert_newlines(fasta[header]))

###############################################################################
### Add newlines every 80 characters for FASTA formatting
###############################################################################
def insert_newlines(string, every=80):
    lines = []

    for i in range(0, len(string), every):
        lines.append(string[i:i+every])

    return '\n'.join(lines)

###############################################################################
### RUN MAIN
###############################################################################
if __name__ == "__main__":
    # this catches sigpipe errors so you don't get an error message if you tail of head output
    signal.signal(signal.SIGPIPE, signal.SIG_DFL)
    main()