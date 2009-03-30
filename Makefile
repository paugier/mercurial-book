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
	en/figs/feature-branches.png \
	en/figs/filelog.png \
	en/figs/metadata.png \
	en/figs/mq-stack.png \
	en/figs/revlog.png \
	en/figs/snapshot.png \
	en/figs/tour-history.png \
	en/figs/tour-merge-conflict.png \
	en/figs/tour-merge-merge.png \
	en/figs/tour-merge-pull.png \
	en/figs/tour-merge-sep-repos.png \
	en/figs/undo-manual-merge.png \
	en/figs/undo-manual.png \
	en/figs/undo-non-tip.png \
	en/figs/undo-simple.png \
	en/figs/wdir-after-commit.png \
	en/figs/wdir-branch.png \
	en/figs/wdir-merge.png \
	en/figs/wdir.png \
	en/figs/wdir-pre-branch.png

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
	@rm -fr build po/*.mo hello en/hello en/html en/.validated-00book.xml en/examples/.run en/examples/results \
          stylesheets/system-xsl en/figs/*-tmp.svg \
          en/figs/feature-branches.png \
          en/figs/filelog.png \
          en/figs/feature-branches.png \
          en/figs/filelog.png \
          en/figs/metadata.png \
          en/figs/mq-stack.png \
          en/figs/revlog.png \
          en/figs/snapshot.png \
          en/figs/tour-history.png \
          en/figs/tour-merge-conflict.png \
          en/figs/tour-merge-merge.png \
          en/figs/tour-merge-pull.png \
          en/figs/tour-merge-sep-repos.png \
          en/figs/undo-manual-merge.png \
          en/figs/undo-manual.png \
          en/figs/undo-non-tip.png \
          en/figs/undo-simple.png \
          en/figs/wdir-after-commit.png \
          en/figs/wdir-branch.png \
          en/figs/wdir-merge.png \
          en/figs/wdir-pre-branch.png \
          en/figs/wdir.png

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
$(LINGUA)/examples/.run:
	(cd $(LINGUA)/examples; ./run-example -v -a)

build/$(LINGUA)/source/hgbook.xml: $(wildcard $(LINGUA)/*.xml) $(images) $(LINGUA)/examples/.run $(images)
	mkdir -p build/$(LINGUA)/source/figs
	cp $(LINGUA)/figs/*.png build/$(LINGUA)/source/figs
	(cd $(LINGUA); xmllint --nonet --noent --xinclude --postvalid --output ../$@.tmp 00book.xml)
	cat $@.tmp | sed 's/\$$rev_id\$$/${rev_id}/' > $@
else
en/examples/.run:
	(cd en/examples; ./run-example -v -a)

build/en/source/hgbook.xml:
	${MAKE} LINGUA=en $@

build/$(LINGUA)/source/hgbook.xml: build/en/source/hgbook.xml po/$(LINGUA).po $(images)
	mkdir -p build/$(LINGUA)/source/figs
	$(TRANSLATE) -m build/en/source/hgbook.xml -p po/$(LINGUA).po -l $@.tmp
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
	mkdir -p build/$(LINGUA)/html/figs
	cp en/figs/*.png build/$(LINGUA)/html/figs
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
	mkdir -p build/$(LINGUA)/html-single/figs
	cp en/figs/*.png build/$(LINGUA)/html-single/figs
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

en/figs/%.png: en/figs/%.svg en/fixsvg
	en/fixsvg $<
	inkscape -D -d 120 -e $@ $<-tmp.svg

en/figs/%.svg: en/figs/%.dot
	dot -Tsvg -o $@ $<
