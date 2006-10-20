# This makefile requires GNU make.

hg_id := $(shell hg parents --template '{node|short}\n')

sources := \
	00book.tex \
	99book.bib \
	99defs.tex \
	build_id.tex \
	concepts.tex \
	daily.tex \
	hook.tex \
	intro.tex \
	mq.tex \
	mq-collab.tex \
	mq-ref.tex \
	preface.tex \
	srcinstall.tex \
	template.tex \
	tour-basic.tex \
	tour-merge.tex

image-sources := \
	kdiff3.png \
	mq-stack.svg \
	tour-history.svg \
	tour-merge-conflict.svg \
	tour-merge-merge.svg \
	tour-merge-pull.svg \
	tour-merge-sep-repos.svg

image-svg := $(filter %.svg,$(image-sources))

example-sources := \
	daily.files \
	hook.msglen \
	hook.simple \
	hook.ws \
	mq.guards \
	mq.qinit-help \
	mq.dodiff \
	mq.id \
	mq.tarball \
	mq.tools \
	mq.tutorial \
	template.simple \
	template.svnstyle \
	tour \
	tour-merge-conflict

latex-options = \
	-interaction batchmode \
	-output-directory $(dir $(1)) \
	-jobname $(basename $(notdir $(1)))

all: pdf html

pdf: pdf/hgbook.pdf

define pdf
	mkdir -p $(dir $@)
	TEXINPUTS=$(dir $<): pdflatex $(call latex-options,$@) $< || (rm -f $@; exit 1)
	cp 99book.bib $(dir $@)
	cd $(dir $@) && bibtex $(basename $(notdir $@))
	cd $(dir $@) && makeindex $(basename $(notdir $@))
	TEXINPUTS=$(dir $<): pdflatex $(call latex-options,$@) $< || (rm -f $@; exit 1)
	TEXINPUTS=$(dir $<): pdflatex $(call latex-options,$@) $< || (rm -f $@; exit 1)
	if grep 'Reference.*undefined' $(@:.pdf=.log); then exit 1; fi
endef

pdf/hgbook.pdf: $(sources) $(image-sources:%.svg=%.pdf) examples
	$(call pdf)

html: html/onepage/hgbook.html html/split/hgbook.html

# This is a horrible hack to work around the fact that the htlatex
# command in tex4ht is itself a horrible hack.  I really don't want to
# include verbatim the big wad of TeX that is repeated in that script,
# so instead I mangle the script itself.

define htlatex
	mkdir -p $(dir $(1))
	head -2 $(shell which htlatex) > $(dir $(1))/htlatex.book
	cp 99book.bib $(dir $@)
	echo '(cd $(dir $@) && bibtex $(basename $(notdir $@)))' >> $(dir $(1))/htlatex.book
	echo '(cd $(dir $@) && makeindex $(basename $(notdir $@)))' >> $(dir $(1))/htlatex.book
	head -3 $(shell which htlatex) >> $(dir $(1))/htlatex.book
	echo 'echo status $$$$' >>  $(dir $(1))/htlatex.book
	chmod 755 $(dir $(1))/htlatex.book
	TEXINPUTS=$(dir $(2)): $(dir $(1))/htlatex.book $(2) "xhtml,html4-uni,$(3)" " -cunihtf -utf8" "" "$(call latex-options,$(1))" || (rm -f $(1); exit 1)
	cd $(dir $(1)) && tex4ht -f/$(basename $(notdir $(1))) -cvalidate -cunihtf
	cd $(dir $(1)) && t4ht -f/$(basename $(notdir $(1)))
	perl -pi -e 's/&#x00([0-7][0-9a-f]);/chr(hex($$1))/egi' $(dir $(1))/*.html
endef

html/onepage/hgbook.html: $(sources) $(image-sources:%.svg=%.png) examples
	$(call htlatex,$@,$<)
	cp $(image-sources:%.svg=%.png) $(dir $@)

html/split/hgbook.html: $(sources) $(image-sources:%.svg=%.png) examples
	$(call htlatex,$@,$<,2)
	cp $(image-sources:%.svg=%.png) $(dir $@)

beta: beta/pdf/hgbook.pdf beta/html/onepage/hgbook.html beta/html/split/hgbook.html

beta/%.tex: %.tex
	./fblinks $(hg_id) $(dir $@) $<

beta/pdf/hgbook.pdf: $(sources:%.tex=beta/%.tex) $(image-sources:%.svg=%.pdf) examples fblinks
	$(call pdf)

beta/html/onepage/hgbook.html: $(sources:%.tex=beta/%.tex) $(image-sources:%.svg=%.png) examples
	$(call htlatex,$@,$<)
	cp $(image-sources:%.svg=%.png) $(dir $@)

beta/html/split/hgbook.html: $(sources:%.tex=beta/%.tex) $(image-sources:%.svg=%.png) examples
	$(call htlatex,$@,$<,2)
	cp $(image-sources:%.svg=%.png) $(dir $@)

# Produce 90dpi PNGs for the web.

%.png: %.svg
	inkscape -D -e $@ $<

# Produce eps & pdf for the pdf

%.pdf: %.eps
	epstopdf $<

%.eps: %.svg
	inkscape -E $@ $<

examples: examples/.run

examples/.run: $(example-sources:%=examples/%.run)
	touch examples/.run

examples/%.run: examples/% examples/run-example
	cd examples && ./run-example $(notdir $<)

build_id.tex: $(wildcard ../.hg/00changelog.[id])
	echo -n $(hg_id) > build_id.tex

clean:
	rm -rf beta html pdf \
		$(image-svg:%.svg=%.pdf) \
		$(image-svg:%.svg=%.png) \
		examples/*.{out,run} examples/.run build_id.tex
