#!/bin/sh

inkscape -E `cygpath -w -a $1` `cygpath -w -a $2`
