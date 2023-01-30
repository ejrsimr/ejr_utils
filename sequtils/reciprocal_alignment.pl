#!/usr/bin/perl
# ejr - 20161013
# last update: ejr: 2021-06-22
# update to use diamond instead of blast
# last update: ejr: 2022-06-27
# this version requires headers to be in format transcript|gene
# it then uses genes instead of transcripts for reciprocal
#
# Reciprocally blast two protein FASTA files
# INPUT: FASTA1 = Initial query fasta
#        FASTA2 = Initial databse fasta
# OUTPUT: to STDOUT seq.id.1\tseq.id.2\tevalue.1v2\trecip.rank\n
# blastp FASTA1 v FASTA2.  best hits in FASTA2 are blasted back to FASTA1
# the rank of the reciprical blast is best hit =1, second best hit = 2 etc.
use strict;
use warnings;
use Getopt::Long;
my $cores=32;
my $max_hits=10;
my $genes="";
my $fasta1="";
my $fasta2="";
my $help="";
GetOptions( "genes" => \$genes,
            "query=s" => \$fasta1,
            "target=s" => \$fasta2,
            "help"     => \$help,
            "cores=i"  => \$cores,
            "max_hits=i" => \$max_hits
            );

if ($help) {
    die "Syntax: $0 --genes --query=query_fasta.fa --target=target_fasta.fa \n
        --genes if set, FASTA headers must be\n
            '>transcript_id\tgene_id'\n
            This treats all sequences from one gene as a single unit, rather than per transcript.
        --query: fasta file of query species\n
        --target: fasta file of target species\n";
}

my $tmpdir = '/scratch/ejr/tmp';
my $cmd = '/n/projects/ejr/src/diamond/diamond';
my $params = " blastp --ultra-sensitive --threads $cores --evalue 0.01 --tmpdir $tmpdir"; 

# CREATE BLAST DATABASES
# check to see if database exist
# if it doesn't create the database
if ( -e "$fasta1" . ".dmnd") { 
    print STDERR "Database for $fasta1 already exists\n";
} else {
    `$cmd makedb --threads $cores --in $fasta1 --db $fasta1`;
    print STDERR "Database for $fasta1 created\n";
}

if ( -e "$fasta2" . ".dmnd") { 
    print STDERR "Database for $fasta2 already exists\n";
} else {
    `$cmd makedb --threads $cores --in $fasta2 --db $fasta2`;
    print STDERR "Database for $fasta2 created\n";
}

my $init_blastout  = $fasta1 . "_v_" . $fasta2 . ".blastp";
my $recip_blastout = $fasta2 . "_v_" . $fasta1 . ".blastp";

# BLAST FASTA1 v FASTA2: best hits only
`$cmd $params --query $fasta1 --db $fasta2 --out $init_blastout --max-target-seqs 1`;

# BLAST FASTA2 v FASTA1: $max_rank number of hits.
`$cmd $params -k $max_hits --query $fasta2 --db $fasta1 --out $recip_blastout`;

# hash %ranks stores best hits and reciproval scores
# $rank{seq1.id}{seq2.id} = rank
my %forward;
my %reverse;

# OPEN FILES
open (INIT,   "$init_blastout") or die  "Cannot open $init_blastout: $!\n";
open (RECIP, "$recip_blastout") or die "Cannot open $recip_blastout: $!\n";
# PARSE INITIAL BLAST
# get best hit and evalue for each gene
while (my $line = <INIT>) {
    chomp $line;
    my @F = split /\t/, $line;

    my ($transcript, $gene, $hit_transcript, $hit_gene);
    if ($genes) {
        ($transcript, $gene) = split /\|/, $F[0];
        ($hit_transcript, $hit_gene) = split /\|/, $F[1];
    } else {
        $gene = $F[0];
        $hit_gene = $F[1];
    }

    my $evalue = $F[10];
    if (exists( $forward{$gene}{$hit_gene} )) {
        if ($evalue < $forward{$gene}{$hit_gene}) {
            $forward{$gene}{'evalue'} = $evalue; 
            $forward{$gene}{'hit'} = $hit_gene; 
        }
    } else {
        $forward{$gene}{'evalue'} = $evalue; 
        $forward{$gene}{'hit'} = $hit_gene; 
    }
}

# PARSE RECIPROCAL BLAST
# get list of hits and scores
while (my $line = <RECIP>) {
    chomp $line;
    my @F = split /\t/, $line;
    my ($transcript, $gene, $hit_transcript, $hit_gene);
    if ($genes) {
        ($transcript, $gene) = split /\|/, $F[0];
        ($hit_transcript, $hit_gene) = split /\|/, $F[1];
    } else {
        $gene = $F[0];
        $hit_gene = $F[1];
    }
    my $score = $F[11];
    if (exists( $reverse{$gene}{$hit_gene} )) {
        if ($score > $reverse{$gene}{$hit_gene}) {
            $reverse{$gene}{$hit_gene} = $score; 
        }
    } else {
        $reverse{$gene}{$hit_gene} = $score;
    }
}

# create rank for each gene - hit based on score
my %ranks;
foreach my $gene (keys %reverse) {
    my $rank = 1;
    foreach my $hit (sort {$reverse{$gene}{$b} <=> $reverse{$gene}{$a}} keys %{$reverse{$gene}}) {
        $ranks{$gene}{$hit} = $rank;
        $rank++;
    }
}


# add ranks to $reverse.


# OUTPUT
print join("\t",
        "gene_id",
        "best_hit_gene_id",
        "evalue",
        "rank"),
        "\n"; 

foreach my $gene (sort keys %forward) {
    if (defined($ranks{$forward{$gene}{'hit'}}{$gene})) {
        if ($ranks{$forward{$gene}{'hit'}}{$gene} > $max_hits) {
            $ranks{$forward{$gene}{'hit'}}{$gene} = ">" . $max_hits;
        }
        print join("\t", 
            $gene, 
            $forward{$gene}{'hit'}, 
            $forward{$gene}{'evalue'}, 
            $ranks{$forward{$gene}{'hit'}}{$gene}), 
            "\n";
    } else {
        print join("\t", 
            $gene, 
            $forward{$gene}{'hit'}, 
            $forward{$gene}{'evalue'}, 
            ">". $max_hits), 
            "\n";

    }
}
