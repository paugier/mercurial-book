  $ cat > svn << EOF
  > cat $TESTS_ROOT/svn-short.txt
  > EOF
  $ chmod +x svn

#$ name: short

  $ ./svn log -r9653
  ------------------------------------------------------------------------
  r9653 | sean.hefty | 2006-09-27 14:39:55 -0700 (Wed, 27 Sep 2006) | 5 lines
  
  On reporting a route error, also include the status for the error,
  rather than indicating a status of 0 when an error has occurred.
  
  Signed-off-by: Sean Hefty <sean.hefty@intel.com>
  
  ------------------------------------------------------------------------

#$ name:

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

  $ echo 'changeset = "{node|short}"' > svn.style

#$ name: id

  $ hg log -r0 --template '{node}'
  0312f545d1d7e5637a821db2b82dc5057595569b (no-eol)

#$ name: simplest

  $ cat svn.style
  changeset = "{node|short}"
  $ hg log -r1 --style svn.style
  c8ec776f4fca (no-eol)

#$ name:

  $ echo 'changeset =' > broken.style

#$ name: syntax.input

  $ cat broken.style
  changeset =

#$ name: syntax.error

  $ hg log -r1 --style broken.style
  abort: broken.style:1: missing value
  [255]

#$ name:

  $ cp $TESTS_ROOT/svn.style .
  $ cp $TESTS_ROOT/svn.template .

#$ name: template

  $ cat svn.template
  r{rev} | {author|user} | {date|isodate} ({date|rfc822date})
  
  {desc|strip|fill76}
  
  ------------------------------------------------------------------------

#$ name: style

  $ cat svn.style
  header = '------------------------------------------------------------------------\n\n'
  changeset = svn.template

#$ name: result

  $ hg log -r1 --style svn.style
  ------------------------------------------------------------------------
  
  r1 | test | 1970-01-01 00:00 +0000 (Thu, 01 Jan 1970 00:00:00 +0000)
  
  added line to end of <<hello>> file.
  
  in addition, added a file with the helpful name (at least i hope that some
  might consider it so) of goodbye.
  
  ------------------------------------------------------------------------

