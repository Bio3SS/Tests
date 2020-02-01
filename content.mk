
## What is up with this one???
## Make assign into a resting subclone! Don't need to all it. Ever.
## Try not to use it, not to make there, etc. 2019 Feb 04 (Mon)
## Immediately bailed on this plan!!! 2019 Feb 04 (Mon)
## Resuscitated assign as a clone and made:
## pullup; pullup; rmsync; rmsync; all!
clonedirs += assign
assign:
	git clone https://github.com/Bio3SS/Assignments $@
	cd assign && $(MAKE) Makefile && $(MAKE) Makefile

assign/%: ; $(MAKE) assign; $(makethere)

## There is also a private repo called Grading_scripts (out of date)
## and a public successor called Grading
## It might be good to farm the grading scripts out to Grading,
## and to use Grading_scripts to keep grade files that we might want to diff

## Grading has poll everywhere stuff
## It used to be a submodule of Tests, but I'm trying to reverse that
## Or something

##################################################################


# Test key
.PRECIOUS: %.ssv

# midterm1.1.ssv:
Ignore += *.ssv
midterm%.ssv: midterm%.mc key.pl
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

# Make a skeleton to track how questions are scrambled
# Will be used later for marking
Ignore += final.skeleton midterm1.skeleton midterm2.skeleton
final.skeleton midterm1.skeleton midterm2.skeleton: %.skeleton: %.mc skeleton.pl
	$(PUSH)

# Make files showing the order for versions of a test
midterm1.%.order: midterm1.skeleton scramble.pl
	$(PUSHSTAR)

midterm2.%.order: midterm2.skeleton scramble.pl
	$(PUSHSTAR)

final.%.order: final.skeleton scramble.pl
	$(PUSHSTAR)

.PRECIOUS: %.orders
Ignore += *.orders
%.orders: %.1.order %.2.order %.3.order %.4.order %.5.order orders.pl
	$(PUSH)

midterm1.orders:

######################################################################



## Put the test together

### Separator for MC and SA on the same test
Sources += end.dmu

Ignore += *.test
%.test: %.mc end.dmu %.ksa
	$(cat)

## Instructions added for 1M strictness; not sure whether to copy them over
Sources += sa_inst.tex

## This should be done better
Sources += copy.tex

######################################################################

.SECONDEXPANSION:
evaluation.now: %.now: $$(wildcard $$*/*)
	@echo $^

midterm2.test.pdf: evaluation/structure.bank
midterm2.5.test.pdf: evaluation/life_history.bank
midterm2.3.key.pdf: evaluation/life_history.bank
midterm2.4.rub.pdf: evaluation/structure.short

## Latex outputs

Sources += test.tmp
Ignore += *.test.tex *.test.pdf
%.test.tex: %.test test.tmp test.test.fmt talk/lect.pl
	$(PUSH)

Ignore += *.key.*
%.key.tex: %.test test.tmp key.test.fmt talk/lect.pl
	$(PUSH)

## Why are rubric dependencies different??
Ignore += *.rub.*
%.rub.tex: %.ksa test.tmp rub.test.fmt talk/lect.pl
	$(PUSH)

######################################################################

###### Marking ######

### Moved to Grading 2019

### Deleted apparently outdated stuff 2019 Apr 23 (Tue)

######################################################################

## Grade sheet scripts ##
## I guess this would be good to have somewhere else, for simplicity

## Principled approach to NAs: add text NA for an MSAF
## Use a perl script to replace blanks with zeroes

## Not clear why I'm keeping different tsvs in pulldir, but it's not hurting much.

## Drops are people marked as not matching by the Avenue import
## Working on obsoleting this in Grading
Ignore += marks.tsv
marks.tsv: pulldir/marks3.tsv zero.pl
	$(PUSH)
TAmarks.Rout: marks.tsv pulldir/drops.csv TAmarks.R
TAmarks.Rout.csv: TAmarks.R

## Not clear if Avenue interprets "-" correctly (or else sets to 0)
Sources += na_fake.pl
Ignore += TAmarks.avenue.csv
TAmarks.avenue.csv: TAmarks.Rout.csv na_fake.pl
	$(PUSH)

######################################################################

## Question analysis

## Need to unscramble and other nonsense; there is still stuff in content

######################################################################

pushdir = ../web/evaluations

######################################################################

midterm2.1.exam.pdf:

## Print versions and printing

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
