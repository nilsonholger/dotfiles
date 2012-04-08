#! /usr/bin/zsh

_SRCDIR="$HOME/local"

_SCM=''
_LOG="$_SRCDIR/update.log"
_UPDATE=''

function update_git {
_SCM='       GIT'
_STATUS=`git pull`
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

echo "`date`" >> $_LOG
echo "[ DIRECTORY]>>> $_SRCDIR" | tee -a $_LOG
for _DIR in $_SRCDIR/*
do
    [ -d $_DIR ] || continue
    cd $_DIR
    _DIR=`basename $_DIR`
    _SCM=''
    [ -d .git ] && update_git
    [ -d .hg ] && update_mercurial
    [ -d .svn ] && update_subversion
    [ ! $_SCM ] && (echo "[  SKIPPING]--- $_DIR" | tee -a $_LOG) && continue
    [ ! $_UPDATE ] && (echo "[$_SCM]=== $_DIR" | tee -a $_LOG) && continue
    echo >> $_LOG
    echo "[$_SCM]+++ $_DIR" | tee -a $_LOG
    make >> $_LOG
    make install >> $_LOG
    echo >> $_LOG
done
