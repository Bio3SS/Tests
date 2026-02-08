## This is Tests, a screens project directory under 3SS
## Includes test and marking machinery (because both depend on scramble stuff)

## https://avenue.cllmcmaster.ca/

## Old course, weird sub-location
## https://avenue.cllmcmaster.ca/d2l/lms/quizzing/admin/quizzes_manage.d2l?ou=371137

current: target
-include target.mk

-include makestuff/newtalk.def
-include makestuff/perl.def

######################################################################

# Content

vim_session:
	bash -cl "vmt content.mk evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank"

######################################################################

## Directories

pardirs += evaluation boxes ts bd_models
pardirs += Life_tables competition exploitation compensation
pardirs += sims

hotdirs += $(pardirs)

pull: $(pardirs:%=%.pull)

######################################################################

## AVenue 2020 Apr 17 (Fri)
## How to use the test banks for a REMOTE test

Sources += avenue_template.csv avenue1.csv

######################################################################

# Archive

## Start the year by tagging last year's questions.
## DON'T do this until you update the year in archive.pl
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

## MC banks

Ignore += midterm1.bank
midterm1.bank: midterm1.formulas evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank
	$(cat)

evaluation/corona.bank:

Ignore += midterm2.bank
midterm2.bank: midterm2.formulas evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank evaluation/life_history.bank evaluation/comp.bank evaluation/pred.bank
	$(cat)

Sources += final.md
Ignore += final.bank
final.bank: final.formulas evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank evaluation/life_history.bank evaluation/comp.bank evaluation/pred.bank evaluation/disease.bank evaluation/helping.bank
	$(cat)

######################################################################

## Bad experiments

Ignore += pdtab.*
## pdtab.pdf: evaluation/pdtab.tsv
pdtab.tex: evaluation/pdtab.tsv
	Rscript -e 'library(knitr); library(readr); read_tsv("$<") |> kable(format="latex" , col.names = NULL) |> writeLines("$@")'

Ignore += alert.pdf
alert.pdf: evaluation/alert.md
	$(ltx_r)

######################################################################

# MC selection
# Use lect/select.format

# final.mc:
.PRECIOUS: %.mc
Ignore += *.mc
%.mc: %.bank null.tmp %.select.fmt newtalk/lect.pl
	$(PUSH)

######################################################################

## mcave.pl does not recognize KEY; be redundant

## Avenue csv files
Ignore += *.mc.csv
%.mc.csv: %.mc mcave.pl
	$(PUSH)

## Resource files for Avenue tests
## final.resource.test: final.mc rt.pl
## final.resource.test: final.mc rt.pl
%.resource.test: %.mc rt.pl
	$(PUSH)

check.pdf: midterm1.5.key.pdf
	$(forcelink)

## Blank version numbers don't work well with changing SA questions
## midterm1.2.key.tex: evaluation/linear.bank evaluation/nonlinear.bank
## midterm1.2.key.pdf: evaluation/linear.bank evaluation/nonlinear.bank
## midterm1.2.rub.pdf: evaluation/linear.bank evaluation/nonlinear.bank

## midterm1.test.pdf: evaluation/linear.bank evaluation/nonlinear.bank
## midterm1.1.test.pdf: evaluation/linear.short evaluation/nonlinear.short
## midterm1.resource.test.pdf: evaluation/linear.bank evaluation/nonlinear.bank
## midterm1.1.key.pdf: evaluation/linear.bank evaluation/nonlinear.bank
## midterm1.mc.csv:  evaluation/linear.bank evaluation/nonlinear.bank

## midterm2.resource.test.pdf: 
## midterm2.mc.csv:  midterm2.mc
## midterm2.key.pdf: evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank evaluation/life_history.bank evaluation/comp.bank evaluation/corona.bank

## midterm2.test.pdf:
## midterm2.key.pdf:

## final.resource.test.pdf:
## final.test.pdf:
## final.key.pdf:
## final.1.test.pdf:
## final.mc.csv: evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank evaluation/life_history.bank evaluation/comp.bank evaluation/pred.bank evaluation/disease.bank
## final.mc.csv: mcave.pl

######################################################################

# Scramble

## Bank should not be scrambled, make these directly

## bank.fmt is stupid; we should be making bank.select.fmt from lect/select.format

Sources += bank.fmt

######################################################################

## Is it scrambling? It looks like midterms are scrambled twice
## 2022 Apr 11 (Mon) We have debt from covid, I guess?

# midterm1.1.smc:

Sources += $(wildcard *.pl)

Ignore += *.smc
midterm1.bank.smc midterm2.bank.smc: %.smc: % null.tmp bank.fmt newtalk/lect.pl
	$(PUSH)

