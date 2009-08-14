# This makefile requires GNU make.

sources := \
	00book.tex \
	99book.bib \
	99defs.tex \
	build_id.tex \
	branch.tex \
	collab.tex \
	concepts.tex \
	custom.sty \
	daily.tex \
	filenames.tex \
	hg_id.tex \
	hgext.tex \
	hook.tex \
	intro.tex \
	mq.tex \
	mq-collab.tex \
	preface.tex \
	srcinstall.tex \
	template.tex \
	tour-basic.tex \
	tour-merge.tex \
	undo.tex \


image-sources := \
	feature-branches.dot \
	filelog.svg \
	kdiff3.png \
	metadata.svg \
	mq-stack.svg \
	note.png \
	revlog.svg \
	snapshot.svg \
	tour-history.svg \
	tour-merge-conflict.svg \
	tour-merge-merge.svg \
	tour-merge-pull.svg \
	tour-merge-sep-repos.svg \
	undo-manual.dot \
	undo-manual-merge.dot \
	undo-non-tip.dot \
	undo-simple.dot \
	wdir.svg \
	wdir-after-commit.svg \
	wdir-branch.svg \
	wdir-merge.svg \
	wdir-pre-branch.svg \


image-dot := $(filter %.dot,$(image-sources))
image-svg := $(filter %.svg,$(image-sources))
image-png := $(filter %.png,$(image-sources))

image-pdf := \
	$(image-dot:%.dot=%.pdf) \
	$(image-svg:%.svg=%.pdf) \
	$(image-png) \


bb-pdf := \
	$(image-dot:%.dot=%.bb) \
	$(image-svg:%.svg=%.bb) \
	$(image-png:%.png=%.bb) \


image-html := \
	$(image-dot:%.dot=%.png) \
	$(image-svg:%.svg=%.png) \
	$(image-png) \


example-sources := \
	backout \
	bisect \
	branching \
	branch-named \
	branch-repo \
	cmdref \
	daily.copy \
	daily.files \
	daily.rename \
	daily.revert \
	extdiff \
	filenames \
	hook.msglen \
	hook.simple \
	hook.ws \
	issue29 \
	mq.guards \
	mq.qinit-help \
	mq.dodiff \
	mq.id \
	mq.tarball \
	mq.tools \
	mq.tutorial \
	rename.divergent \
	rollback \
	tag \
	template.simple \
	template.svnstyle \
	tour \
	tour-merge-conflict \


example-prereqs := \
	/usr/bin/merge \


binary-staffs := \
	kdiff3.png \
	note.png \
	examples/data/netplug-1.2.5.tar.bz2 \
	examples/data/netplug-1.2.8.tar.bz2 \


dist-sources := \
	../html/hgicon.png \
	../html/index.html.var \
	../html/index.en.html \


latex-options = \
	-interaction batchmode \
	-output-directory $(dir $(1)) \
	-jobname $(basename $(notdir $(1))) \

hg = $(shell which hg)

hg-id = 

hg-version = unknown

########################################

SVG2PNG = sh svg2png.sh

SVG2EPS = sh svg2eps.sh

GS = gs

MAKEINDEX= mendex -J -f

########################################

all: pdf html

pdf: pdf/hgbook.pdf

define pdf
	mkdir -p $(dir $@)
	platex $(call latex-options,$@) $(1) \
	|| (rm -f $@; exit 1)
	cp 99book.bib $(dir $@)
	cd $(dir $@) && jbibtex $(basename $(notdir $@))
	cd $(dir $@) && $(MAKEINDEX) $(basename $(notdir $@))
	platex $(call latex-options,$@) $(1) \
	|| (rm -f $@; exit 1)
	platex $(call latex-options,$@) $(1) \
	|| (rm -f $@; exit 1)
	export TEXINPUTS=..; cd $(dir $@) && dvipdfmx $(basename $(notdir $@))
#	if grep 'Reference.*undefined' $(@:.pdf=.log); then exit 1; fi
endef

pdf/hgbook.pdf: $(sources) atbegxxx.tex
pdf/hgbook.pdf: $(image-pdf)
pdf/hgbook.pdf: $(bb-pdf)
#pdf/hgbook.pdf: examples
pdf/hgbook.pdf: 00book_pdf.tex
	$(call pdf,00book_pdf.tex)

html: onepage split

htlatex := htlatex.sh

onepage: $(htlatex)
onepage: html/onepage/hgbook.html
onepage: html/onepage/hgbook.css
onepage: $(image-html:%=html/onepage/%)

html/onepage/%: %
	cp $< $@

split: $(htlatex)
split: html/split/hgbook.html
split: html/split/hgbook.css
split: $(image-html:%=html/split/%)

