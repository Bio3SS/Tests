use strict;
use 5.10.0;

$/ = "";

my $comment = "";
my $dq= '"';
my $qn = 0;
while (<>){
	chomp;
	my $val=0;
	$val = 100 if s/^[*]\s*//;

	s/``/“/g;
	s/''/”/g;

	s/\\rmax/r_max/g;
	s/\\yr/yr/g;
	s/\\Ro/R_0/g;
	s/\\R_0/R_0/g;
	s/\\R/R/g;
	s/\\ell/ℓ/g;
	s/\\lambda/λ/g;

	s/\\ / /g;

	s/\\textsl\{([^}]*)\}/_$1_/g;
	s/\\emph\{([^}]*)\}/_$1_/g;

	if (/^COMMENT/){
		s/\w*\s*//;
		$comment = "$_ ";
	}
	elsif (/^INTRO/){}
	elsif (/^ANS/){}
	elsif (/^Q/){
		$qn++;
		my $id = sprintf("2020F%2d", $qn);
		$id =~ s/ /0/g;
		my $tit = $_;
		$tit =~ s/[^\w\s]//g;
		$tit = join("_", (split /\s/, $tit)[3..4]);
		s/\w*\s*/$comment/;
		say "";
		say "NewQuestion,MC,";
		say "ID,$id";
		say "Title,$tit";
		say "QuestionText,$dq$_$dq,";
		say "Points,1,";
		say "Difficulty,1,";
	}
	elsif (/^-/){
		$comment = "";
	}
	else{
		say "Option,$val,$dq$_$dq,,";
	}
}
