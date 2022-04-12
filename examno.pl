use strict;

my $v = shift @ARGV;

my $w = "DEFERRED";
$w = "Version $v" if $v<=5;

while(<>){
	s/XXX/$w/g;
	print;
}
