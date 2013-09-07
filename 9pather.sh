#!/bin/bash
# Copyright 2013, Alex Zavrazhniy, me@themengzor.com
# CC-BY-NC-SA, http://creativecommons.org/licenses/by-nc-sa/3.0/
# Tested only on OS X 10.8.4

if [ -z "$1" ]; then
	echo "9path-ready automatic images generator"
	echo "Crops central repeatable pixels"
	echo ""
	echo "Usage:"
	echo "       9patch.sh file"
	echo "       9patch.sh file1 file2 ... fileN"
	echo "       9patch.sh *.png"
	echo "       9patch.sh button_*"
	exit 1
fi

if [ "$1" = "-v" ]; then
	echo "9patcher v1.0"
	exit 0
fi

# cycling through all the passed files
for FILE in "$@"
do
	echo -n "Processing $FILE..."

	# checking for a proper image
	CHECK=`identify $FILE 2>&1`
	STATUS=$?
	if [ $STATUS -ne 0 ]; then
		echo -e "$(tput setaf 1) ERROR (not an image) $(tput setaf 7)"
		continue 1
	fi

	# get image resolution
	WH=`identify $FILE 2>&1 | awk {'print $3'} 2>&1`
	WIDTH=`echo $WH | awk -F 'x' {'print $1'}`
	HEIGHT=`echo $WH | awk -F 'x' {'print $2'}`

	# determine first releatable column
	START1=2
	START2=4
	FOUND=0
	while [ $FOUND -eq 0 ]; do
		if [ $START2 -eq $WIDTH ]; then
			# there is no repeatable columns in this image
			echo -e "$(tput setaf 1) ERROR (invalid or already patched)$(tput setaf 7)"
			rm -rf /tmp/$FILE-start-*
			continue 2
		fi

		convert $FILE -gravity West -crop 2x$HEIGHT+$START1+0 /tmp/$FILE-start-$START1.png > /dev/null 2>&1
		convert $FILE -gravity West -crop 2x$HEIGHT+$START2+0 /tmp/$FILE-start-$START2.png > /dev/null 2>&1
		COMP=`compare -metric AE /tmp/$FILE-start-$START1.png /tmp/$FILE-start-$START2.png /dev/null 2>&1`
		if [ "$COMP" = "0" ]; then
			# repeatable column found
			FOUND=1
		else
			let START1=START1+2
			let START2=START2+2
		fi
	done

	# remove columns temp files
	rm -rf $FILE-start-*

	# crop an image
	convert $FILE -gravity West -crop ${START1}x$HEIGHT+0+0 /tmp/$FILE-9patch-1.png > /dev/null 2>&1
	convert $FILE -gravity Center -crop 2x$HEIGHT+0+0 /tmp/$FILE-9patch-2.png > /dev/null 2>&1
	convert $FILE -gravity East -crop ${START1}x$HEIGHT+0+0 /tmp/$FILE-9patch-3.png > /dev/null 2>&1

	# concatenate a final image
	montage /tmp/$FILE-9patch-*.png -mode Concatenate -tile x1 -background none $FILE > /dev/null 2>&1

	# remove temp files
	rm -rf /tmp/$FILE-9patch*

	# image done
	echo -e "$(tput setaf 2) OK$(tput setaf 7)"
done