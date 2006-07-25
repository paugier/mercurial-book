#!/usr/bin/python

import os, re, sys

count = 0

for line in os.popen('hg export tip'):
    # remember the name of the file that this diff affects
    m = re.match(r'^--- [^/]/([^\t])', line)
    if m: 
	filename = m.group(1)
	continue
    # remember the line number
    m = re.match(r'^@@ -(\d+),')
    if m:
        linenum = m.group(1)
        continue
    linenum += 1
    # check for an added line with trailing whitespace
    m = re.match(r'^\+.*\s$', line)
    if m:
	print >> sys.stderr, ('%s:%d: trailing whitespace introduced' %
                              (filename, linenum))
        count += 1

if count:
    # save the commit message so we don't need to retype it
    os.system('hg tip --template "{desc}" > .hg/commit.save')
    print >> sys.stderr, 'commit message saved to .hg/commit.save'

sys.exit(count)
