#!/bin/bash

cp $EXAMPLE_DIR/data/check_whitespace.py .

hg init a
cd a
echo '[hooks]' > .hg/hgrc
echo "pretxncommit.whitespace = hg export tip | (! grep -qP '^\\+.*[ \\t]$')" >> .hg/hgrc

#$ name: simple

cat .hg/hgrc
echo 'a ' > a
hg commit -A -m 'test with trailing whitespace'
