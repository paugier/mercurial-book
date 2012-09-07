This is a theme designed to use with the plasTeX page template
renderer to generate commentable documents.

To "install" it, symlink this folder from the plasTeX XHTML Themes
folder. Example:

faraday:/usr/lib/pymodules/python2.5/plasTeX/Renderers/XHTML/Themes#
ln -s (this folder) alqua

Usage example:

$ plastex --theme=alqua --split-level=0 mylatex.tex
