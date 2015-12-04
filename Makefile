help:
	@echo "Targets:"
	@echo "========"
	@echo "make html"
	@echo "make html-single"
	@echo "make pdf"
	@echo "make gettext"

example-sources := $(wildcard en/examples/*.t) $(wildcard en/examples/ch*/*)

fig-source-dot := $(wildcard en/figs/*.dot)
fig-source-svg := $(wildcard en/figs/*.svg)
fig-source-gif := $(wildcard en/figs/*.gif)
fig-source-png := $(wildcard en/figs/*.png)
fig-targets := $(fig-source-dot:%.dot=%.png) $(fig-source-svg:%.svg=%.png) $(fig-source-gif) $(fig-source-png)

#TODO: return code
en/examples/.run: $(example-sources)
	mkdir -p en/examples/results
	$(PRETEST) (cd en/examples && ./run-tests.py --with-hg=`which hg` -j `nproc` --keep-outputdir && ./process-examples.py && ./process-configfiles.py)

.PHONY: examples
examples: en/examples/.run

en/figs/%.svg: en/figs/%.dot
	dot -Tsvg -o $@ $<

en/figs/%.png: en/figs/%.svg
	rm -f $<-tmp.svg
	en/fixsvg $<
	inkscape -D --export-png=$@ $<-tmp.svg
	rm $<-tmp.svg

images: $(fig-targets)

html: examples images
	sphinx-build en build/html

html-single: examples images
	sphinx-build -b singlehtml en build/html-single

pdf: examples images
	#requires rst2pdf
	sphinx-build -b pdf en build/pdf

gettext: examples images
	sphinx-build -b gettext en build/gettext
