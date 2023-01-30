# sequtils
Created by: ejr  
Last modified date: 2022-11-17    

General purpose DNA/RNA sequence utilities. Some of these are my own implementations of common tools with minor input and output changes to align with my personal preferences.  

## fasta_filter
Filter FASTA file for length and gc content.  

## fasta_regex
Search for regular expression in fasta file, return BED file of loci.  

## fasta_retrieve
Retrieve sequences from FASTA formatted file based on file of complete or partial sequence names.  Can also retrieve all sequences, which do not match the patterns.  

## fasta_stats
Get descriptive statistics of FASTA formatted file.  

## fasta_utils.py
Contains functions for other scripts.  

## fasta2gc
Get table of per sequence gc content from FASTA formatted file.  

## fasta2histograms
Writes png histograms for per sequence GC content and lengths.  

## fasta2len
Get table of per sequence lengths from FASTA formatted file.  

## fasta2tab 
Convert FASTA formatted files to tabular format.  

## fasta_itrs
Experimental: find ITRs in FASTA file. return BED.  

## tab2fasta
Convert tabular sequence data to FASTA format.  