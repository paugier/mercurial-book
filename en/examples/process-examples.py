#!/usr/bin/env python

import glob
import re
import os

def writeblock(testname, blockname, blocklines):
    filename = 'results/{testname}.{blockname}.lxo'.format(
                testname=testname, blockname=blockname)
    with open(filename, 'w') as f:
        f.write(''.join(blocklines))

if __name__ == "__main__":
    for filename in glob.glob('results/test-*.t.out'):
        m = re.search('test-(.*).t.out', filename)
        if not m:
            continue
        testname = m.group(1)

        with open(filename, 'r') as f:
            blockname = None
            blocklines = []
            for line in f.readlines():
                m = re.match('#\$ name: ([^\s]*)', line)
                m2 = re.match('#\$ name:$', line)
                m_comment = re.match('# ', line)
                if m:
                    if blockname:
                        writeblock(testname, blockname, blocklines)
                    blockname = m.group(1)
                    blocklines = []
                    blocklines.append('.. code::\n')
                    blocklines.append('\n')
                elif m2:
                    if blockname:
                        writeblock(testname, blockname, blocklines)
                    #Unnamed block: don't process it further
                    blockname = None
                elif m_comment:
                    #Indent comments so they don't ruin the code blocks
                    blocklines.append('  %s' % line)
                else:
                    blocklines.append(line)
            if blockname:
                writeblock(testname, blockname, blocklines)
