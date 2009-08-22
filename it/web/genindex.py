# This script works with Python 3.0 or above

import glob, os, re

chapter_re = re.compile(r'<(chapter|appendix|preface)\s+id="([^"]+)">')
filename_re = re.compile(r'<\?dbhtml filename="([^"]+)"\?>')
title_re = re.compile(r'<title>(.*)</title>')

chapters = (sorted(glob.glob('../ch*.xml')) +
            sorted(glob.glob('../app*.xml')))

fp = open('index-read.html.in', 'w', encoding='utf-8')

print('''
<div class="navheader"><h1 class="booktitle">Mercurial: la guida definitiva<div class="authors">di Bryan O\&#8217;Sullivan</div></h1></div>
<div class="book"><ul class="booktoc">''', file=fp)

ch = 0
app = 0
ab = 0
for c in chapters:
    filename = None
    title = None
    chapid = None
    chaptype = None
    for line in open(c, encoding='utf-8'):
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
            if title.find('&') >= 0:
                title = title.replace('&', '\&')
            ab += 1
            date = os.popen('hg log -l1 --template "{date|isodate}" ' + c).read().split(None, 1)[0]
            args = {
                'ab': "ab"[ab % 2],
                'date': date,
                'chapid': chapid,
                'num': num,
                'filename': filename,
                'title': title,
                }
            print('<li class="zebra_%(ab)s"><span class="chapinfo">%(date)s</span>%(num)s. <a href="%(filename)s">%(title)s</a></li>' % args, file=fp)
            break

print('</ul></div>', file=fp)

fp.close()
