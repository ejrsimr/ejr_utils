#!/usr/bin/perl
# last modified: ejr: 2022-09-06
# Web interface for BLAST
# INPUT: FASTA formatted list of sequences
# OUTPUT: FULL BLAST output or BLAST tabular output.

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use File::Temp qw(tempfile);

my $blast_dir = "/usr/bin/";
my $q = new CGI;
my $species;
my $dir;

#BLAST evalue option
my %evalues = (1000 => 1, 10 => 1, .001 => 1, 1e-5 => 1, 1e-20 => 1);
my @evalues = (1000, 10, .001, 1e-5, 1e-20);
#BLAST programs
my %programs = ('blastn' => 1, 'tblastn' => 1, 'tblastx' => 1);
my @programs = ('blastn', 'tblastn', 'tblastx');
#Number of Alignments
my %alignments = ('1'  => 1, '10' => 1, '100' => 1,'1000' => 1);
my @alignments = ('1', '10', '100','1000');
#FORMATS
my %formats = ('table' => 1, 'full' => 1);
my @formats = ('table', 'full');
#My species
my %dirs = ('Schmidtea_mediterranea' => 1, 'Pomacea_canaliculata' => 1, 'planaria_other' => 1, 'misc' => 1);
my @dirs = ('Schmidtea_mediterranea', 'Pomacea_canaliculata', 'planaria_other', 'misc');

if ($q->param('species')) {
	$species = $q->param('species');
	unless (defined($dirs{$species})) {exit;}
	$dir = "/var/other_data/ejr/blastdb/" . $species ."/"; 
}



#BLAST databases
my @databases;
my %databases;

opendir(DIR, $dir) or die $!;

while (my $file = readdir(DIR)) {
    # Use a regular expression to ignore files beginning with a period
    if ($file =~ /fa$/){ 
        push @databases, $file;
	$databases{$file} = 1;
    }
}
@databases = sort(@databases);

closedir(DIR);




print $q->header;
print '<link href="/blast.css" rel="stylesheet" type="text/css"
/>';
print $q->h1("BLAST");
print $q->start_html(-title => 'BLAST');

if ($q->param('program')) {
    display_results($q);
} else {
    output_form($q);
}


print $q->end_html;


exit(0);



sub output_form {

#FORM FIELDS
print $q->start_form(
    -name    => 'main_form',
    -method  => 'POST',
    -enctype => &CGI::URL_ENCODED,
    -onsubmit => 'return javascript:validation_function()',
);

print $q->hidden('species',$species);

print $q->start_table;
print $q->Tr (
    $q->td("Program:"),
    $q->td($q->popup_menu(
        -name => 'program',
        -values => \@programs,
        -default => 'blastn',
        )),
    $q->td("Database:"),
    $q->td($q->popup_menu(
        -name => 'database',
        -values => \@databases,
        -default => 'schMedS3_h1_transcripts.fa',
    )),
    $q->td("E-value:"),
    $q->td($q->popup_menu(
        -name => 'evalue',
        -values => \@evalues,
        -default => '.001'
    )),

    $q->td("# of Alignments:"),
    $q->td($q->popup_menu(
        -name => 'alignments',
        -values => \@alignments,
        -default => '1',
    )),
    $q->td("Format:"),
    $q->td($q->popup_menu(
        -name => 'format',
        -values => \@formats,
        -default => 'table',
    )),
);

print $q->Tr (
    $q->td({-colspan => 7, -align=> 'center'},$q->textarea(
        -name => 'fasta',
        -cols => 80,
        -rows => 20,
    )),
);

print $q->Tr (
    $q->td({-colspan=>7, -align=>'center'}, $q->submit(-value=>'Submit'))
);

print $q->end_table;



print $q->end_form;

#END FORM

}

sub display_results {
    my ($q) = @_;
    my ($fh, $filename) = tempfile();


    my $program = $q->param('program');
    my $database = $q->param('database');
    my $evalue = $q->param('evalue');
    my $alignments = $q->param('alignments'); 
    my $fasta = $q->param('fasta');
    my $format = $q->param('format');

    if (! defined($programs{$program})) {$program = 'blastn'}
    if (! defined($evalues{$evalue})) {$evalue = '.001'}
    if (! defined($alignments{$alignments})) {$alignments = '1'}
    if (! defined($formats{$format})) {$format = 'table'}

    # we need to escape out the database name as we don't have a safe list
    if (! defined($databases{$database})) {$database = 'smed_20140614.fsa_nt'}
    $database =~ s/[^\w\\\.]//g;
    $dir =~  s/[^\w\/\.]//g;

    print $fh $fasta;

    my $command;
    if ($format eq "table") {
        if ($program eq 'blastn'){
            $command = $blast_dir . "$program -db " . $dir .
            $database. " -query $filename -evalue $evalue -word_size 15 -max_target_seqs $alignments -outfmt 7 ";
        }else{
            $command = $blast_dir . "$program -db ".  $dir . $database. " -query $filename -evalue $evalue -max_target_seqs $alignments -outfmt 7 ";

        }
    } else {
        if ($program eq 'blastn'){
            $command = $blast_dir . "$program -db ". $dir .
            $database. " -word_size 15 -query $filename -evalue $evalue";
            }else{
            $command = $blast_dir . "$program -db ". $dir .
            $database. " -query $filename -evalue $evalue";

            }
    }


    open(CMD, "$command 2>&1 | grep -v \"^#\" |" ) or die "Command failed: $!\n";


	if ($format eq "table") {
		print "<table cellpadding=\"1\" cellspacing=\"1\" width=\"80%\" border=\"1\">";
		print "<tr><td>";
		print join("</td><td>", "query_id", "subject_id", "identity", "alignment_length", "mismatches", "gap_opens", "qstart", "qend", "sstart", "send","evalue", "score"), "\n";
		print "<\/td><\/tr>";
    		while (my $line = <CMD>) {
			unless ($line =~ /nvalid/) { 
				$line =~ s/\t/<\/td><td>/g;
				$line = "<tr><td>$line<\/td><\/tr>";
        			print $line;
			}
    		}
    		print "</table>";
	} else {
		print "<PRE>";
		while (my $line = <CMD>) {
			print $line;
		}
		print "</PRE>"
	}
	
    close(CMD);


}
