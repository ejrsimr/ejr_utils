#!/usr/bin/perl
# parse cd-hit-est clstr output
#
my %out;
my $cluster;
my %counts;

while (my $line = <>) {
    chomp $line;
    if ($line =~ /^>(.+)/) { 
        $cluster = $1; 
    } else {
        $name = $line;
        $name =~ s/.+\>(.+)\.\.\..+/$1/;
        $out{$cluster}{$name} = 1; 
        $counts{$cluster}++;
    }
}

foreach my $cluster (sort keys %out) {
    foreach my  $name (sort keys %{$out{$cluster}}) {
        print join("\t", $name, $cluster, $counts{$cluster}), "\n";
    }
}



__END__
#>Cluster 0
#0       48121nt, >dd_Smes_a1_5752_1... *
#>Cluster 1
#0       19980nt, >dd_Smes_a1_16745_6... at 1:19674:1:19674/+/100.00%
#1       37460nt, >dd_Smes_a1_16745_5... *
#>Cluster 2
#0       37034nt, >dd_Smes_a1_16745_3... *
