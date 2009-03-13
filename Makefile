#
# Makefile for the hgbook, top-level
#

FORMATS=html html-single pdf

PO_LANGUAGES := zh
DBK_LANGUAGES := en
LANGUAGES := $(DBK_LANGUAGES) $(PO_LANGUAGES)

UPDATEPO = PERLLIB=../tools/po4a/lib/ ../tools/po4a/po4a-updatepo -M UTF-8 \
	   -f docbook -o doctype='docbook' -o includeexternal \
	   -o nodefault='<programlisting> <screen>' \
	   -o untranslated='<programlisting> <screen>'
TRANSLATE = PERLLIB=tools/po4a/lib/ tools/po4a/po4a-translate -M UTF-8 \
	   -f docbook -o doctype='docbook' \
	   -k 0

#rev_id = $(shell hg parents --template '{node|short} ({date|isodate})')
rev_id = $(shell hg parents --template '{node|short} ({date|shortdate})')

images := \
	en/images/feature-branches.png \
	en/images/filelog.png \
	en/images/metadata.png \
	en/images/mq-stack.png \
	en/images/revlog.png \
	en/images/snapshot.png \
	en/images/tour-history.png \
	en/images/tour-merge-conflict.png \
	en/images/tour-merge-merge.png \
	en/images/tour-merge-pull.png \
	en/images/tour-merge-sep-repos.png \
	en/images/undo-manual-merge.png \
	en/images/undo-manual.png \
	en/images/undo-non-tip.png \
	en/images/undo-simple.png \
	en/images/wdir-after-commit.png \
	en/images/wdir-branch.png \
	en/images/wdir-merge.png \
	en/images/wdir.png \
	en/images/wdir-pre-branch.png

help:
	@echo "  make html         [LINGUA=en|zh|...]"
	@echo "  make html-single  [LINGUA=en|zh|...]"
	@echo "  make pdf          [LINGUA=en|zh|...]"
	@echo "  make validate     [LINGUA=en|zh|...] # always before commit!"
	@echo "  make tidypo       [LINGUA=zh|...]    # always before commit!"
	@echo "  make updatepo     [LINGUA=zh|...]    # update po files."
	@echo "  make all          [LINGUA=en|zh|...]"
	@echo "  make stat         # print statistics about po files."
	@echo "  make clean        # Remove the build files."

