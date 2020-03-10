use strict;

my $v = shift @ARGV;

$v = "DEFERRED";
$v = "Version $v" if $v<=5;

while(<>){
	s/XXX/$v/g;
	print;
}
