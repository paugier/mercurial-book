<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
                
  <xsl:import href="../chunk-stylesheet.xsl"/>

  <xsl:param name="l10n.gentext.language" select="'it'"/>
  
  <xsl:param name="html.stylesheet">styles.css</xsl:param>
  
  <xsl:template name="user.head.content">
    <!--
    <link rel="alternate" type="application/atom+xml" title="Comments"
      href="/feeds/comments/"/>
    -->
    <link rel="shortcut icon" type="image/png" href="figs/favicon.png"/>
    <script type="text/javascript" src="javascript/jquery-min.js"></script>
    <script type="text/javascript" src="javascript/hgbook.js"></script>
  </xsl:template>
  
  <!-- Overriding parameters for the Italian localisation -->
  
  <xsl:template name="user.header.navigation">
    <div class="navheader"><h2 class="booktitle"><a href="/">Mercurial: la guida definitiva</a> <span class="authors">di Bryan O'Sullivan</span></h2></div>
  </xsl:template>
  
  <xsl:template name="user.footer.content">
    <div class="hgfooter">
      <p><img src="figs/rss.png"/> Volete rimanere aggiornati? Abbonatevi al feed delle modifiche per il <a class="feed" href="http://bitbucket.org/gpiancastelli/hgbook-it/atom">libro italiano</a>.</p>
      <p>Copyright 2006, 2007, 2008, 2009 Bryan O'Sullivan.
      Icone realizzate da <a href="mailto:mattahan@gmail.com">Paul Davey</a> alias <a href="http://mattahan.deviantart.com/">Mattahan</a>.</p>
      <p>Copyright 2009 <a href="mailto:giulio.piancastelli@gmail.com">Giulio Piancastelli</a> per la traduzione italiana.</p>
    </div>
  </xsl:template>
  
  <xsl:template name="user.footer.navigation">
    <!-- No Google Analytics script for the moment -->
  </xsl:template>
  
</xsl:stylesheet>