midterm1.%.smc: midterm1.mc scramble.pl
	$(PUSHSTAR)
midterm2.%.smc: midterm2.mc scramble.pl
	$(PUSHSTAR)

midterm1.smc midterm2.smc:  %.smc: %.mc
	$(copy)

######################################################################

## Generic tests are midterms with MC and SA
## The final is just MC so has its own rules here

# final.1.final.pdf: evaluation/disease.bank
.PRECIOUS: final.%.test
final.%.test: final.mc scramble.pl
	$(PUSHSTAR)

final.test: final.mc
	$(copy)

######################################################################

## Select short answers

midterm1.sa:

# SA banks
Ignore += *.short.test
Sources += sahead.short
midterm1.short.test: sahead.short evaluation/linear.short evaluation/nonlinear.short evaluation/structure.short
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

midterm1.vsa midterm2.vsa: %.vsa: %.sa testselect.pl
	perl -wf $(filter %.pl, $^) 2 $(filter-out %.pl, $^) > $@

midterm1.%.vsa: midterm1.sa testselect.pl
	$(PUSHSTAR)

midterm2.%.vsa: midterm2.sa testselect.pl
	$(PUSHSTAR)

## Convert versioned sa to rmd style
Ignore += *.rsa
.PRECIOUS: %.rsa
%.rsa: %.vsa lect/knit.fmt newtalk/lect.pl
	$(PUSH)

## and finally knit
knit = echo 'knitr::knit("$<", "$@")' | R --vanilla
Ignore += *.ksa
.PRECIOUS: %.ksa
%.ksa: %.rsa
	$(knit)

######################################################################

## Put the test together

#  midterm1.1.test:
#  midterm1.bank.test.pdf:
#  midterm2.bank.key.pdf:

### Separator for MC and SA on the same test
Sources += end.dmu

Ignore += *.test
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
## midterm1.1.rub.pdf: evaluation/structure.short
## midterm1.3.key.pdf: evaluation/linear.short

## midterm2.test.pdf: evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank evaluation/life_history.bank evaluation/comp.bank
## midterm2.1.test.pdf: evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank evaluation/life_history.bank evaluation/comp.bank
## midterm2.1.key.pdf: evaluation/linear.bank evaluation/nonlinear.bank evaluation/structure.bank evaluation/life_history.bank evaluation/comp.bank
#### evaluation/pred.bank

## midterm2.1.key.pdf: evaluation/nonlinear.bank evaluation/nonlinear.short
## midterm2.4.rub.pdf: evaluation/structure.short evaluation/life_history.short

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

Sources += scantron.jpg

## midterm2.3.exam.pdf:
## midterm2.3.test.log

## Printed midterm
## Cover pages handled differently from final
## This is because the final cover needs to know the number of pages
## so it's part of the main tex document
## Would be good to get the version number on front of the midterm!
## Check which midterm and update numbers and so forth
Sources += samcmidterm.tex mcmidterm.tex
## mcmidterm.pdf: mcmidterm.tex

## Add cover pages and such
Ignore += *.exam.tex *.exam.pdf *.front.pdf
## midterm1.1.exam.pdf: samcmidterm.tex
midterm1.%.exam.pdf: samcmidterm.pdf midterm1.%.test.pdf
	$(pdfcat)

## midterm2.5.exam.pdf: samcmidterm.tex
midterm2.%.exam.pdf: samcmidterm.pdf midterm2.%.test.pdf
	$(pdfcat)

### we handle testver twice (redundant code)
### examno.pl does something for the cover page on the final
### midterms (and final body?) are handled by scramble.pl
### Better way might be separate .tmp for the tests, just like
### we have versioned .tmp for the exam
### 5 versions for midterms
### Specify version 6 to get Deferred for exam
Sources += final.tmp examno.pl final.cover.tex
## final.6.final.pdf: final.tmp 
## final.3.test:

final.%.tmp: final.tmp examno.pl
	$(PUSHSTAR)

Ignore += *.final.tex
%.final.tex: %.test %.tmp test.test.fmt newtalk/lect.pl
	$(PUSH)

######################################################################

pushdir = ../web/materials

######################################################################

## Printing

## https://mps.mcmaster.ca/services/printing-services/
## account # MAC01 206000301032330000

## White, orchid, green, salmon 
## White, pink, green, yellow 
## Two-sided, stapled

## midterm1.1.key.pdf: evaluation/linear.short evaluation/nonlinear.short

midterm1_ship: midterm1.1.exam.pdf.go midterm1.2.exam.pdf.go midterm1.3.exam.pdf.go midterm1.4.exam.pdf.go midterm1.5.exam.pdf.go
## /bin/cp -f $^ ~/Downloads

