#! /usr/bin/env zsh
#
# ocr circumvents pdf ocr x free version one page restriction (sorry) by
# separating a pdf into single pages, running them through ocr x and
# reassembling them into a single pdf again
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

# setup variables
TMPDIR=/Volumes/ramdisk

# loop through all arguments
for FILE in $@
do
	# create ramdisk and copy file
	diskutil erasevolume HFS+ "$TMPDIR:t" `hdiutil attach -nomount ram://1165430` > /dev/null
	cp $FILE $TMPDIR
	cd $TMPDIR

	# strip path
	FILE=$FILE:t

	# check for number of pages
	PAGES=`gs -dNODISPLAY -dNOPAUSE -dBATCH $FILE | grep Processing | cut -d' ' -f5 | cut -d'.' -f1`
	echo "INPUT: $FILE ($PAGES)"

	# split -> ocr -> merge
	for i in {0001..$PAGES}
	do
		gs -dFirstPage=$i -dLastPage=$i -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$TMPDIR/$i.pdf $FILE
		open -a /Applications/PDF\ OCR\ X.app $i.pdf
		while true
		do
			sleep 1
			if [ -r $i.pdf.searchable.pdf ]
			then
				break
			fi
		done
	done
	gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$FILE.searchable.pdf [0-9][0-9][0-9][0-9].pdf.searchable.pdf


	# check for number of pages again and compare
	PAGES2=`gs -dNODISPLAY -dNOPAUSE -dBATCH $FILE.searchable.pdf | grep Processing | cut -d' ' -f5 | cut -d'.' -f1`
	[ $PAGES -eq $PAGES2 ] && echo "SUCCESS: $FILE ($PAGES)" || echo "FAILURE: $FILE ($PAGES != $PAGES2 )"

	# cleanup
	killall Preview
	killall JavaApplicationStub
	mv $FILE.searchable.pdf ~/Downloads/${FILE/.searchable.pdf}
	cd -
	hdiutil detach $TMPDIR > /dev/null
done
