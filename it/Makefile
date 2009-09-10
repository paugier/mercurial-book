include Makefile.vars

# Makefile.vars includes the following system-dependent variables:
#
# dtd-url = the location of the DocBook 4.5 DTD on your filesystem
# system-xsl-dir = the location of DocBook XSLT on your filesystem
# dynamic-link-command = the command to link the DocBook XSLT to our styles 
# python = the location of Python 3.x on your filesystem

xml-src-files := \
	00book.xml \
	$(wildcard ch*.xml) \
	$(wildcard app*.xml) \
	bibliography.xml

xsltproc-opts := --nonet --xinclude
xmllint-opts := --noout --nonet --valid --path '$(dtd-url)'

root-web := html
support-web := $(root-web)/support
obj-web := $(root-web)/read
figs-web-folder := $(obj-web)/figs
script-web := $(obj-web)/javascript
web-global := ../web
web-local := web

html: $(obj-web)/index.html $(web-local)/index-read.html.in figs

$(obj-web)/index.html: ../stylesheets/system-xsl .validated-00book.xml
	xsltproc $(xsltproc-opts) -o $(obj-web)/x ../stylesheets/it/web.xsl 00book.xml
	mkdir -p $(support-web)
	cp -f $(web-global)/icons/*.png $(support-web)
	cp $(web-global)/styles.css $(support-web)
	sed -i -e "s|figs/||g" $(support-web)/styles.css
	mkdir -p $(figs-web-folder)
	mkdir -p $(script-web)
	cp -f $(web-local)/*.js $(script-web)

../stylesheets/system-xsl: $(system-xsl-dir)
	$(dynamic-link-command)

$(web-local)/index-read.html.in: $(web-local)/genindex.py $(xml-src-files)
	cp $(web-local)/index-template.html $(obj-web)/index.html
	sed -i -e "s|{% block bodycontent %}{% endblock %}|$(shell cat $(web-local)/index-read.html.in)|g" $(obj-web)/index.html
	sed -i -e "s|/support/|../support/|g" $(obj-web)/*.html
	cp $(web-local)/index-template.html $(root-web)/index.html
	sed -i "s|{% block bodycontent %}{% endblock %}|$(shell cat $(web-local)/index-home.html.in)|g" $(root-web)/index.html
	sed -i -e "s|/support/|support/|g" $(root-web)/index.html

$(web-local)/genindex.py: $(xml-src-files)
	cd $(web-local) && $(python) genindex.py

valid: .validated-00book.xml

.validated-00book.xml: $(xml-src-files)
	xmllint $(xmllint-opts) $<
	touch $@

clean:
	rm -f $(web-local)/index-read.html.in
	rm -f .validated-00book.xml
	rm -rf $(root-web)

image-folder := figs
# graphs, figures, screenshots
image-files := $(wildcard $(image-folder)/*.dot $(image-folder)/*.svg $(image-folder)/*.png)
# graphs
image-dot := $(filter %.dot, $(image-files))
# figures
image-svg := $(filter %.svg, $(image-files))
# screenshots
image-png := $(filter %.png, $(image-files))

figs-web := \
	$(image-dot:$(image-folder)/%.dot=$(figs-web-folder)/%.png) \
	$(image-svg:$(image-folder)/%.svg=$(figs-web-folder)/%.png) \
	$(image-png:$(image-folder)/%.png=$(figs-web-folder)/%.png)

figs: $(figs-web)

$(figs-web-folder)/%.png: $(image-folder)/%.svg
	inkscape -D -d 120 -e $@ $<

$(figs-web-folder)/%.png: $(figs-web-folder)/%.svg
	inkscape -D -e $@ $<
	rm $<

$(figs-web-folder)/%.png: $(image-folder)/%.png
	cp $< $@

$(figs-web-folder)/%.svg: $(image-folder)/%.dot
	dot -Tsvg -o $@ $<
