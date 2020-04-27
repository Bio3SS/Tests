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
	s/\\indiv/indiv/g;
	s/\\lambda/λ/g;
	s/\\alpha/α/g;
	s/\\frac\{([^}]*)\}\{([^}]*)\}/$1\/$2/g;
	s/\\geq/≥/g;
	s/\\leq/≤/g;
	s/\\blank\\*/________/g;

	s/\\ / /g;

	s/\{\\em */\\emph{/g;
	s/\\textsl\{([^}]*)\}/_$1_/g;
	s/\\emph\{([^}]*)\}/_$1_/g;
	s/\\uname\{([^}]*)\}/$1/g;

	s/\\\$/CDOL/g;
	s/\$//g;
	s/CDOL/\$/g;

	if (/^COMMENT/){
		s/\w*\s*//;
		$comment = "$_ ";
	}
	elsif (/^WEB/){
		s/\w*\s*//;
		$comment = "$_ ";
	}
	elsif (/^INTRO/){}
	elsif (/^FIGHEAD/){}
	elsif (/^HEAD/){}
	elsif (/^KEY/){}
	elsif (/FIG/){}
	elsif (/PDF/){}
	elsif (/NOCOMMENT/){}
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
	elsif (/^-----/){
		$comment = "";
	}
	else{
		say "Option,$val,$dq$_$dq,,";
	}
}
