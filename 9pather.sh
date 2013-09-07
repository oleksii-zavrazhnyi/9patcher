#!/bin/bash
# Copyright 2013, Alex Zavrazhniy, me@themengzor.com
# CC-BY-NC-SA, http://creativecommons.org/licenses/by-nc-sa/3.0/
# Tested only on OS X 10.8.4

if [ -z "$1" ]; then
	echo "9path-ready automatic images generator"
	echo "Crops central repeatable pixels"
	echo ""
	echo "Usage:"
	echo "       9patch.sh [-skip X] file"
	echo "       9patch.sh [-skip X] file1 file2 ... fileN"
	echo "       9patch.sh [-skip X] *.png"
	echo "       9patch.sh [-skip X] button_*"
	echo "Parameters:"
	echo "       -skip: Skip first X pixels"
	echo "              (for example: 9patch.sh -skip 40 file1 file2 file3)"
	exit 1
fi

if [ "$1" = "-v" ]; then
	echo "9patcher v1.2"
	exit 0
fi

SKIP=0
if [ "$1" = "-skip" ]; then
	SKIP=$2
fi

# cycling through all the passed files
for FILE in "$@"
do
	if [ $SKIP -gt 0 ]; then
		if [ "$FILE" = "$1" ]; then
			continue 2
		fi
		if [ "$FILE" = "$2" ]; then
			continue 2
		fi
	fi

	echo -n "Processing ${FILE}..."

	# checking for a proper image
	CHECK=`identify -format "%wx%h" "${FILE}" 2>&1`
	STATUS=$?
	if [ $STATUS -ne 0 ]; then
		echo -e "$(tput setaf 1) ERROR (not an image) $(tput setaf 7)"
		continue 1
	fi

	# generate temp file name template
	TMP=`mktemp /tmp/9patch_XXXXXXXXXXXX`

	# get image resolution
	WH=`identify -format "%wx%h" "${FILE}" 2>&1`
	WIDTH=`echo $WH | awk -F 'x' {'print $1'}`
	HEIGHT=`echo $WH | awk -F 'x' {'print $2'}`

	# determine initial offset
	if [ $SKIP -gt 0 ]; then
		START1=$SKIP
	else
		START1=2
	fi
		
	let START2=START1+2
	FOUND=0

	# determine first repeatable column
	while [ $FOUND -eq 0 ]; do
		if [ $START2 -eq $WIDTH ]; then
			# there is no repeatable columns in this image
			echo -e "$(tput setaf 1) ERROR (invalid or already patched)$(tput setaf 7)"
			rm -rf ${TMP}*
			continue 2
		fi

		convert "${FILE}" -gravity West -crop 2x${HEIGHT}+${START1}+0 ${TMP}${START1}.png > /dev/null 2>&1
		convert "${FILE}" -gravity West -crop 2x${HEIGHT}+${START2}+0 ${TMP}${START2}.png > /dev/null 2>&1
		COMP=`compare -metric AE ${TMP}${START1}.png ${TMP}${START2}.png /dev/null 2>&1`
		if [ "$COMP" = "0" ]; then
			# repeatable column found
			FOUND=1
		else
			let START1=START1+2
			let START2=START2+2
		fi
	done

	# remove columns temp files
	rm -rf ${TMP}*

	# crop an image
	convert "${FILE}" -gravity West -crop ${START1}x${HEIGHT}+0+0 ${TMP}west.png > /dev/null 2>&1
	convert "${FILE}" -gravity Center -crop 2x${HEIGHT}+0+0 ${TMP}center.png > /dev/null 2>&1
	convert "${FILE}" -gravity East -crop ${START1}x${HEIGHT}+0+0 ${TMP}east.png > /dev/null 2>&1

	# concatenate a final image
	montage ${TMP}west.png ${TMP}center.png ${TMP}east.png -mode Concatenate -tile x1 -background none "${FILE}" > /dev/null 2>&1

	# remove temp files
	rm -rf ${TMP}*

	# image done
	echo -e "$(tput setaf 2) OK$(tput setaf 7)"
done