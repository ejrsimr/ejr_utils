#!/usr/bin/env python
# ejr: 2022-09-02
# run STAR alignment from simr Sample_Report.csv file
# We provide the sequence directory separately from the Sample_report.csv so that
# we can use a modifed file removing unwanted samples of combining samples.

### IMPORT ####################################################################
import sys
import argparse
import tempfile
import pandas as pd
import os
import shutil

### MAIN ######################################################################
def main():

    # get command line arguments
    args = get_args()

    # create temporary directory on local storage
    temp_dir = tempfile.TemporaryDirectory(dir=args.tmpdir)

    # parse sample report
    samples = read_sample_report(args.sample_report, args.seqdir)

    # run STAR
    run_star(samples, temp_dir, args.threads, args.STAR, args.db, args.outdir, args.paired, args.gtf)

    exit()

### read in sample report and output dataframe with one line per sample #######
def read_sample_report(sample_report, seqdir):
    # select only FASTQ names and Sample and reshape for STAR
    # multiple file for same sample are separated by commas
    # paired files are separated by spaces
    df = pd.read_csv(sample_report)
    df = df[['SampleName', 'Read', 'Output']]
    df['Output'] = df['Output'].map(lambda x: seqdir + "/" + x)
    df = df.groupby(['SampleName','Read']).agg(','.join).reset_index()
    df = df.pivot(index='SampleName', columns='Read', values='Output')
    
    return(df)

### Run STAR ################################################
def run_star(samples,temp_dir,threads,STAR,db, outdir, paired, gtf):

    for sample in samples.iterrows():

        if paired:
            combined_samples = sample[1][1] + ' ' + sample[1][2]
        else:
            combined_samples = sample[1][1]
            
        command = ( STAR + 
                   ' --runThreadN ' + str(threads) + 
                   ' --genomeDir '  + db + 
                   ' --readFilesIn ' + combined_samples + 
                   ' --readFilesCommand pigz -dcp 4' + 
                   ' --quantMode GeneCounts' + 
                   ' --outFileNamePrefix ' + temp_dir.name + '/' + sample[0] + '.' +
                   ' --outSAMtype BAM SortedByCoordinate' )
        
        if gtf:
            command = command + ' --sjdbGTFfile ' + gtf
            
        print(command)
        os.system(command)
        os.system('ls ' + temp_dir.name)
        
        copy_files(outdir, sample, temp_dir)
    
    return()

### copy star output files to out directory ###################################
def copy_files(outdir, sample, temp_dir):

    shutil.copy(temp_dir.name + '/' + sample[0] + ".ReadsPerGene.out.tab", outdir)
    shutil.copy(temp_dir.name + '/' + sample[0] + ".Log.final.out", outdir)
    shutil.copy(temp_dir.name + '/' + sample[0] + ".Aligned.sortedByCoord.out.bam", outdir)
    print("Alignment complete and files copied: ", sample)

    return()

### validate that a directory is valid path ###################################
def dir_path(path):
    if os.path.isdir(path):
        return path
    else:
        raise argparse.ArgumentTypeError(f"readable_dir:{path} is not a valid path")

### ARGUMENT PARSING ##########################################################
def get_args():
    parser = argparse.ArgumentParser(description="Run STAR aligner using Sample_Report.csv as input")
    # file defaults to stdin
    parser.add_argument('--sample_report', help = 'full path to Sample_Report.csv')
    parser.add_argument('--db', help = 'STAR database')
    parser.add_argument('--seqdir', help = 'Directory containing FASTQ files')
    parser.add_argument('--tmpdir', type = dir_path, default = "/scratch/ejr/tmp", help = 'Temporary Directory Location')
    parser.add_argument('--STAR', default = '/n/apps/CentOS7/bin/STAR', help = 'Location of STAR command')
    parser.add_argument('--paired', help = 'Set this if paired reads.', action="store_true")
    parser.add_argument('--threads', type = int, default = '16', help = 'Number of threads to use for STAR')
    parser.add_argument('--outdir', type = dir_path, default = '.', help = 'where to copy STAR output files')
    parser.add_argument('--gtf', default = '.', help = 'gtf file')
    args = parser.parse_args()

    return args

### RUN MAIN ##################################################################
if __name__ == "__main__":
    main()
###############################################################################

"""
STAR REFERENCE
Dobin A, Davis CA, Schlesinger F, Drenkow J, Zaleski C, Jha S, Batut P,
Chaisson M, Gingeras TR. STAR: ultrafast universal RNA-seq aligner.
Bioinformatics. 2013 Jan 1;29(1):15-21. doi: 10.1093/bioinformatics/bts635. Epub 
2012 Oct 25. PubMed PMID: 23104886; PubMed Central PMCID: PMC3530905.
"""