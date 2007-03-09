#!/usr/bin/env python

import os
import sys
import re

unicode_re = re.compile(r'&#x00([0-7][0-9a-f]);', re.I)
fancyvrb_re = re.compile(r'id="fancyvrb\d+"', re.I)

tmpsuffix = '.tmp.' + str(os.getpid())

def fix_ascii(m):
    return chr(int(m.group(1), 16))

for name in sys.argv[1:]:
    tmpname = name + tmpsuffix
    ofp = file(tmpname, 'w')
    for line in file(name):
        line = unicode_re.sub(fix_ascii, line)
        line = fancyvrb_re.sub('id="fancyvrb"', line)
        ofp.write(line)
    ofp.close()
    os.rename(tmpname, name)
