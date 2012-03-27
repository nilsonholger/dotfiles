#! /bin/zsh
#
# ocr circumvents pdf ocr x free version one page restriction (sorry) by
# separating a pdf into single pages, running them through ocr x and
# reassembling them into a single pdf again

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
