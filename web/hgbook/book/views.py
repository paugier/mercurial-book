from django.shortcuts import render
import glob, os, re
from django.conf import settings
from django.http import HttpResponse, Http404

chapter_re = re.compile(r'<(chapter|appendix|preface)\s+id="([^"]+)">')
filename_re = re.compile(r'<\?dbhtml filename="([^"]+)"\?>')
title_re = re.compile(r'<title>(.*)</title>')

def index(request):
    chapters = (sorted(glob.glob('../../en/ch*.xml')) +
                sorted(glob.glob('../../en/app*.xml')))

    ch = 0
    app = 0
    chaps = []
    for c in chapters:
        filename = None
        title = None
        chapid = None
        chaptype = None
        for line in open(c):
            m = chapter_re.search(line)
            if m:
                chaptype, chapid = m.groups()
            m = filename_re.search(line)
            if m:
                filename = m.group(1)
            m = title_re.search(line)
            if m:
                title = m.group(1)
            if filename and title and chapid:
                if chaptype == 'appendix':
                    num = chr(ord('A') + app)
                    app += 1
                else:
                    num = ch
                    ch += 1
                date = os.popen('hg log -l1 --template "{date|isodate}" ' + c).read().split(None, 1)[0]
                args = {
                    'date': date,
                    'feed': '/feeds/comments/%s' % chapid,
                    'index': num,
                    'url': filename,
                    'title': title,
                }
                chaps.append(args)
                break
    return render(request, 'home.html', {'chapters': chaps})

def chapter(request, path, **kwargs):
    import converter
    try:
        res = converter.convert_chapter(os.path.join(kwargs['document_root'], path))
        return HttpResponse(res)
    except IOError:
        raise Http404("Page does not exist")
