#!/bin/bash

SCRIPT_NAME=$0

if [ $# -lt 3 ]; then
	echo "Usage: $SCRIPT_NAME <IMAGE> <CANVAS> [WxH [WxH ...]"
	exit 1
fi

IMAGE=$1
CANVAS=$2

if [ ! -f "$IMAGE" ]; then
	echo "Error: File \"$IMAGE\" not found"
	exit 1
fi

if [ ! -f "$CANVAS" ]; then
	echo "Error: File \"$CANVAS\" not found"
	exit 1
fi

SIZES=${@:3}

for SIZE in $SIZES; do 
	WHARRAY=(${SIZE//x/ })
	if [ ${#WHARRAY[@]} -ne 2 ]; then
		echo "Error: \"$SIZE\" is not a valid size."
		continue
	fi
	re='^[0-9]+$'
	if ! [[ ${WHARRAY[0]} =~ $re ]]; then
		echo "Error: \"$SIZE\" is not a valid size."
		continue
	fi	
	if ! [[ ${WHARRAY[1]} =~ $re ]]; then
		echo "Error: \"$SIZE\" is not a valid size."
		continue
	fi
	WIDTH=${WHARRAY[0]}
	HEIGHT=${WHARRAY[1]}

	IMAGE_PX=`identify -format "%w %h " $IMAGE && identify -format "%w %h" $CANVAS`

	whARRAY=(${IMAGE_PX//x/ })
	srcWIDTH=${whARRAY[0]}
	srcHEIGHT=${whARRAY[1]}
	maxWIDTH=${whARRAY[2]}
	maxHEIGHT=${whARRAY[3]}

	if [ ! ${#IMAGE_PX[0]} -lt ${#IMAGE_PX[2]} ]; then
		convert $IMAGE -resize "$srcWIDTHX$maxHEIGHT" test_file.png
		composite -gravity center test_file.png $CANVAS $IMAGE'_'$srcWIDTH'x'$maxHEIGHT
		convert $IMAGE'_'$srcWIDTH'x'$maxHEIGHT -resize $WIDTH'x'$HEIGHT $IMAGE'_'$WIDTH'x'$HEIGHT.png 
		rm test_file.png
	else
		convert $IMAGE -resize "$maxWIDTHX$srcHEIGHT" test_file.png
		composite -gravity center test_file.png $CANVAS $IMAGE'_'$srcWIDTH'x'$maxHEIGHT
		convert $IMAGE'_'$srcWIDTH'x'$maxHEIGHT -resize $WIDTH'x'$HEIGHT $IMAGE'_'$WIDTH'x'$HEIGHT.png
		rm test_file.png
	fi

	echo "Creating file $IMAGE-$WIDTH-$HEIGHT.png with a width of $WIDTH pixel and a height of $HEIGHT pixel."

done


