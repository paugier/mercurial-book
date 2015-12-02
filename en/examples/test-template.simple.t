  $ hg init myrepo
  $ cd myrepo
  $ echo hello > hello
  $ hg commit -Am'added hello'
  adding hello

  $ echo hello >> hello
  $ echo goodbye > goodbye
  $ echo '   added line to end of <<hello>> file.' > ../msg
  $ echo '' >> ../msg
  $ echo 'in addition, added a file with the helpful name (at least i hope that some might consider it so) of goodbye.' >> ../msg

  $ hg commit -Al../msg
  adding goodbye

  $ hg tag mytag
  $ hg tag v0.1

#$ name: normal

  $ hg log -r1
  changeset:   1:c8ec776f4fca
  tag:         mytag
  user:        test
  date:        Thu Jan 01 00:00:00 1970 +0000
  summary:     added line to end of <<hello>> file.
  

#$ name: compact

  $ hg log --style compact
  3[tip]   91900a8c91ee   1970-01-01 00:00 +0000   test
    Added tag v0.1 for changeset e8277000e239
  
  2[v0.1]   e8277000e239   1970-01-01 00:00 +0000   test
    Added tag mytag for changeset c8ec776f4fca
  
  1[mytag]   c8ec776f4fca   1970-01-01 00:00 +0000   test
    added line to end of <<hello>> file.
  
  0   0312f545d1d7   1970-01-01 00:00 +0000   test
    added hello
  

#$ name: changelog

  $ hg log --style changelog
  1970-01-01  test  <test>
  
  	* .hgtags:
  	Added tag v0.1 for changeset e8277000e239
  	[91900a8c91ee] [tip]
  
  	* .hgtags:
  	Added tag mytag for changeset c8ec776f4fca
  	[e8277000e239] [v0.1]
  
  	* goodbye, hello:
  	added line to end of <<hello>> file.
  
  	in addition, added a file with the helpful name (at least i hope
  	that some might consider it so) of goodbye.
  	[c8ec776f4fca] [mytag]
  
  	* hello:
  	added hello
  	[0312f545d1d7]
  

#$ name: simplest

  $ hg log -r1 --template 'i saw a changeset\n'
  i saw a changeset

#$ name: simplesub

  $ hg log --template 'i saw a changeset: {desc}\n'
  i saw a changeset: Added tag v0.1 for changeset e8277000e239
  i saw a changeset: Added tag mytag for changeset c8ec776f4fca
  i saw a changeset: added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope that some might consider it so) of goodbye.
  i saw a changeset: added hello

#$ name: keywords

  $ hg log -r1 --template 'author: {author}\n'
  author: test
  $ hg log -r1 --template 'desc:\n{desc}\n'
  desc:
  added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope that some might consider it so) of goodbye.
  $ hg log -r1 --template 'files: {files}\n'
  files: goodbye hello
  $ hg log -r1 --template 'file_adds: {file_adds}\n'
  file_adds: goodbye
  $ hg log -r1 --template 'file_dels: {file_dels}\n'
  file_dels: 
  $ hg log -r1 --template 'node: {node}\n'
  node: c8ec776f4fca16a08e85d5a13dcd372fb7c66f0e
  $ hg log -r1 --template 'parents: {parents}\n'
  parents: 
  $ hg log -r1 --template 'rev: {rev}\n'
  rev: 1
  $ hg log -r1 --template 'tags: {tags}\n'
  tags: mytag

#$ name: datekeyword

  $ hg log -r1 --template 'date: {date}\n'
  date: 0.00
  $ hg log -r1 --template 'date: {date|isodate}\n'
  date: 1970-01-01 00:00 +0000

#$ name: manyfilters

  $ hg log -r1 --template '{author}\n'
  test
  $ hg log -r1 --template '{author|domain}\n'
  
  $ hg log -r1 --template '{author|email}\n'
  test
  $ hg log -r1 --template '{author|obfuscate}\n' | cut -c-76
  &#116;&#101;&#115;&#116;
  $ hg log -r1 --template '{author|person}\n'
  test
  $ hg log -r1 --template '{author|user}\n'
  test

  $ hg log -r1 --template 'looks almost right, but actually garbage: {date}\n'
  looks almost right, but actually garbage: 0.00
  $ hg log -r1 --template '{date|age}\n'
  1970-01-01
  $ hg log -r1 --template '{date|date}\n'
  Thu Jan 01 00:00:00 1970 +0000
  $ hg log -r1 --template '{date|hgdate}\n'
  0 0
  $ hg log -r1 --template '{date|isodate}\n'
  1970-01-01 00:00 +0000
  $ hg log -r1 --template '{date|rfc822date}\n'
  Thu, 01 Jan 1970 00:00:00 +0000
  $ hg log -r1 --template '{date|shortdate}\n'
  1970-01-01

  $ hg log -r1 --template '{desc}\n' | cut -c-76
  added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope that some m
  $ hg log -r1 --template '{desc|addbreaks}\n' | cut -c-76
  added line to end of <<hello>> file.<br/>
  <br/>
  in addition, added a file with the helpful name (at least i hope that some m
  $ hg log -r1 --template '{desc|escape}\n' | cut -c-76
  added line to end of &lt;&lt;hello&gt;&gt; file.
  
  in addition, added a file with the helpful name (at least i hope that some m
  $ hg log -r1 --template '{desc|fill68}\n'
  added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope
  that some might consider it so) of goodbye.
  $ hg log -r1 --template '{desc|fill76}\n'
  added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope that some
  might consider it so) of goodbye.
  $ hg log -r1 --template '{desc|firstline}\n'
  added line to end of <<hello>> file.
  $ hg log -r1 --template '{desc|strip}\n' | cut -c-76
  added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope that some m
  $ hg log -r1 --template '{desc|tabindent}\n' | expand | cut -c-76
  added line to end of <<hello>> file.
  
          in addition, added a file with the helpful name (at least i hope tha

  $ hg log -r1 --template '{node}\n'
  c8ec776f4fca16a08e85d5a13dcd372fb7c66f0e
  $ hg log -r1 --template '{node|short}\n'
  c8ec776f4fca

#$ name: combine

  $ hg log -r1 --template 'description:\n\t{desc|strip|fill68|tabindent}\n'
  description:
  	added line to end of <<hello>> file.
  
  	in addition, added a file with the helpful name (at least i hope
  	that some might consider it so) of goodbye.

#$ name: rev

  $ echo 'changeset = "rev: {rev}"\n' > rev
  $ hg log -l1 --style ./rev
  rev: 3 (no-eol)
