use strict;
use 5.10.0;

$/ = "";

my $comment = "";
my $qn = 0;
while (<>){
	chomp;
	my $val=0;
	$val = 100 if s/^[*]\s*//;
	if (/^COMMENT/){
		s/\w*\s*//;
		$comment = $_;
	}
	elsif (/^INTRO/){}
	elsif (/^ANS/){}
	elsif (/^Q/){
		$qn++;
		my $id = sprintf("2020F%2d", $qn);
		$id =~ s/ /0/g;
		s/\w*\s*/$comment/;
		say "";
		say "NewQuestion,MC,";
		say "ID,$id";
		say "Title,Question";
		say "QuestionText,$_,";
		say "Points,1,";
		say "Difficulty,1,";
	}
	elsif (/^-/){
		$comment = "";
	}
	else{
		say "Option,$val,$_,,";
	}
}
