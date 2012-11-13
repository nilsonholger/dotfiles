#! /usr/bin/env bash
#
# convert a motion jpg to individual jpgs
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



# abort with message
abort() {
	echo -e "\e[1;31m>>> $1\e[0m"
	exit
}



# normal message
message() {
	echo -e "\e[1;32m>>> $1\e[0m"
}



# check dependencies
hash ffmpeg 2>/dev/null || abort "NO FFMPEG FOUND!"
# todo: include usage of 'avconv'



# check input
[ -z "$1" -o -z "$2" ] && echo "usage: $0 [-v] <video_1> <video_2>

   -v|--verbose      verbose output
   -i|--ignore       ignore existing files (overwrite)
" && exit



# set options
QUIET='&> /dev/null'
IGNORE=true
for i in $@
do
	case $i in
		'-v'|'--verbose') QUIET=''; shift;;
		'-i'|'--ignore') IGNORE=false; shift;;
	esac
done



# check file existence
[ ! -f "$1" ] && abort "FILE NOT FOUND: $1"
[ ! -f "$2" ] && abort "FILE NOT FOUND: $2"



# create target directory
DIR_NAME="`stat --printf='%y' $1`"
DIR_NAME="${DIR_NAME/\.*}"
DIR_NAME="${DIR_NAME/ /_}"
(mkdir "$DIR_NAME" 2>/dev/null || $IGNORE) && abort "DIRECTORY ALREADY EXISTS: $DIR_NAME"



# converting
message "CONVERTING $1"
eval ffmpeg -i $1 -vcodec copy -vbsf mjpeg2jpeg $DIR_NAME/frame_%d_1.jpg $QUIET
message "CONVERTING $2"
eval ffmpeg -i $2 -vcodec copy -vbsf mjpeg2jpeg $DIR_NAME/frame_%d_2.jpg $QUIET
message "DONE"
