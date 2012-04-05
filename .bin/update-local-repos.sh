#! /usr/bin/zsh

_SRCDIR="$HOME/local"

_CVS=''
_HAS_UPDATES=''
_LOG="$_SRCDIR/update-local-repos.log"
_PWD_ORIG=$PWD

function update_git {
_CVS='GIT'
_STATUS=`git pull`
[ $_STATUS = "Already up-to-date." ] && _HAS_UPDATES='' || _HAS_UPDATES=true
}

function update_mercurial {
_CVS='MERCURIAL'
_STATUS=`hg pull`
[ ${_STATUS/*no changes found}x = "x" ] && _HAS_UPDATES='' || _HAS_UPDATES=true
}

function update_subversion {
_CVS='SUBVERSION'
_STATUS=`svn update`
[ ${_STATUS/At revision *.}x = "x" ] && _HAS_UPDATES='' || _HAS_UPDATES=true
}

echo "`date`" >> $_LOG
echo "UPDATING LOCAL REPOSITORIES IN $_SRCDIR" | tee -a $_LOG
for _DIR in $_SRCDIR/*
do
    [ -d $_DIR ] || continue
    cd $_DIR
    _DIR=`basename $_DIR`
    _CVS=''
    [ -d .git ] && update_git
    [ -d .hg ] && update_mercurial
    [ -d .svn ] && update_subversion
    [ ! $_CVS ] && (echo "---SKIPPED $_DIR [NO_CVS_DVS]" | tee -a $_LOG) && continue
    [ ! $_HAS_UPDATES ] && (echo "===CURRENT $_DIR [$_CVS]" | tee -a $_LOG) && continue
    make >> $_LOG
    make install >> $_LOG
    echo "+++UPDATED $_DIR [$_CVS]" | tee -a $_LOG
done

cd $_PWD_ORIG
