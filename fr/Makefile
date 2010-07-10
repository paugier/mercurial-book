# This makefile requires GNU make.

image-sources := $(wildcard figs/*.dot figs/*.gif figs/*.png figs/*.svg)

xml-src-files := \
	00book.xml \
	app*.xml \
	ch*.xml

image-dot := $(filter %.dot,$(image-sources))
image-svg := $(filter %.svg,$(image-sources))
image-oth := $(filter %.gif %.png,$(image-sources))

obj-web := html
obj-websup := $(obj-web)/support
obj-web-read := $(obj-web)/read

image-web := \
	$(image-dot:%.dot=$(obj-web-read)/%.png) \
	$(image-svg:%.svg=$(obj-web-read)/%.png) \
	$(image-oth:%=$(obj-web-read)/%)

example-sources-by-name := \
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
	tour-merge-conflict

example-sources := \
	$(example-sources-by-name:%=examples/%) \
	$(wildcard examples/ch*/*)

extras-web-base := \
	$(obj-web)/index.html \
	$(obj-web)/robots.txt \
	$(obj-websup)/form-min.js \
	$(obj-websup)/form.js \
	$(obj-websup)/hsbook.js \
	$(obj-websup)/jquery-min.js \
	$(obj-websup)/jquery.js \
	$(obj-websup)/styles.css

extras-web := $(extras-web-base) $(extras-web-base:%=%.gz)

xsltproc := xsltproc
xsltproc-opts := --nonet --xinclude --path '$(xml-path)'

xmllint := xmllint
xmllint-opts := --noout --nonet --valid

system-xsl-dir := $(firstword $(wildcard \
	/usr/share/sgml/docbook/xsl-stylesheets \
	/usr/share/xml/docbook/stylesheet/nwalsh \
	))

# Bletcherousness.

ifneq ($(wildcard /usr/share/sgml/docbook/xml-dtd-4.4-*),)
dtd-dir := $(wildcard /usr/share/sgml/docbook/xml-dtd-4.4-*)
else
ifneq ($(wildcard /usr/share/xml/docbook/schema/dtd/4.4),)
dtd-dir := $(wildcard /usr/share/xml/docbook/schema/dtd/4.4)
else
$(error Do not know where to look for DocBook XML 4.4 DTD)
endif
endif

ifeq ($(system-xsl-dir),)
$(error add a suitable directory to system-xsl-dir)
endif

example-prereqs := \
	/usr/bin/merge

dist-sources := \
	../html/hgicon.png \
	../html/index.html.var \
	../html/index.en.html

hg = $(shell which hg)

hg-id = $(shell hg parents --template '{node|short}, dated {date|isodate},\n')

hg-version = $(shell hg version -q | \
		     sed 's,.*(version \(unknown\|[a-f0-9+]*\)),\1,')

all: web complete.xml

../stylesheets/system-xsl: $(system-xsl-dir)
	ln -s $< $@

web: ../stylesheets/system-xsl websup html

html: $(obj-web-read)/index.html

../web/index-read.html.in: ../web/genindex.py $(xml-src-files)
	cd ../web && ./genindex.py

$(obj-web-read)/index.html: ../stylesheets/system-xsl .validated-00book.xml ../web/index-read.html.in
	xsltproc $(xsltproc-opts) -o $(obj-web-read)/x ../stylesheets/chunk-stylesheet.xsl 00book.xml
	python ../web/texpand.py ../web/index-read.html.in html/read/index.html
	for i in $(obj-web-read)/*.html; do \
	  gzip -9 -c $$i > $$i.gz; \
	done

websup: $(extras-web) $(image-web)
	mkdir -p $(obj-websup)/figs $(obj-web-read)/figs
	cp ../stylesheets/system-xsl/images/*.png $(obj-websup)/figs
	cp -f ../web/icons/*.png $(obj-websup)/figs

complete.xml: .validated-00book.xml
	$(xsltproc) $(xsltproc-opts) -o $@ ../stylesheets/dtd-profile.xsl 00book.xml

all-ids.dat: ../stylesheets/all-ids.xsl $(xml-src-files)
	$(xsltproc) $(xsltproc-opts) -o $@ ../stylesheets/all-ids.xsl 00book.xml

web: websup

valid: .validated-00book.xml

.validated-00book.xml: $(xml-src-files) examples/.run
	$(xmllint) --path '$(dtd-dir):$(xml-path)' $(xmllint-opts) $<
	touch $@

# Produce 90dpi PNGs for the web.

$(obj-web-read)/figs/%.png: $(obj-web-read)/figs/%.svg fixsvg
	mkdir -p $(dir $@)
	./fixsvg $<
	inkscape -D -e $@ $<-tmp.svg
	rm $<-tmp.svg

$(obj-web-read)/figs/%.png: figs/%.svg fixsvg
	mkdir -p $(dir $@)
	./fixsvg $<
	inkscape -D -e $@ $<-tmp.svg
	rm $<-tmp.svg

$(obj-web-read)/figs/%.gif: figs/%.gif
	cp $< $@

$(obj-web-read)/figs/%.png: figs/%.png
	cp $< $@

$(obj-web-read)/figs/%.svg: figs/%.dot
	mkdir -p $(dir $@)
	dot -Tsvg -o $@ $<

examples: $(example-prereqs) examples/.run

examples/.run: $(example-sources)
	cd examples && ./run-example -a

examples/%.run: examples/% examples/run-example

clean:
	-rm -rf dist html $(image-dot:%.dot=%.pdf) $(image-dot:%.dot=%.png) \
	  $(image-svg:%.svg=%.png) examples/*.{lxo,run} examples/.run

install: html $(dist-sources)
	rm -rf dist
	mkdir -p dist
	cp html/*.{css,html,png} dist
	cp $(dist-sources) dist

rsync: install
	rsync -avz --delete dist sp.red-bean.com:public_html/hgbook

vpath %.css ../web
vpath %.html.in ../web
vpath %.js ../web/javascript

$(obj-websup)/%.css: %.css
	@mkdir -p $(dir $@)
	cp $< $@

$(obj-websup)/%.jpg: %.jpg
	@mkdir -p $(dir $@)
	cp $< $@

$(obj-websup)/%.js: %.js
	@mkdir -p $(dir $@)
	cp $< $@

$(obj-web)/%: ../web/%
	@mkdir -p $(dir $@)
	cp $< $@

$(obj-web)/%.html: %.html.in
	@mkdir -p $(dir $@)
	python ../web/texpand.py $< $@

%.gz: %
	gzip -9 -c $< > $@
