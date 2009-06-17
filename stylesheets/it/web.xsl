<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>
                
  <xsl:import href="../chunk-stylesheet.xsl"/>

  <xsl:param name="l10n.gentext.language" select="'it'"/>
  
  <!-- Overriding parameters for the Italian localisation -->
  
  <xsl:template name="user.header.navigation">
    <div class="navheader"><h2 class="booktitle"><a href="/">Mercurial: la guida definitiva</a> <span class="authors">di Bryan O'Sullivan</span></h2></div>
  </xsl:template>
  
  <xsl:template name="user.footer.content">
    <div class="hgfooter">
      <p><img src="/support/figs/rss.png"/> Volete rimanere aggiornati? Abbonatevi al feed delle modifiche per <a id="chapterfeed" class="feed" href="/feeds/comments/">questo capitolo</a> o per <a class="feed" href="/feeds/comments/">l'intero libro</a>.</p>
      <p>Copyright 2006, 2007, 2008, 2009 Bryan O'Sullivan.
      Icone realizzate da <a href="mailto:mattahan@gmail.com">Paul Davey</a> alias <a href="http://mattahan.deviantart.com/">Mattahan</a>.</p>
    </div>
  </xsl:template>
  
  <xsl:template name="user.footer.navigation">
    <!-- No Google Analytics script for the moment -->
  </xsl:template>
  
</xsl:stylesheet>
