# This makefile requires GNU make.

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
	wdir-pre-branch.svg

xml-src-files := \
	00book.xml \
	app*.xml \
	ch*.xml

image-dot := $(filter %.dot,$(image-sources))
image-svg := $(filter %.svg,$(image-sources))
image-png := $(filter %.png,$(image-sources))

image-html := $(image-dot:%.dot=%.png) $(image-svg:%.svg=%.png) $(image-png)

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
	tour-merge-conflict

obj-web := html
obj-websup := html/support

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

all: web

../xsl/system-xsl: $(system-xsl-dir)
	ln -s $< $@

web: ../xsl/system-xsl websup html

html: ../xsl/system-xsl $(xml-src-files) valid
	xsltproc $(xsltproc-opts) -o html/read/x ../xsl/chunk-stylesheet.xsl 00book.xml
	for i in html/read/*.html; do \
	  gzip -9 -c $$i > $$i.gz; \
	done

websup: $(extras-web)
	mkdir -p $(obj-websup)/figs
	cp ../xsl/system-xsl/images/*.png $(obj-websup)/figs
	cp -f ../web/icons/*.png $(obj-websup)/figs

web: websup

valid: .validated-00book.xml

.validated-00book.xml: $(xml-src-files)
	$(xmllint) --path '$(dtd-dir):$(xml-path)' $(xmllint-opts) $<
	touch $@

# Produce 90dpi PNGs for the web.

%.png: %.svg fixsvg
	./fixsvg $<
	inkscape -D -e $@ $<-tmp.svg
	rm $<-tmp.svg

%.svg: %.dot
	dot -Tsvg -o $@ $<

examples: $(example-prereqs) examples/.run

examples/.run: $(example-sources:%=examples/%.run)
	touch examples/.run

examples/%.run: examples/% examples/run-example
	cd examples && ./run-example $(notdir $<)

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
