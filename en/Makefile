sources := \
	00book.tex \
	99book.bib \
	99defs.tex \
	mq.tex

example-sources := \
	examples/run-example \
	examples/mq.qinit-help \
	examples/mq.tutorial

latex-options = \
	-interaction batchmode \
	-output-directory $(dir $(1)) \
	-jobname $(basename $(notdir $(1)))

all: pdf html

pdf: pdf/hgbook.pdf

pdf/hgbook.pdf: $(sources) examples
	mkdir -p $(dir $@)
	pdflatex $(call latex-options,$@) $< || (rm -f $@; exit 1)
	cp 99book.bib $(dir $@)
	cd $(dir $@) && bibtex $(basename $(notdir $@))
	pdflatex $(call latex-options,$@) $< || (rm -f $@; exit 1)
	pdflatex $(call latex-options,$@) $< || (rm -f $@; exit 1)

html: html/onepage/hgbook.html html/split/hgbook.html

define htlatex
	mkdir -p $(dir $(1))
	head -2 $(shell which htlatex) > $(dir $(1))/htlatex.book
	cp 99book.bib $(dir $@)
	echo '(cd $(dir $@) && bibtex $(basename $(notdir $@)))' >> $(dir $(1))/htlatex.book
	head -3 $(shell which htlatex) >> $(dir $(1))/htlatex.book
	echo 'echo status $$$$' >>  $(dir $(1))/htlatex.book
	chmod 755 $(dir $(1))/htlatex.book
	$(dir $(1))/htlatex.book $(2) "xhtml,html4-uni,$(3)" " -cunihtf -utf8" "" "$(call latex-options,$(1))" || (rm -f $(1); exit 1)
	cd $(dir $(1)) && tex4ht -f/$(basename $(notdir $(1))) -cvalidate -cunihtf
	cd $(dir $(1)) && t4ht -f/$(basename $(notdir $(1)))
	perl -pi -e 's/&#x00([0-7][0-9a-f]);/chr(hex($$1))/egi' $(dir $(1))/*.html
endef

html/onepage/hgbook.html: $(sources) examples
	$(call htlatex,$@,$<)

html/split/hgbook.html: $(sources) examples
	$(call htlatex,$@,$<,2)

.PHONY: examples

examples: examples/.run

examples/.run: $(example-sources)
	cd examples && ./run-example

clean:
	rm -rf html pdf *.aux *.dvi *.log *.out examples/*.out examples/.run
