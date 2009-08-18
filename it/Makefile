include Makefile.vars

# Makefile.vars include the following system-dependent variables:
#
# dtd-url = the location of the DocBook 4.5 DTD on your filesystem
# system-xsl-dir = the location of DocBook XSLT on your filesystem
# python = the location of Python 3.x on your filesystem

xml-src-files := \
	00book.xml \
	$(wildcard ch*.xml) \
	$(wildcard app*.xml) \
	bibliography.xml

xsltproc-opts := --nonet --xinclude
xmllint-opts := --noout --nonet --valid --path '$(dtd-url)'
    
obj-web := html
figs-web := ${obj-web}/figs
script-web := $(obj-web)/javascript
web-global := ../web
web-local := web

html: ${obj-web}/index.html ${web-local}/index-read.html.in

#$(obj-web)/index.html: ../stylesheets/system-xsl .validated-00book.xml #../web/index-read.html.in
$(obj-web)/index.html: .validated-00book.xml
	xsltproc $(xsltproc-opts) -o $(obj-web)/x ../stylesheets/it/web.xsl 00book.xml
#	xsltproc $(xsltproc-opts) -o $(obj-web)/x ../stylesheets/chunk-stylesheet.xsl 00book.xml
	cp ${web-global}/styles.css ${obj-web}
	mkdir -p ${figs-web}
	cp -f ${web-global}/icons/*.png $(figs-web)
	cp -f examples/figs/*.png $(figs-web)
	mkdir -p $(script-web)
	cp -f $(web-local)/*.js $(script-web)
	sed -i -e "s|/support/||g" ${obj-web}/*.html
#	python ../web/texpand.py ../web/index-read.html.in html/read/index.html
#	for i in $(obj-web-read)/*.html; do \
#	  gzip -9 -c $$i > $$i.gz; \
#	done

#../stylesheets/system-xsl: $(system-xsl-dir)
#	ln -s $< $@

$(web-local)/index-read.html.in: $(web-local)/genindex.py $(xml-src-files)
	cp $(web-local)/index-template.html $(obj-web)/index.html
	sed -i -e "s|{% block bodycontent %}{% endblock %}|$(shell cat $(web-local)/index-read.html.in)|g" ${obj-web}/index.html

$(web-local)/genindex.py: $(xml-src-files)
	cd $(web-local) && $(python) genindex.py

valid: .validated-00book.xml

.validated-00book.xml: $(xml-src-files) #examples/.run
	xmllint $(xmllint-opts) $<
	touch $@

clean:
	rm -f $(web-local)/index-read.html.in
	rm -rf $(obj-web)

image-folder := figs
# graphs, figures, screenshots
image-files := $(wildcard $(image-folder)/*.dot $(image-folder)/*.svg $(image-folder)/*.png)
# graphs
image-dot := $(filter %.dot, $(image-files))
# figures
image-svg := $(filter %.svg, $(image-files))
# screenshots
image-png := $(filter %.png, $(image-files))

figs-folder := examples/figs
figs-web := \
	$(image-dot:$(image-folder)/%.dot=$(figs-folder)/%.png) \
	$(image-svg:$(image-folder)/%.svg=$(figs-folder)/%.png) \
	$(image-png:$(image-folder)/%.png=$(figs-folder)/%.png)

figs: $(figs-web)

#$(figs-folder)/%.png: $(image-folder)/%.png $(image-folder)/%.svg
$(figs-folder)/%.png: $(image-folder)/%.svg
	inkscape -D -d 120 -e $@ $<

$(figs-folder)/%.png: $(figs-folder)/%.svg
	inkscape -D -d 120 -e $@ $<
	rm $<

$(figs-folder)/%.png: $(image-folder)/%.png
	cp $< $@

$(figs-folder)/%.svg: $(image-folder)/%.dot
	dot -Tsvg -o $@ $<
