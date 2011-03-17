#!/usr/bin/env python
#
# Add unique ID attributes to para tags.  This script should only be
# run by one person, since otherwise it introduces the possibility of
# chaotic conflicts among tags.

import glob, os, re, sys

tagged = re.compile('<para[^>]* id="x_([0-9a-f]+)"[^>]*>', re.M)
untagged = re.compile('<para>')

names = glob.glob('ch*.xml') + glob.glob('app*.xml')

# First pass: find the highest-numbered paragraph ID.

biggest_id = 0
seen = set()
errs = 0

for name in names:
    for m in tagged.finditer(open(name).read()):
        i = int(m.group(1),16)
        if i in seen:
            print >> sys.stderr, '%s: duplication of ID %s' % (name, i)
            errs += 1
        seen.add(i)
        if i > biggest_id:
            biggest_id = i

def retag(s):
    global biggest_id
    biggest_id += 1
    return '<para id="x_%x">' % biggest_id

# Second pass: add IDs to paragraphs that currently lack them.

for name in names:
    f = open(name).read()
    f1 = untagged.sub(retag, f)
    if f1 != f:
        tmpname = name + '.tmp'
        fp = open(tmpname, 'w')
        fp.write(f1)
        fp.close()
        os.rename(tmpname, name)

sys.exit(errs)