html/split/%: %
	cp $< $@

# This is a horrible hack to work around the fact that the htlatex
# command in tex4ht is itself a horrible hack.  I really don't want to
# include verbatim the big wad of TeX that is repeated in that script,
# but I've given up and run a hacked copy as htlatex.book here.

define htlatex
	mkdir -p $(dir $@)
	sh ./htlatex.sh \
		$(1) \
		"bookhtml,html4-uni,$(2)" \
		"$(call latex-options,$@)" \
	|| (rm -f $@; exit 1)
	cp 99book.bib $(dir $@)
	cd $(dir $@) && jbibtex $(basename $(notdir $@))
	cd $(dir $@) \
	&& jtex '\def\filename{{hgbook}{idx}{4dx}{ind}} \input idxmake.4ht' \
	&& $(MAKEINDEX) \
		-o $(basename $(notdir $@)).ind \
		$(basename $(notdir $@)).4dx
	sh ./htlatex.sh \
		$(1) \
		"bookhtml,html4-uni,$(2)" \
		"$(call latex-options,$@)" \
	|| (rm -f $@; exit 1)
	sh ./htlatex.sh \
		$(1) \
		"bookhtml,html4-uni,$(2)" \
		"$(call latex-options,$@)" \
	|| (rm -f $@; exit 1)
	cd $(dir $@) && tex4ht -f/$(basename $(notdir $@)) -cvalidate -cunihtf
	cd $(dir $@) && t4ht -f/$(basename $(notdir $@))
	python ./fixhtml.py $(dir $@)/*.html
	rm $(dir $@)/hgbook.css
endef

html/onepage/hgbook.html: $(sources)
html/onepage/hgbook.html: $(image-html)
#html/onepage/hgbook.html: examples
html/onepage/hgbook.html: bookhtml.cfg
html/onepage/hgbook.html: 00book_html.tex
	$(call htlatex,00book_html.tex)

html/split/hgbook.html: $(sources)
html/split/hgbook.html: $(image-html)
#html/split/hgbook.html: examples
html/split/hgbook.html: bookhtml.cfg
html/split/hgbook.html: 00book_html.tex
	$(call htlatex,00book_html.tex,2)

# Produce 90dpi PNGs for the web.

%.png: %.svg
	$(SVG2PNG) $@ $<

%.svg: %.dot
	dot -Tsvg -o $@ $<

# Produce eps/pdf/bb for the pdf

%.pdf: %.eps
	epstopdf $<

%.eps: %.svg
	$(SVG2EPS) $@ $<

%.eps: %.dot
	dot -Tps -o $@ $<

%.bb: %.pdf
	$(GS) -q -sDEVICE=bbox -dAutoRotatePages=/None - -c quit - \
		< $< > $@ 2>&1

%.bb: %.png
	ebb $<

examples: $(example-prereqs) $(binary-staffs) examples/.run

examples/.run: $(example-sources:%=examples/%.run)
	touch examples/.run

examples/%.run: examples/% examples/run-example
	cd examples && python ./run-example $(notdir $<)

changelog := $(wildcard ../.hg/store/00changelog.[id])
ifeq ($(changelog),)
changelog := $(wildcard ../.hg/00changelog.[id])
endif

build_id.tex: $(changelog)
	echo -n '$(hg-id)' > build_id.tex

hg_id.tex: $(hg)
	echo -n '$(hg-version)' > hg_id.tex

clean:
	rm -rf dist html pdf \
		$(image-dot:%.dot=%.pdf) \
		$(image-dot:%.dot=%.png) \
		$(image-dot:%.dot=%.bb) \
		$(image-svg:%.svg=%.pdf) \
		$(image-svg:%.svg=%.png) \
		$(image-svg:%.svg=%.bb) \
		$(image-png:%.png=%.bb) \
		examples/*.{lxo,run} examples/.run build_id.tex hg_id.tex
	rm -f atbegxxx.tex

install: pdf split $(dist-sources)
	rm -rf dist
	mkdir -p dist
	cp pdf/hgbook.pdf dist
	cp html/split/*.{css,html,png} dist
	cp $(dist-sources) dist

rsync: install
	rsync -avz --delete dist sp.red-bean.com:public_html/hgbook

##### these targets are needed because mq can not handle binary files

kdiff3.png:
	cp ../en/kdiff3.png .

note.png:
	cp ../en/note.png .

examples/data/netplug-1.2.5.tar.bz2:
	mkdir -p examples/data
	cp ../en/examples/data/netplug-1.2.5.tar.bz2 examples/data

examples/data/netplug-1.2.8.tar.bz2:
	mkdir -p examples/data
	cp ../en/examples/data/netplug-1.2.8.tar.bz2 examples/data
