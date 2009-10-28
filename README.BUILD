HOW-TO:  Compiling the Mercurial Book
======================================

This Mercurial Book is written in DocBook 4.5.

The goal of this document is to give simple instructions to anyone who
wants to compile this book into a useful format, like HTML or PDF.  It
should state *exactly* which tools to use, and how to invoke them, in
simplest terms.

Table of Contents:

  I. PRIMER
 II. COMPILING THE DOCS
III. HACKING ON THE DOCS

I. PRIMER

  DocBook has a tortured, confusing history. Before you do anything,
  take a look at:

      http://wiki.docbook.org/topic/DocBookTutorials

II. COMPILING THE DOCS

1. Install XML DTD and XSL stylesheets for DocBook

      % sudo apt-get install docbook-xml docbook-xsl

2. Install libxml2-utils

      % sudo apt-get install libxml2-utils

3. Install graph drawing and patches tools

      % sudo apt-get install graphviz inkscape patchutils

4. Install pdf support

      % sudo apt-get install openjdk-6-jdk docbook-xsl-saxon libsaxon-java fop

  The Makefile will actually invoke $FOP_HOME/fop.sh, you should do
  some trick, let fop's CLASSPATH include saxon.jar and docbook-xsl-saxon.jar .

5. Configure XML Catalogs
  For non pdf output, we use xsltproc for XSLT process, xsltproc use system
  catalog files automatically, usually /etc/xml/catalog. Users do not need to
  care about it.

  For pdf output, we need use the xsl extensions (docbook-xsl-saxon), so we must
  create file $JAVA_LIB/CatalogManager.properties like this:

      catalogs=/etc/xml/catalog
      relative-catalogs=true
      static-catalog=yes
      catalog-class-name=org.apache.xml.resolver.Resolver
      verbosity=1

6. Create Makefile.vars
  Please create your Makefile.vars from Makefile.vars.tmpl .

7. Make
  Run 'make' for more details, for example:

  * make all document(pdf, epub, html and html-single for all languages)
      % make all

  * make english document(pdf, epub, html and html-single for all languages)
      % make LINGUA=en all

  * make Chinese document(pdf, epub, html and html-single for all languages)
      % make LINGUA=zh all

  * make Chinese pdf document
      % make LINGUA=zh pdf

III. HACKING ON THE DOCS

In addition to everything in section II:

1. Get a nice editing environment for XML

  This isn't strictly required, but it's nice when your editor
  colorizes things, understands the DTD, tells you what tags you can
  insert, etc.

  If you use emacs, we recommend the nxml-mode. Most free
  operating systems package it, or its home page is here:

      http://www.emacswiki.org/emacs/NxmlMode

  If you use vim, you might check out xmledit, at:

      http://www.vim.org/scripts/script.php?script_id=301

2. Get a validating parser

  Actually, if you have what you need to compile the documentation,
  then you almost certainly have an XML validator installed already -
  it is called xmllint, and comes as part of libxml2.

  The makefile is preconfigured with a suitable invocation of it,
  so simply run:

      $ make validate

3. Read about DocBook

  You'll want to get real intimate with a DocBook reference, such as
  can be found at:  http://www.docbook.org/tdg/en/html/
