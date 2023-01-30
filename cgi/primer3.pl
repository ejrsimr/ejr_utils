#!/usr/bin/perl -w

# this script will write a primer3 input file and will run parsePrimer3.pl 
# runPrimer3.pl -f fasta.nt  (Note -f is required)
# input a fasta file
# output a tab delimited file will all possible primers

use strict;
use Getopt::Std;
use Bio::SeqIO;
use CGI':standard';
use IO::String;

my $primer3_binary = "/usr/bin/primer3_core";
my $parsePrimer3_binary = "/var/www/cgi-bin/parsePrimer3.pl";

if (!param){

print header;
print
    start_html('Run Primer3'),
    h1('Run Primer3 and get tab-delimited output'),

    start_multipart_form,

#textbox for seq 
    "Input one or more sequences in <a href='http://en.wikipedia.org/wiki/FASTA_format'>FASTA format</a><br>",

	textarea(-name=>'fasta',-rows=>20,-cols=>90),

    br,
	#end textbox

    br,
    br,
	"<u>Primer Length</u> ",
	"&nbsp;",
	"&nbsp;",
	"opt:", "&nbsp;",textfield(-name=>'primerLenOpt', -value=>20 , -size=>3),
	"&nbsp;",
	"&nbsp;",
	"min:", "&nbsp;",textfield(-name=>'primerLenMin',-size=>3, -value=>10),
	"&nbsp;",
	"&nbsp;",
	"max:", "&nbsp;",textfield(-name=>'primerLenMax',-size=>3, -value=>25),
    br,
    br,
	"<u>Primer Tm</u>",
	"&nbsp;",
	"&nbsp;",
	"opt:", "&nbsp;",textfield(-name=>'tmOpt',-size=>3, -value=>55),
	"&nbsp;",
	"&nbsp;",
	"min:", "&nbsp;",textfield(-name=>'tmMin',-size=>3, -value=>50),
	"&nbsp;",
	"&nbsp;",
	"max:", "&nbsp;",textfield(-name=>'tmMax',-size=>3, -value=>65),
    br,
    br,
	"<u>Primer GC Content</u>",
	"&nbsp;",
	"&nbsp;",
	'opt:', "&nbsp;",textfield(-name=>'gcOpt',-size=>3, -value=>50),
	"&nbsp;",
	"&nbsp;",
	'min:', "&nbsp;",textfield(-name=>'gcMin',-size=>3, -value=>45),
	"&nbsp;",
	"&nbsp;",
	'max:', "&nbsp;",textfield(-name=>'gcMax',-size=>3, -value=>60),
     br,
     br,
	"<u>GC Clamp</u>",
	"&nbsp;",
	"&nbsp;",
	"&nbsp;",textfield(-name=>'gcClamp',-size=>3, -value=>1),
    br,
    br,
    "<u>Number of primer pairs (Max 25)</u>",
	"&nbsp;",
	"&nbsp;",
	"&nbsp;",textfield(-name=>'numPrimers',-size=>3, -value=>1),
     br,
     br,
    "&nbsp;",checkbox(-name=>'t4p',-checked=>0,-value=>1),
    br,
    br,
	"<u>Optimal Product Length (bp)</u>",
	"&nbsp;",
	"&nbsp;",
	"&nbsp;",textfield(-name=>'optimalProductLength',-size=>25, -value=>"As long as possible"),
    br,
    br,
        "<u>Salt Correction (int)</u> <a href=\"https://primer3.org/manual.html#PRIMER_SALT_CORRECTIONS\">[About this parameter]</a>",
        "&nbsp;",
        "&nbsp;",
        "&nbsp;",textfield(-name=>'saltCorrectionInt',-size=>25, -value=>"1"),
     br,
     br,

    submit(-name=>'primer3', -value=>'Get Primers'),
    end_form,
    end_html;

}