clean:
	@rm -fr build po/*.mo hello en/hello en/html en/.validated-00book.xml \
          stylesheets/system-xsl en/images/*-tmp.svg \
          en/images/feature-branches.png \
          en/images/filelog.png \
          en/images/feature-branches.png \
          en/images/filelog.png \
          en/images/metadata.png \
          en/images/mq-stack.png \
          en/images/revlog.png \
          en/images/snapshot.png \
          en/images/tour-history.png \
          en/images/tour-merge-conflict.png \
          en/images/tour-merge-merge.png \
          en/images/tour-merge-pull.png \
          en/images/tour-merge-sep-repos.png \
          en/images/undo-manual-merge.png \
          en/images/undo-manual.png \
          en/images/undo-non-tip.png \
          en/images/undo-simple.png \
          en/images/wdir-after-commit.png \
          en/images/wdir-branch.png \
          en/images/wdir-merge.png \
          en/images/wdir-pre-branch.png \
          en/images/wdir.png

all:
ifdef LINGUA
	for f in $(FORMATS); do \
	  $(MAKE) LINGUA=$(LINGUA) $$f; \
	done
else
	for l in $(LANGUAGES); do \
	    for f in $(FORMATS); do \
		$(MAKE) LINGUA=$$l $$f; \
	    done; \
	done
endif

stat:
	@( \
	LANG=C; export LANG; cd po; \
	for f in *.po; do \
	    printf "%s\t" $$f; \
	    msgfmt --statistics -c $$f; \
	done; \
	)

tidypo:
ifdef LINGUA
	msgcat --sort-by-file --width=80 po/$(LINGUA).po > po/$(LINGUA).tmp && \
	    mv po/$(LINGUA).tmp po/$(LINGUA).po;
else
	for po in $(wildcard po/*.po); do \
	    msgcat --sort-by-file --width=80 $$po > $$po.tmp && mv $$po.tmp $$po; \
	done
endif

ifndef LINGUA
updatepo:
	for l in $(PO_LANGUAGES); do \
	    $(MAKE) $@ LINGUA=$$l; \
	done
else
updatepo:
ifneq "$(findstring $(LINGUA),$(PO_LANGUAGES))" ""
	(cd po && $(UPDATEPO) -m ../en/00book.xml -p $(LINGUA).po)
	$(MAKE) tidypo LINGUA=$(LINGUA)
endif
endif

ifndef LINGUA
validate:
	for l in $(LANGUAGES); do \
	    $(MAKE) $@ LINGUA=$$l; \
	done
else
validate: build/$(LINGUA)/source/hgbook.xml
	xmllint --nonet --noout --postvalid --xinclude $<

ifneq "$(findstring $(LINGUA),$(DBK_LANGUAGES))" ""
build/$(LINGUA)/source/hgbook.xml: $(wildcard $(LINGUA)/*.xml) $(images)
	mkdir -p build/$(LINGUA)/source
	cp -r $(LINGUA)/* build/$(LINGUA)/source
	xmllint --nonet --noent --xinclude --postvalid --output $@.tmp $(LINGUA)/00book.xml
	cat $@.tmp | sed 's/\$$rev_id\$$/${rev_id}/' > $@
else
build/$(LINGUA)/source/hgbook.xml: $(wildcard en/*.xml) po/$(LINGUA).po $(images)
	mkdir -p build/$(LINGUA)/source
	cp -r en/images build/$(LINGUA)/source
	cp -r en/examples build/$(LINGUA)/source
	cp en/book-shortcuts.xml build/$(LINGUA)/source
	for f in en/*.xml; do \
	  if [ $$f != "en/book-shortcuts.xml" ]; then \
	    $(TRANSLATE) -m $$f -p po/$(LINGUA).po -l build/$(LINGUA)/source/`basename $$f`; \
	  fi \
	done
	xmllint --nonet --noent --xinclude --postvalid --output $@.tmp build/$(LINGUA)/source/00book.xml
	cat $@.tmp | sed 's/\$$rev_id\$$/${rev_id}/' > $@
endif

endif

ifndef LINGUA
html:
	for l in $(LANGUAGES); do \
	    $(MAKE) $@ LINGUA=$$l; \
	done
else
html: build/$(LINGUA)/html/index.html

build/$(LINGUA)/html/index.html: build/$(LINGUA)/source/hgbook.xml stylesheets/html.xsl stylesheets/$(LINGUA)/html.xsl
	mkdir -p build/$(LINGUA)/html/images
	cp en/images/*.png build/$(LINGUA)/html/images
	cp stylesheets/hgbook.css build/$(LINGUA)/html
	xsltproc --output build/$(LINGUA)/html/ \
	    stylesheets/$(LINGUA)/html.xsl build/$(LINGUA)/source/hgbook.xml
endif

ifndef LINGUA
html-single:
	for l in $(LANGUAGES); do \
	    $(MAKE) $@ LINGUA=$$l; \
	done
else
html-single: build/$(LINGUA)/html-single/hgbook.html

build/$(LINGUA)/html-single/hgbook.html: build/$(LINGUA)/source/hgbook.xml stylesheets/html-single.xsl stylesheets/$(LINGUA)/html-single.xsl
	mkdir -p build/$(LINGUA)/html-single/images
	cp en/images/*.png build/$(LINGUA)/html-single/images
	cp stylesheets/hgbook.css build/$(LINGUA)/html-single
	xsltproc --output build/$(LINGUA)/html-single/hgbook.html \
	    stylesheets/$(LINGUA)/html-single.xsl build/$(LINGUA)/source/hgbook.xml
endif

ifndef LINGUA
pdf:
	for l in $(LANGUAGES); do \
	    $(MAKE) $@ LINGUA=$$l; \
	done
else
pdf: build/$(LINGUA)/pdf/hgbook.pdf

build/$(LINGUA)/pdf/hgbook.pdf: build/$(LINGUA)/source/hgbook.xml stylesheets/fo.xsl stylesheets/$(LINGUA)/fo.xsl
	mkdir -p build/$(LINGUA)/pdf
	java -classpath tools/fop/lib/saxon65.jar:tools/fop/lib/saxon65-dbxsl.jar:tools/fop/lib/xml-commons-resolver-1.2.jar:tools/fop/conf \
	    com.icl.saxon.StyleSheet \
	    -x org.apache.xml.resolver.tools.ResolvingXMLReader \
	    -y org.apache.xml.resolver.tools.ResolvingXMLReader \
	    -r org.apache.xml.resolver.tools.CatalogResolver \
	    -o build/$(LINGUA)/source/hgbook.fo \
	    build/$(LINGUA)/source/hgbook.xml \
	    stylesheets/$(LINGUA)/fo.xsl \
	    fop1.extensions=1

	(cd build/$(LINGUA)/source && ../../../tools/fop/fop.sh hgbook.fo ../pdf/hgbook.pdf)
endif

en/images/%.png: en/images/%.svg en/fixsvg
	en/fixsvg $<
	inkscape -D -d 120 -e $@ $<-tmp.svg

en/images/%.svg: en/images/%.dot
	dot -Tsvg -o $@ $<
