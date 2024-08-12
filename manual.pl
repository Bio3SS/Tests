use strict;
use 5.10.0;

my $ans;
while(<>){
	chomp;
	s/.*([A-E])$/$1/ or die "Bad line $.";
	$ans .= $_;
}

$ans =~ tr/A-E/a-e/;
$ans =~ s/...../$& /g;
say $ans;
