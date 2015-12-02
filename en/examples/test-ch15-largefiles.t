  $ echo '[extensions]' >> $HGRCPATH
  $ echo 'largefiles =' >> $HGRCPATH

#$ name: init
  $ hg init foo
  $ cd foo
  $ dd if=/dev/urandom of=randomdata count=2000
  2000+0 records in
  2000+0 records out
  1024000 bytes (1.0 MB) copied, * s, * MB/s (glob)

#$ name: add-regular
  $ hg add randomdata
  $ hg commit -m 'added randomdata as regular file'

#$ name:
  $ hg --config extensions.strip= strip -r . --keep
  saved backup bundle to * (glob)

#$ name: add-largefile
  $ hg add --large randomdata
  $ hg commit -m 'added randomdata as largefile'
