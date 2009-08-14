#!/bin/sh

inkscape -D -e `cygpath -w -a $1` `cygpath -w -a $2`
