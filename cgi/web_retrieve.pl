#!/usr/bin/perl
# ejr - Last modified 20140808 
# Now requires directory containing blast databases.
# example of URL ?dir=/n/projects/ejr/blastdb
# Web interface for FASTA retrieval using blastdbcmd
# INPUT: list of identifies
# OUTPUT: FASTA output

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use File::Temp qw(tempfile);

my $q = new CGI;
my $dir;
my $species;

#My species
my %dirs = ('Schmidtea_mediterranea' => 1, 'Pomacea_canaliculata' => 1, 'planaria_other' => 1, 'misc' => 1);

if ($q->param('species')) {
        $species = $q->param('species');
        unless (defined($dirs{$species})) {exit;}
        $dir = "/var/other_data/ejr/blastdb/" . $species ."/";
}

#get list of BLAST databases
my @databases;
opendir(DIR, $dir) or die $!;
while (my $file = readdir(DIR)) {
    # Use a regular expression to ignore files beginning with a period
    if ($file =~ /fa$/){ 
        push @databases, $file;
    }
}
@databases = sort(@databases);
closedir(DIR);

print $q->header;
print '<link href="/blast.css" rel="stylesheet" type="text/css" />';
print $q->start_html(-title => 'Retrieve Sequences');
print $q->h1("Retrieve from BLAST database");

if ($q->param('list')) {
    display_results($q);
} else {
    output_form($q);
}

print $q->end_html;


exit(0);

# SUBROUTINES

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

print  $q->td("Database:"),
       $q->td($q->popup_menu(
       -name => 'database',
       -values => \@databases,
       -default => 'schMedS3_h1_transcripts.fa',
     ));
print $q->Tr (
    $q->td({-colspan => 7, -align=> 'center'},$q->textarea(
        -name => 'list',
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

    my $list = $q->param('list');
    print STDERR $list;
    # edit 20141218 
    $list =~ tr/\r/\n/;
    my @list_items = split(/\n/, $list);
    foreach my $item (@list_items) {
	unless ($item) {next;}
	$item =~ s/>//g;
    	$item =~ s/^(.+?)\s+.*/$1/;
	$item =~ s/[^\w\.]//g;
	print $fh $item, "\n";
	print $item . "<br>";
	}

    my $database = $q->param('database');

if ($q->param('species')) {
        $species = $q->param('species');
        unless (defined($dirs{$species})) {exit;}
        $dir = "/var/other_data/ejr/blastdb/" . $species ."/";
}
    $database =~ s/[^\w\\\.]//g;
    $dir =~  s/[^\w\/\.]//g;



    my $command;
   $command = "/var/other_data/ejr/bin/retrieve_from_fasta -f $filename " . $dir . "/" . $database;

    open(CMD, "$command 2>&1 |") or die "Command failed: $!\n";
    print "<PRE>";
    while (my $line = <CMD>) {
        print $line;
    }
    print "</PRE>";
    close(CMD);
}