#####################
#
# reading, storing cmd line variables
#
###################
if ( param ){
    print header;
    print start_html('Your Primers');

	my $fasta = param('fasta');
	my $time = time();
####################
#
# tests 
# 
####################



#test for fasta format
my $found = $fasta =~ />/;

if (!$found){
	$fasta = ">UnknownSequnce\n$fasta";
}

####################
#
#  stores command line variables into program variables
#    -- or --
#  if no cmd line variables are given it stores default values
#
####################

my ($gcOpt, $gcMin, $gcMax) = (param ('gcOpt') , param ('gcMin') , param('gcMax'));
my ($tmOpt, $tmMin, $tmMax)  = (param ('tmOpt') , param('tmMin') , param('tmMax'));
my ($primerLenOpt, $primerLenMin, $primerLenMax) = (param ('primerLenOpt') , param('primerLenMin') , param('primerLenMax'));
my $gcClamp = param('gcClamp');
my $t4p = param('t4p');
my $numPrimers = param('numPrimers');
my $optimalProductLength = param('optimalProductLength');
my $saltCorrectionInt = param('saltCorrectionInt');
####################
#
#  1.parsing of the required fasta file
#  2.writing the primer3 input file
#
####################
if ($numPrimers >= 25) {$numPrimers = 25}
my $stringfh = new IO::String($fasta);
       my $inseq = Bio::SeqIO-> new(-fh     => $stringfh,
                                    -format => 'fasta');

my $count = 0;
while (my $seqIO = $inseq->next_seq) {
        my $id  = $seqIO->id;
        my $seq = $seqIO->seq;
        my $len = length($seq);
	if ($optimalProductLength !~ /long/){
		$len = $optimalProductLength;
	}
        #my $len = length($seq);
        my $len_75 = int ($len * .75);
        my $len_50 = int ($len * .50);
        my $len_25 = int ($len * .25);

	
	if ($len_25 <= $primerLenMax){
		print "** WARNING ** $id sequence is too short.  No primers will be made for this sequence.<br><br>";
		next if $len_25 <= $primerLenMax;
	}	
	
	open OUTFILE,  ">>/tmp/$time.in_primer3";

        print OUTFILE

"PRIMER_SEQUENCE_ID=$id
SEQUENCE_TEMPLATE=$seq
PRIMER_PRODUCT_SIZE_RANGE=$len_75-$len $len_50-$len $len_25-$len 100-$len
PRIMER_GC_CLAMP=$gcClamp       
PRIMER_MIN_GC=$gcMin
PRIMER_OPT_GC_PERCENT=$gcOpt
PRIMER_MAX_GC=$gcMax
PRIMER_OPT_SIZE=$primerLenOpt
PRIMER_MIN_SIZE=$primerLenMin
PRIMER_MAX_SIZE=$primerLenMax
PRIMER_OPT_TM=$tmOpt
PRIMER_MIN_TM=$tmMin
PRIMER_MAX_TM=$tmMax
PRIMER_NUM_RETURN=$numPrimers
PRIMER_SALT_CORRECTIONS=$saltCorrectionInt
=\n";
	$count++
}



if ($count){ #proceed only if 1 or more appropriate sequences are provided

####################
#
# running the primer3
#
###################

	print "Primers for $count sequence(s).\n\n";

	`cat /tmp/$time.in_primer3  | $primer3_binary > /tmp/$time.out_primer3`;

	#print "Your Primers are in $file.primers.txt\n\n";



####################
#
# running the parser
#
###################

	my $output = `$parsePrimer3_binary /tmp/$time.out_primer3` ;

	my @lines = split /\n/ , $output;
	print "<table><tr><td>";
	print "<table border=1 align=left cellpadding=2>";

	foreach my $line (@lines){
		my @fields = split /\t/ , $line;
		print "<tr align=center>";
        unless ($fields[2] eq "primerSetNum" or $fields[2] <= $numPrimers) {next;}
        if ($t4p == 1 && $fields[3] eq 'left') {
            $fields[10] = "CATTACCATCCCG" . $fields[9];
        } elsif ($t4p == 1 && $fields[3] eq 'right'){
            $fields[10] = "CCAATTCTACCCG" . $fields[9];
        } elsif ($t4p ==1 && $fields[0] eq 'ID') {
            $fields[10] = "t4p + primer";
        }
		foreach my $field (@fields){
			#print "<td><pre>$field</pre></td>";
			print "<td><font face=courier size=2>$field</font></td>";
		}
		print "</tr>";
	}
	print "</table>";
	print "</td></tr>";
	
	#print "<tr><td>";
	#print "<br>tab-delimited format:<br>";
	#print "<pre>", $output , "</pre>";
	#print "</tr></tr>";
	print "</table>";
    print "<br>";
    
    # output fasta of primers
    print "<pre>";
    shift(@lines);
    foreach my $line (@lines) {
	my @fields = split /\t/ , $line;
        unless ($fields[2] <= $numPrimers) {next;}
        print ">$fields[0]_primer_", $fields[2],"_", $fields[3], " len", $fields[6], "\n";
        print $fields[9], "\n";
        #if ($t4p == 1 && $fields[3] eq 'right'){
        #  print ">$fields[0]_primer_", $fields[2], $fields[3], "_t4p", " len", $fields[6], "(+13)", "\n";
        #  print "CCAATTCTACCCG" . $fields[9], "\n";
        #}elsif($t4p == 1 && $fields[3] eq 'left'){
        #  print ">$fields[0]_primer_", $fields[2], $fields[3], "_t4p", " len", $fields[6], "(+13)", "\n";
        #  print "CATTACCATCCCG" . $fields[9], "\n";
        #}
    }
    print "</pre>";

}
	close OUTFILE;
#	unlink ("/tmp/$time.in_primer3","/tmp/$time.out_primer3");
    print end_html;
}

