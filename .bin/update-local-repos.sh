#! /usr/bin/env zsh
#
# Copyright (C) 2012 nilsonholger@hyve.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

_SRCDIR="$HOME/local"
_LOG="$_SRCDIR/update.log"
_UPDATE_ORDER="$_SRCDIR/.update-order"

_INDEX=0
_SCM=''
_UPDATE=''
_BUILD_FAILED=''
_TEST="$_SRCDIR/.test-output"

function out_buffer {
((_INDEX++))
_BUFFER[$_INDEX]="$1"
echo $1 >> $_LOG
}

function add_prefix {
while read line
do
    echo $1: $line | tee -a $_LOG
done
}

function update_git {
_SCM='GIT'
echo "GIT STATUS" | add_prefix $1
git pull 2>&1 | tee $_TEST | add_prefix $1
grep -q -E "(Already up-to-date|Current branch .* is up to date)" $_TEST && _UPDATE='' || _UPDATE=true
}

function update_mercurial {
_SCM='MERCURIAL'
echo "MERCURIAL STATUS" | add_prefix $1
hg pull | tee $_TEST | add_prefix $1
grep -q "no changes found" $_TEST && _UPDATE='' || _UPDATE=true
}

function update_subversion {
_SCM='SUBVERSION'
echo "SUBVERSION STATUS" | add_prefix $1
svn update | tee $_TEST | add_prefix $1
grep -q "At revision" $_TEST && _UPDATE='' || _UPDATE=true
}

function update_cvs {
_SCM='CVS'
echo "CVS STATUS" | add_prefix $1
cvs update 2>/dev/null | tee $_TEST | add_prefix $1
grep -q -E "^P " $_TEST && _UPDATE=true || _UPDATE=''
}



echo "`date`" > $_LOG
for _DIR in `cat $_UPDATE_ORDER`
do
    cd $_SRCDIR
    [ -d $_DIR ] || continue
    cd $_DIR
    _SCM=''
    _BUILD_FAILED=''
    [ -d .git ] && update_git $_DIR
    [ -d .hg ] && update_mercurial $_DIR
    [ -d .svn ] && update_subversion $_DIR
    [ -d CVS ] && update_cvs $_DIR
    [ ! $_SCM ] && out_buffer "--- $_DIR [NO_SCM]" && continue
    [ ! $_UPDATE ] && out_buffer "=== $_DIR [$_SCM]" && continue
    out_buffer "+++ $_DIR [$_SCM]"
    [ -r Makefile ] && (make && make install || _BUILD_FAILED=true) | add_prefix $_DIR
    [ -r build/Makefile ] && (cd build && (make && make install || _BUILD_FAILED=true) | add_prefix $_DIR )
    [ $_BUILD_FAILED ] && out_buffer "!!! $_DIR [$_SCM] BUILD FAILED"
done
echo
echo
echo
for i in {1..$_INDEX}
do
    echo ${_BUFFER[$i]}
done
