#! /usr/bin/env zsh

_SRCDIR="$HOME/local"
_LOG="$_SRCDIR/update.log"
_UPDATE_ORDER="$_SRCDIR/.update-order"

_INDEX=0
_SCM=''
_UPDATE=''
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
    [ -d .git ] && update_git $_DIR
    [ -d .hg ] && update_mercurial $_DIR
    [ -d .svn ] && update_subversion $_DIR
    [ -d CVS ] && update_cvs $_DIR
    [ ! $_SCM ] && out_buffer "--- $_DIR [NO_SCM]" && continue
    [ ! $_UPDATE ] && out_buffer "=== $_DIR [$_SCM]" && continue
    out_buffer "+++ $_DIR [$_SCM]"
    [ -r Makefile ] && make install | add_prefix $_DIR
    [ -r build/Makefile ] && ( cd build && make install | add_prefix $_DIR )
done
echo
echo
echo
for i in {1..$_INDEX}
do
    echo ${_BUFFER[$i]}
done
