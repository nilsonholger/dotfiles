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



# message system
message() {
	case $1 in
		'ABORT') echo -e "\e[1;31m>>> $2\e[0m"; exit;;
		'HELP')
		echo "usage: `basename $0` [options] <video_1> ...

options:
   -c|--count  <arg> output file \${COUNT} starts with <arg> (see *output name*)
   -h|--help         this help message
   -i|--ignore       ignore existing directory (overwrite files inside)
   -n|--name   <arg> output file name scheme (see *output name*)
   -v|--verbose      verbose output

output name (default 'frame_\${FRAME}_\${COUNT}.jpg'):
      a string that indicates the output file names, the following sequences
      are supported (please surround the string with \"\")
      \${FRAME}    the frame number
      \${COUNT}    the input file number
" && exit
			;;
		*) echo -e "\e[0;33m>>> $1\e[0m";;
	esac
}



# check dependencies
hash ffmpeg 2>/dev/null || message "ABORT" "NO FFMPEG FOUND!"
# todo: include usage of 'avconv'



# set options
_QUIET='&> /dev/null'
_IGNORE=''
_FILE_NAME_FORMAT='frame_${FRAME}_${COUNT}.jpg'
FRAME='%d'
COUNT=1
for i in $@
do
	case $i in
		'-c'|'--count')
			shift
			COUNT=$1
			message "USING START COUNT: $COUNT"
			shift
			;;
		'-h'|'--help') message "HELP";;
		'-i'|'--ignore') _IGNORE="TRUE"; shift;;
		'-n'|'--name')
			shift
			_FILE_NAME_FORMAT="$1"
			message "USING FILE NAME FORMAT: $_FILE_NAME_FORMAT"
			shift
			;;
		'-v'|'--verbose') _QUIET=''; shift;;
	esac
done



# check file arguments
[ $# -eq 0 ] && message "ABORT" "NO FILES GIVEN!"
for i in $@
do
	[ ! -f "$i" ] && message "ABORT" "FILE NOT FOUND: $i"
done



# create target directory
_DIR_NAME="`stat --printf='%y' $1`"
_DIR_NAME="${_DIR_NAME/\.*}"
_DIR_NAME="${_DIR_NAME/ /_}"
[ -d $_DIR_NAME -a -z "$_IGNORE" ] && message "ABORT" "DIRECTORY ALREADY EXISTS: $_DIR_NAME"
message "CREATING OUTPUT DIRECTORY: $_DIR_NAME"
eval mkdir "$_DIR_NAME" $_QUIET



# converting
for i in $@
do
	_FILE=`eval echo $_FILE_NAME_FORMAT`
	message "CONVERTING $i -> $_DIR_NAME/$_FILE}"
	eval ffmpeg -i $i -vcodec copy -vbsf mjpeg2jpeg $_DIR_NAME/$_FILE $_QUIET
	((COUNT++))
done
message "DONE"
