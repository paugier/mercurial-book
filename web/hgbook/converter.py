from lxml import etree
from lxml import html
from lxml.cssselect import CSSSelector
import md5
import sys


args = sys.argv[1:]

# django stuff
from django.core.management import setup_environ
import settings # Assumed to be in the same directory.
setup_environ(settings)       # ugly django collateral effects :(
from comments.models import Element

doc_id = 'MMSC'
sel = CSSSelector('div.chapter p, pre, h1, table.equation')
chapter_sel = CSSSelector('div.chapter')

try:
    filename = args[0]
except IndexError:
    raise IndexError("Usage: %s <path-to-html-file>" % __file__)

tree = etree.parse(filename, html.HTMLParser(remove_blank_text=True))
root = tree.getroot()

chapter = chapter_sel(root)[0]
chapter_title = chapter.get('id').split(':')[1]
chapter_hash = md5.new(chapter.get('id').encode('utf8')).hexdigest()

chapter.set('id', chapter_hash)

for element in sel(root):
    hsh_source = element.text or element.get('alt') or etree.tostring(element)

    if hsh_source:
        hsh_source_encoded = hsh_source.encode('utf8')
        hsh = md5.new(hsh_source_encoded).hexdigest()
        element.set('id', '%s-%s' % (chapter_hash, hsh))
    
        # create the commentable element in the DB
        e = Element()
        e.id = '%s-%s' % (chapter_hash, hsh)
        e.chapter = chapter_hash
        e.title = chapter_title
        e.save()



print etree.tostring(root)      # pipe to a file if you wish

