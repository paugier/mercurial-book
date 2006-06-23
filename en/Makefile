sources := 00book.tex mq.tex

latex-options = \
	-interaction batchmode \
	-output-directory $(dir $(1)) \
	-jobname $(basename $(notdir $(1)))

all: pdf html

pdf: pdf/hgbook.pdf

pdf/hgbook.pdf: $(sources)
	mkdir -p $(dir $@)
	pdflatex $(call latex-options,$@) $< || (rm -f $@; exit 1)
	pdflatex $(call latex-options,$@) $< || (rm -f $@; exit 1)
	pdflatex $(call latex-options,$@) $< || (rm -f $@; exit 1)

html: html/onepage/hgbook.html html/split/hgbook.html

define htlatex
	mkdir -p $(dir $(1))
	head -4 $(shell which htlatex) > $(dir $(1))/htlatex.book
	chmod 755 $(dir $(1))/htlatex.book
	$(dir $(1))/htlatex.book $(2) "xhtml,html4-uni,$(3)" " -cunihtf -utf8" "" "$(call latex-options,$(1))" || (rm -f $(1); exit 1)
	cd $(dir $(1)) && tex4ht -f/$(basename $(notdir $(1))) -cvalidate -cunihtf
	cd $(dir $(1)) && t4ht -f/$(basename $(notdir $(1)))
endef

html/onepage/hgbook.html: $(sources)
	$(call htlatex,$@,$<)

html/split/hgbook.html: $(sources)
	$(call htlatex,$@,$<,2)

clean:
	rm -rf html pdf *.aux *.dvi *.log *.out