## Push tests and keys with the same command
midterm1_post: midterm1.1.test.pdf.pd midterm1.2.test.pdf.pd midterm1.3.test.pdf.pd midterm1.4.test.pdf.pd midterm1.5.test.pdf.pd
midterm1_post: midterm1.1.key.pdf.pd midterm1.2.key.pdf.pd midterm1.3.key.pdf.pd midterm1.4.key.pdf.pd midterm1.5.key.pdf.pd

midterm1.rub.zip: midterm1.1.rub.pdf midterm1.2.rub.pdf midterm1.3.rub.pdf
	## midterm1.4.rub.pdf midterm1.5.rub.pdf
	$(ZIP)

midterm2_splat: midterm2.1.exam.pdf.go midterm2.2.exam.pdf.go midterm2.3.exam.pdf.go midterm2.4.exam.pdf.go midterm2.5.exam.pdf.go

midterm2_post: midterm2.1.test.pdf.pd midterm2.2.test.pdf.pd midterm2.3.test.pdf.pd midterm2.4.test.pdf.pd midterm2.5.test.pdf.pd
midterm2_post: midterm2.1.key.pdf.pd midterm2.2.key.pdf.pd midterm2.3.key.pdf.pd midterm2.4.key.pdf.pd midterm2.5.key.pdf.pd

midterm2.rub.zip: midterm2.1.rub.pdf midterm2.2.rub.pdf midterm2.3.rub.pdf midterm2.4.rub.pdf midterm2.5.rub.pdf
	$(ZIP)

## Search email for Exam Upload Instructions (or notice when email arrives and do something)
# http://macdrive.mcmaster.ca/u/d/4ce0683ccb1f49cca555/ (2019 deferred)
# B5%m3dG6

Ignore += $(wildcard Bio_3SS3*.pdf) 
Ignore += $(wildcard final*final.pdf) 
final_ship: final.1.final.pdf final.2.final.pdf final.2.final.pdf final.4.final.pdf ;
final_upload: final_ship Bio_3SS3_C01_V1.pdf Bio_3SS3_C01_V2.pdf Bio_3SS3_C01_V3.pdf Bio_3SS3_C01_V4.pdf Bio_3SS3_C01_V5.pdf
	/bin/cp Bio_3SS3_C01*.pdf ~/Downloads
defer: Bio_3SS3_C01_V6.pdf
	/bin/cp $< ~/Downloads

## Finalizing
## final.1.final.pdf:

Bio_3SS3_C01_V%.pdf: final.%.final.pdf
	$(forcelink)

## final.6.final.pdf:
## Bio_3SS3_C01_V6.pdf: 

######################################################################

## After the test, but before the next test, archive the scantron file
## Bleah, just save it on the Dropbox maybe

## We really want to base the key on the human-readable key.tex
## For now, just be really carefully about checking
# midterm2.1.ssv:
Ignore += *.ssv
.PRECIOUS: midterm%.ssv
midterm%.ssv: midterm%.smc key.pl
	$(PUSH)

## final.1.ssv
.PRECIOUS: final.%.ssv
final.%.ssv: final.%.test key.pl
	$(PUSH)

######################################################################

## Marking the 2024 Deferred exam by hand

Ignore += *.manual
## final.6.manual: final.6.ssv manual.pl
final.%.manual: final.%.ssv manual.pl
	$(PUSH)

# Make a special answer key for scantron processing
# To allow multiple answers, use KEY in the .bank file
# Does not work yet for self-scoring
# midterm1.1.sc.csv:
Ignore += *.sc.csv
%.sc.csv: %.ssv scantron.pl
	$(PUSH)

## Put scantron files on macdrive for mps
## diff midterm2.scantron.csv ~/Downloads/midterm1.scantron.csv ##
Ignore += *.scantron.csv
## midterm1.scantron.csv:
## midterm2.scantron.csv:
## final.key.pdf: evaluation/linear.bank
## final.1.key.pdf:
## final.scantron.csv:

## How many versions did you print??
# Combine a bunch of scantron keys into a file for the processors
midterm1.scantron.csv midterm2.scantron.csv: %.scantron.csv: %.1.sc.csv %.2.sc.csv %.3.sc.csv %.4.sc.csv %.5.sc.csv
	$(cat)

final.scantron.csv: %.scantron.csv: %.1.sc.csv %.2.sc.csv %.3.sc.csv %.4.sc.csv %.5.sc.csv
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
-include makestuff/texi.mk
-include makestuff/hotcold.mk
-include makestuff/pandoc.mk

-include makestuff/git.mk
-include makestuff/visual.mk
-include makestuff/projdir.mk
