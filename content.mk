
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

## Latex outputs

midterm2.test.pdf: evaluation/structure.bank
midterm2.5.test.pdf: evaluation/life_history.bank
midterm2.3.key.pdf: evaluation/life_history.bank
midterm2.4.rub.pdf: evaluation/structure.short

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

