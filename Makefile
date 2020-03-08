## This is Tests, a screens project directory under 3SS
## Includes test and marking machinery (because both depend on scramble stuff)

current: target
-include target.mk

-include makestuff/newtalk.def
-include makestuff/perl.def

######################################################################

# Content

vim_session:
	bash -cl "vmt content.mk"

######################################################################

## Directories

pardirs += evaluation assign ts Life_tables

hotdirs += $(pardirs)

pull: $(pardirs:%=%.pull)

######################################################################

# Archive

## DON'T do this until you update the year in archive.pl
## Start the year by tagging last year's questions.
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
midterm1.bank: midterm1.formulas evaluation/linear.bank evaluation/nonlinear.bank evaluation/corona.bank
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

## Bank should not be scrambled, make these directly

## bank.fmt is stupid; figure out how to put bank closer to main path
Sources += bank.fmt

# midterm1.1.smc:

Sources += $(wildcard *.pl)

Ignore += *.smc
midterm1.bank.smc midterm2.bank.smc: %.smc: % null.tmp bank.fmt newtalk/lect.pl
	$(PUSH)

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
%.bank.sa: %.short.test null.tmp bank.fmt newtalk/lect.pl
	$(PUSH)

######################################################################

## Knit short answers
## Not scrambling (afraid of format problems)
## Maybe these can be solved by always having a page per question

Ignore += *.vsa

# Use version 3 for the bank
midterm1.bank.vsa midterm2.bank.vsa: %.vsa: %.sa testselect.pl
	perl -wf $(filter %.pl, $^) 3 $(filter-out %.pl, $^) > $@

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
#  midterm1.bank.test:
#  midterm2.bank.key.pdf:

### Separator for MC and SA on the same test
Sources += end.dmu

Ignore += *.test
midterm2.1.test: 
	$(cat)
%.test: %.smc end.dmu %.ksa
	$(cat)

## Instructions added for 1M strictness; I think I like them
## Ask team?
Sources += sa_inst.tex sa_head.tex

## This should be done better
Sources += copy.tex

######################################################################

## Latex outputs

## midterm1.bank.test.pdf: evaluation/nonlinear.bank
## midterm1.1.test.pdf: evaluation/nonlinear.bank evaluation/nonlinear.short
## midterm1.2.rub.pdf: evaluation/linear.short
## midterm1.2.key.pdf: evaluation/linear.short

## midterm2.test.pdf: evaluation/structure.bank
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

midterm1.4.exam.pdf:

## Final versions

## Cover pages handled differently
## This is because the final cover needs to know the number of pages
## so it's part of the main tex document
## (midterms share midterm.front.tex)
Sources += $(wildcard *.front.tex)
Sources += scantron.jpg

## Add cover pages and such
Ignore += *.exam.tex *.exam.pdf *.front.pdf
midterm1.%.exam.pdf: midterm.front.pdf midterm1.%.test.pdf
	$(pdfcat)

midterm2.%.exam.pdf: midterm.front.pdf midterm2.%.test.pdf
	$(pdfcat)

### we handle testver twice (redundant code)
### examno.pl does something for the cover page on the final
### midterms (and final body?) are handled by scramble.pl
### Better way might be separate .tmp for the tests, just like
### we have versioned .tmp for the exam
Sources += final.tmp examno.pl final.cover.tex
## final.3.final.pdf: final.tmp 

final.%.tmp: final.tmp examno.pl
	$(PUSHSTAR)

%.final.tex: %.test %.tmp test.test.fmt talk/lect.pl
	$(PUSH)

######################################################################

pushdir = ../web/materials

######################################################################

## Printing

## http://printpal.mcmaster.ca/
## account # 206000301032330000

## White, orchid, green, salmon 
## Two-sided, stapled

midterm1.5.exam.pdf:
## midterm1.3.key.pdf: evaluation/linear.short evaluation/nonlinear.short

