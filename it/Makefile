include Makefile.vars

xml-src-files := \
	00book.xml \
	$(wildcard ch*.xml)
	#$(wildcard app*.xml)
	
    
obj-web := html
figs-web := ${obj-web}/figs
web-global := ../web
web-local := web

html: ${obj-web}/index.html ${web-local}/index-read.html.in

#$(obj-web)/index.html: ../stylesheets/system-xsl .validated-00book.xml #../web/index-read.html.in
$(obj-web)/index.html: .validated-00book.xml
	xsltproc $(xsltproc-opts) -o $(obj-web)/x ../stylesheets/chunk-stylesheet.xsl 00book.xml
	cp ${web-global}/styles.css ${obj-web}
	mkdir -p ${figs-web}
	cp -f ${web-global}/icons/*.png $(figs-web)
    cp -f examples/figs/*.png $(figs-web)
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
	cd $(web-local) && ./genindex.py

valid: .validated-00book.xml

.validated-00book.xml: $(xml-src-files) #examples/.run
	xmllint $(xmllint-opts) $<
	touch $@

clean:
	rm -f $(web-local)/index-read.html.in
	rm -rf $(obj-web)
