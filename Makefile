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
Sources += archive.pl
archiveQuestions:
	perl -pi -f archive.pl evaluation/*.bank

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

Sources += $(wildcard *.pl)

midterm1.%.mc: midterm1.mc scramble.pl
	$(PUSHSTAR)

midterm2.%.mc: midterm2.mc scramble.pl
	$(PUSHSTAR)

final.%.test: final.mc scramble.pl
	$(PUSHSTAR)

final.test: final.mc
	$(copy)
 
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

%.pl:
	$(CP) subTests/$@ .
	$(RW)

######################################################################

