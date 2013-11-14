#! /usr/bin/env zsh
#
# aperture-export: exports images from aperture and ONLY images (no metadata)
# into folders named after project name (folder/project hierarchy not
# considered)
#
# WARNING!!!: ...here be dragons...
# might not work for you or DESTROY YOUR DATA, if unsure, change the 'mv'
# command to 'echo' or 'cp' in the innermost while loop to test its output, or
# work on a copy
#
# REQUIREMENTS:
# Aperture Library.aplibrary/ApertureData.xml <- contains needed info
# Aperture Library.aplibrary/Masters <- contains images
#
# USAGE:
# place script inside "Aperturae Library.aplibrary" folder and execute, modify
# beforehand as needed
#
# Copyright (C) 2013 nilsonholger@hyve.org
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



# output path
_PATH="$HOME/aperture-export/"



# get album names
_ALBUMS=$(awk '/AlbumName/,/string/ {if (/string/) print substr($0,12,length($0)-20)}' ApertureData.xml | tail -n +8)



# process albums
echo $_ALBUMS | while read _ALBUM
do
	# print, create directory and save name
	echo $_ALBUM
	mkdir -p "$_PATH/$_ALBUM"
	_ALBUM_ORIG=$_ALBUM

	# escape '/' and ' '
	_ALBUM="${_ALBUM//\//\\/}"
	_ALBUM="${_ALBUM// /\ }"

	# get image identifiers
	_IMAGES=$(awk "/>${_ALBUM}</,/dict/" ApertureData.xml | awk '/array/,/PhotoCount/' | awk '/string/ {print substr($0, 13, length($0)-21)}')

	# process images in current album
	echo $_IMAGES | while read _IMAGE
	do
		# print and 
		echo -n " $_IMAGE "
		_IMAGE=${_IMAGE//+/.}

		# translate identifier to file path/name
		_FILE=$(awk "/<key>$_IMAGE/,/^Masters/" ApertureData.xml | grep -m1 Masters | awk '{print substr($0, 58, length($0)-66)}')

		# move file
		[ -e "$_FILE" ] && mv -v "$_FILE" "$_PATH/$_ALBUM_ORIG/`basename "$_FILE"`" || echo "NOT FOUND"
	done
	echo
done