midterm1_ship: midterm1.1.exam.pdf midterm1.2.exam.pdf midterm1.3.exam.pdf midterm1.4.exam.pdf midterm1.5.exam.pdf
	/bin/cp -f $^ ~/Downloads

## Push tests and keys with the same command
midterm1_post: midterm1.1.test.pdf.pd midterm1.2.test.pdf.pd midterm1.3.test.pdf.pd midterm1.4.test.pdf.pd midterm1.5.test.pdf.pd
midterm1_post: midterm1.1.key.pdf.pd midterm1.2.key.pdf.pd midterm1.3.key.pdf.pd midterm1.4.key.pdf.pd midterm1.5.key.pdf.pd

midterm1.rub.zip: midterm1.1.rub.pdf midterm1.2.rub.pdf midterm1.3.rub.pdf midterm1.4.rub.pdf midterm1.5.rub.pdf
	$(ZIP)

midterm2_ship: midterm2.1.exam.pdf midterm2.2.exam.pdf midterm2.3.exam.pdf midterm2.4.exam.pdf midterm2.5.exam.pdf
	/bin/cp -f $^ ~/Downloads

midterm2_post: midterm2.1.test.pdf.pd midterm2.2.test.pdf.pd midterm2.3.test.pdf.pd midterm2.4.test.pdf.pd midterm2.5.test.pdf.pd

midterm2_keys: midterm2.1.key.pdf.pd midterm2.2.key.pdf.pd midterm2.3.key.pdf.pd midterm2.4.key.pdf.pd midterm2.5.key.pdf.pd

midterm2.rub.zip: midterm2.1.rub.pdf midterm2.2.rub.pdf midterm2.3.rub.pdf midterm2.4.rub.pdf midterm2.5.rub.pdf
	$(ZIP)

## Search email for Exam Upload Instructions (or notice when email arrives and do something)
# http://macdrive.mcmaster.ca/u/d/4ce0683ccb1f49cca555/ (2019 deferred)
# B5%m3dG6

Ignore += $(wildcard Bio_3SS3*.pdf) 
Ignore += $(wildcard final*final.pdf) 
final_ship: final.1.final.pdf final.2.final.pdf final.2.final.pdf final.4.final.pdf ;
final_upload: final_ship Bio_3SS3_C01_V1.pdf Bio_3SS3_C01_V2.pdf Bio_3SS3_C01_V3.pdf Bio_3SS3_C01_V4.pdf
	/bin/cp Bio_3SS3_C01*.pdf ~/Downloads
defer: Bio_3SS3_C01_V5.pdf
	/bin/cp $< ~/Downloads

## Finalizing
## final.1.final.pdf:

Bio_3SS3_C01_V%.pdf: final.%.final.pdf
	$(forcelink)

######################################################################

# Test key
.PRECIOUS: %.ssv

## We really want to base the key on the human-readable key.tex
## For now, just be really carefully about checking
# midterm1.1.ssv:
Ignore += *.ssv
midterm%.ssv: midterm%.smc key.pl
	$(PUSH)

final.%.ssv: final.%.test key.pl
	$(PUSH)

# Make a special answer key for scantron processing
# To allow multiple answers, use KEY in the .bank file
# Does not work yet for self-scoring
# midterm1.1.sc.csv:
Ignore += *.sc.csv
%.sc.csv: %.ssv scantron.pl
	$(PUSH)

Ignore += *.scantron.csv
midterm1.scantron.csv:
midterm2.scantron.csv:
final.scantron.csv:

# Combine a bunch of scantron keys into a file for the processors
final.scantron.csv midterm1.scantron.csv midterm2.scantron.csv: %.scantron.csv: %.1.sc.csv %.2.sc.csv %.3.sc.csv %.4.sc.csv %.5.sc.csv
	$(cat)

######################################################################

## Fuel

Ignore += tube.png
tube.png:
	wget -O $@ https://what-if.xkcd.com/imgs/a/11/droppings_car.png

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

## This is pretty.
subTests/%:
	$(MAKE) subTests

