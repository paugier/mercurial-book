#!/usr/bin/env python

import glob
import re

if __name__ == "__main__":
    for filename in glob.glob('ch*/*.lst'):

        with open(filename, 'r') as f:
            output = []
            for line in f.readlines():
                output.append('  ' + line)
        m = re.search('(.*)/(.*.lst)', filename)
        output_filename = 'results/' + m.group(1) + '-' + m.group(2) + '.lxo'
        with open(output_filename, 'w') as f:
            f.write('.. code::\n\n')
            f.write(''.join(output))
