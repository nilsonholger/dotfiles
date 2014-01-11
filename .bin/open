#! /usr/bin/env zsh
#
# to be used with mutts mail attachments, sends them back to portable by using
# reverse ssh tunnel

[ -z $1 ] && echo "usage: open FILE" && exit
FILE=`basename $1`
FILE=${FILE/mutt-}
echo "$FILE -> ssh_client:Downloads/"
scp -P 18981 $1 localhost:Downloads/$FILE || scp -P 19891 $1 localhost:$FILE
