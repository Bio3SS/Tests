use strict;
use 5.10.0;

$/ = "";

while (<>){
	print if (/^INTRO/);
	print if (s/^HEAD/OUTLINE/);
	print if (s/^FIGHEAD/HEAD/);
	print if (/FIG/);
	print if (/PDF/);
}
