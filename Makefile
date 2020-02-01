## This is Tests, a screens project directory under 3SS
## Includes test and marking machinery (because both depend on scramble stuff)

current: target
-include target.mk

include makestuff/newtalk.def
include makestuff/perl.def

######################################################################

# Content

vim_session:
	bash -cl "vmt content.mk"

######################################################################

## Directories

## evaluation would be a good candidate for a submodule, since we could 
## really set the clock back to when we made the test
## but I'm NOT doing it now 2020 Feb 01 (Sat)

pardirs += evaluation

######################################################################

# Archive

## Start the year by tagging last year's questions.
## DON'T do this until you update the year
## DON'T try to make this work with -e (not easy, not important)
archiveQuestions:
	perl -pi -f archive.pl evaluation/*.bank evaluation/*.short

######################################################################

## Formulas
Sources += $(wildcard *.formulas)
Sources += $(wildcard formula*.tex)

######################################################################

### Formats

Ignore += null.tmp
null.tmp:
	touch $@

Ignore += *.fmt
%.test.fmt: lect/test.format lect/fmt.pl
	$(PUSHSTAR)

%.select.fmt: lect/select.format lect/fmt.pl
	$(PUSHSTAR)

######################################################################

## Short-answer banks

Ignore += midterm1.bank
midterm1.bank: midterm1.formulas evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank
	$(cat)

Ignore += midterm2.bank
midterm2.bank: midterm2.formulas evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank evaluation/life_history.bank evaluation/comp.bank
	$(cat)

Ignore += final.bank
final.bank: final.formulas evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank evaluation/life_history.bank evaluation/comp.bank evaluation/pred.bank evaluation/disease.bank
	$(cat)

######################################################################

# MC selection
# Use lect/select.format

# midterm1.mc:

.PRECIOUS: %.mc
Ignore += *.mc
%.mc: %.bank null.tmp %.select.fmt newtalk/lect.pl
	$(PUSH)

# Scramble

# midterm1.1.smc:

Sources += $(wildcard *.pl)

midterm1.%.smc: midterm1.mc scramble.pl
	$(PUSHSTAR)

midterm2.%.smc: midterm2.mc scramble.pl
	$(PUSHSTAR)

final.%.test: final.smc scramble.pl
	$(PUSHSTAR)

final.test: final.mc
	$(copy)

######################################################################

## Select short answers

midterm1.sa:

# Make combined SA lists for each test
Ignore += *.short.test
Sources += sahead.short
midterm1.short.test: sahead.short evaluation/linear.short evaluation/nonlinear.short 
	$(cat)

midterm2.short.test: evaluation/linear.short evaluation/nonlinear.short evaluation/structure.short evaluation/life_history.short
	$(cat)

# Select the short-answer part of a test

.PRECIOUS: %.sa
Ignore += *.sa
%.sa: %.short.test null.tmp %.select.fmt newtalk/lect.pl
	$(PUSH)

######################################################################

## Knit short answers
## Not scrambling (afraid of format problems)
## Maybe these can be solved by always having a page per question

Ignore += *.vsa
midterm1.%.vsa: midterm1.sa testselect.pl
	$(PUSHSTAR)

midterm2.%.vsa: midterm2.sa testselect.pl
	$(PUSHSTAR)

## Convert versioned sa to rmd style
Ignore += *.rsa
%.rsa: %.vsa lect/knit.fmt newtalk/lect.pl
	$(PUSH)

## and finally knit
Ignore += *.ksa
knit = echo 'knitr::knit("$<", "$@")' | R --vanilla
%.ksa: %.rsa
	$(knit)

######################################################################

## Put the test together

#  midterm1.1.test:

### Separator for MC and SA on the same test
Sources += end.dmu

Ignore += *.test
%.test: %.smc end.dmu %.ksa
	$(cat)
midterm1.1.test: midterm1.1.smc end.dmu midterm1.1.ksa
	$(cat)

## Instructions added for 1M strictness; not sure whether to copy them over
Sources += sa_inst.tex

## This should be done better
Sources += copy.tex

######################################################################

## Latex outputs

## midterm2.test.pdf: evaluation/structure.bank
## midterm1.2.test: evaluation/nonlinear.bank
## midterm1.2.test.pdf: evaluation/nonlinear.bank
## midterm2.3.key.pdf: evaluation/life_history.bank
## midterm2.4.rub.pdf: evaluation/structure.short

Sources += test.tmp
Ignore += *.test.tex *.test.pdf
%.test.tex: %.test test.tmp test.test.fmt newtalk/lect.pl
	$(PUSH)

Ignore += *.key.*
%.key.tex: %.test test.tmp key.test.fmt newtalk/lect.pl
	$(PUSH)

## Why are rubric dependencies different??
Ignore += *.rub.*
%.rub.tex: %.ksa test.tmp rub.test.fmt newtalk/lect.pl
	$(PUSH)

######################################################################

### Makestuff

Sources += Makefile

Sources += content.mk

Ignore += makestuff
msrepo = https://github.com/dushoff
Makefile: makestuff/Makefile
makestuff/Makefile:
	git clone $(msrepo)/makestuff
	ls $@

-include makestuff/os.mk

-include makestuff/lect.mk
-include makestuff/texdeps.mk
-include makestuff/hotcold.mk
-include makestuff/wrapR.mk

## -include makestuff/wrapR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
-include makestuff/projdir.mk

######################################################################

## Cribbing 

Ignore += subTests
## subTests.ro:
subTests:
	git clone https://github.com/Bio3SS/$@.git

$(Sources):
	$(CP) subTests/$@ .
	$(RW)

