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
sel = CSSSelector('p, pre, h1, table.equation')
body = CSSSelector('body')

try:
    filename = args[0]
except IndexError:
    raise IndexError("Usage: %s <path-to-html-file>" % __file__)

tree = etree.parse(filename, html.HTMLParser())
root = tree.getroot()

body(root)[0].set('id', doc_id)

for element in sel(root):
    hsh_source = element.text or element.get('alt') or etree.tostring(element)

    if hsh_source:
        hsh_source_encoded = hsh_source.encode('utf8')
        hsh = md5.new(hsh_source_encoded).hexdigest()
        element.set('id', '%s-%s' % (doc_id, hsh))
    
        # create the commentable element in the DB
        e = Element()
        e.id = '%s-%s' % (doc_id, hsh)
        e.chapter = doc_id
        e.title = hsh
        e.save()



print etree.tostring(root)      # pipe to a file if you wish

