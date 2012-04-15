#! /usr/bin/env zsh

_SRCDIR="$HOME/local"
_LOG="$_SRCDIR/update.log"
_UPDATE_ORDER="$_SRCDIR/.update-order"

_INDEX=0
_SCM=''
_UPDATE=''

function add_buffer {
((_INDEX++))
_BUFFER[$_INDEX]="$1"
echo $1 >> $_LOG
}

function add_out {
while read line
do
    echo $1: $line | tee -a $_LOG
done
}

function update_git {
_SCM='       GIT'
_STATUS=`git pull 2>&1`
[ $_STATUS = "Already up-to-date." ] && _UPDATE='' || _UPDATE=true
}

function update_mercurial {
_SCM=' MERCURIAL'
_STATUS=`hg pull`
[ ${_STATUS/*no changes found}x = "x" ] && _UPDATE='' || _UPDATE=true
}

function update_subversion {
_SCM='SUBVERSION'
_STATUS=`svn update`
[ ${_STATUS/At revision *.}x = "x" ] && _UPDATE='' || _UPDATE=true
}

echo "`date`" > $_LOG
for _DIR in `cat $_UPDATE_ORDER`
do
    cd $_SRCDIR
    [ -d $_DIR ] || continue
    cd $_DIR
    _SCM=''
    echo -n " $_DIR"
    [ -d .git ] && update_git
    [ -d .hg ] && update_mercurial
    [ -d .svn ] && update_subversion
    [ ! $_SCM ] && add_buffer "[   SKIPPED]--- $_DIR" && continue
    [ ! $_UPDATE ] && add_buffer "[$_SCM]=== $_DIR" && continue
    add_buffer "[$_SCM]+++ $_DIR"
    [ -r Makefile ] && make install | add_out $_DIR
    echo >> $_LOG
done

echo
for i in {1..$_INDEX}
do
    echo ${_BUFFER[$i]}
done
