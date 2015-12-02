  $ hg init
  $ echo a > test.c
  $ hg ci -Am'First commit'
  adding test.c

#$ name: go

  $ cat > multiline << EOF
  > changeset = "Changed in {node|short}:\n{files}"
  > file = "  {file}\n"
  > EOF
  $ hg log --style multiline
  Changed in *: (glob)
    test.c
