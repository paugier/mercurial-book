include Makefile.vars

xml-src-files := \
	00book.xml \
	#app*.xml \
	ch*.xml
    
obj-web := html

html: ${obj-web}/index.html

#$(obj-web)/index.html: ../stylesheets/system-xsl .validated-00book.xml #../web/index-read.html.in
$(obj-web)/index.html: .validated-00book.xml
	xsltproc $(xsltproc-opts) -o $(obj-web)/x ../stylesheets/chunk-stylesheet.xsl 00book.xml
#	python ../web/texpand.py ../web/index-read.html.in html/read/index.html
#	for i in $(obj-web-read)/*.html; do \
#	  gzip -9 -c $$i > $$i.gz; \
#	done

#../stylesheets/system-xsl: $(system-xsl-dir)
#	ln -s $< $@

valid: .validated-00book.xml

.validated-00book.xml: $(xml-src-files) #examples/.run
	xmllint $(xmllint-opts) $<
	touch $@

