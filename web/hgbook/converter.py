from bs4 import BeautifulSoup
import md5
import sys
import os

def convert_chapter(filename):
    from comments.models import Element

    with open(filename, 'r') as f:
        soup = BeautifulSoup(f, 'html.parser')

        navheader = soup.new_tag("div")
        navheader["class"] = "navheader"
        navheader.string ="by Bryan O'Sullivan"
        h1title = soup.new_tag("h1")
        h1title["class"] = "booktitle"
        h1title.string = "Mercurial: the definite guide"
        body = soup.find("body")
        navheader.insert(0, h1title)
        body.insert(0, navheader)

        chapters = soup.find_all("div", class_="chapter")
        if not chapters:
            print "Failed to convert %s" % filename
            return unicode(soup)

        chapter = chapters[0]
        chapter_title = chapter['id'].split(':')[1]
        chapter_hash = md5.new(chapter['id'].encode('utf8')).hexdigest()
        chapter['id'] = chapter_hash

        elements = soup.select("div.chapter p, pre, h1, table.equation")
        for element in elements:
            hsh_source = element.text

            if hsh_source:
                hsh_source_encoded = hsh_source.encode('utf8')
                hsh = md5.new(hsh_source_encoded).hexdigest()
                element['id'] = '%s-%s' % (chapter_hash, hsh)
            
                # create the commentable element in the DB
                e = Element()
                e.id = '%s-%s' % (chapter_hash, hsh)
                e.chapter = chapter_hash
                e.title = chapter_title
                e.save()
            else:
                print 'Element not hashed: %s' % hsh_source

        return soup.prettify()

if __name__ == '__main__':
    args = sys.argv[1:]

    # django stuff
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "hgbook.settings")

    try:
        filename = args[0]
    except IndexError:
        raise IndexError("Usage: %s <path-to-html-file>" % __file__)

    res = convert_chapter(filename)
    print res.encode('utf8')      # pipe to a file if you wish
