#!/bin/bash

ULTRAWIDE=0
WIDE=0
NORMAL=0
TELE=0
ULTRATELE=0

COUNT=0
SUBCOUNT=0
COUNTNOEXIF=0

HEREIAM=`pwd`

# Function showhelp: shows a little help message
function showhelp {
	echo -e "\n"
	echo "Usage: stats_focal.sh [-d DIR] [-s STRING] [-f FORMAT]"
	echo "  -d DIR: root directory where the photos directories live, WITHOUT trailing slash; by default it's the current directory."
	echo "  -s STRING: sets the STRING to look for in the EXIF data; default: 'Focal Length'."
	echo "  -f FORMAT: sets the FORMAT of the camera; available values: 'm43', 'apsc', 'ff', 'mf'; default is 'm43'."
	echo ""
	echo "Examples:"
	echo "   ./stats_focal.sh -d /media/Fotos/2014 -> will proccess the *.jpg and *.JPG inside all the subdirectories under /media/Fotos/2014/."
	echo "   ./stats_focal.sh -d /media/Fotos/2014 -s \"Focal size\" -> will proccess the *.jpg and *.JPG inside all the subdirectories under /media/Fotos/2014/ looking for string 'Focal size' in the EXIF data."
	echo "   ./stats_focal.sh -f \"apsc\" -> will proccess the *.jpg and *.JPG inside all the subdirectories under the current directory, using format Full Frame to calculate the focal lenght."
	echo ""
	echo ""
}

# Function countfiles: recursive function to loop through all the subdirectories, and all the *.jpg and *.JPG files inside them
function countfiles {

	echo -e "\nReading `pwd` ..."

	EXISTS=`ls -1 *.jpg 2>/dev/null | wc -l`
	if [ $EXISTS != 0 ]; then
		for FILE in *.jpg; do
      	          VAL=`exiftool $FILE  | grep -i $EXIFSTRING | grep -v equivalent | grep -v "35mm Format" | grep mm | cut -d":" -f 2 | cut -d" " -f 2 | cut -d"." -f 1 | uniq`

		  if [ "$VAL" != "" ]; then

	 	        if [ $VAL -lt $ULTRAWIDELIMIT ]; then
	                        ULTRAWIDE=$((ULTRAWIDE+1))
	                elif [ $VAL -ge $ULTRAWIDELIMIT ] && [ $VAL -le $WIDELIMIT ]; then
	                        WIDE=$((WIDE+1))
	                elif [ $VAL -gt $WIDELIMIT ] && [ $VAL -le $NORMALLIMIT ]; then
	                        NORMAL=$((NORMAL+1))
	                elif [ $VAL -gt $NORMALLIMIT ] && [ $VAL -le $TELELIMIT ]; then
	                        TELE=$((TELE+1))
	                elif [ $VAL -gt $TELELIMIT ]; then
	                        ULTRATELE=$((ULTRATELE+1))
	                fi

	                COUNT=$((COUNT+1))
	                SUBCOUNT=$((SUBCOUNT+1))
		  else
			COUNTNOEXIF=$((COUNTNOEXIF+1))

		  fi
	        done
	fi

	EXISTS=`ls -1 *.JPG 2>/dev/null | wc -l`
        if [ $EXISTS != 0 ]; then
                for FILE in *.JPG; do
                  VAL=`exiftool $FILE  | grep -i $EXIFSTRING | grep -v equivalent | grep -v "35mm Format" | grep mm | cut -d":" -f 2 | cut -d" " -f 2 | cut -d"." -f 1 | uniq`

		  if [ "$VAL" != "" ]; then

                        if [ $VAL -lt $ULTRAWIDELIMIT ]; then
                                ULTRAWIDE=$((ULTRAWIDE+1))
                        elif [ $VAL -ge $ULTRAWIDELIMIT ] && [ $VAL -le $WIDELIMIT ]; then
                                WIDE=$((WIDE+1))
                        elif [ $VAL -gt $WIDELIMIT ] && [ $VAL -le $NORMALLIMIT ]; then
                                NORMAL=$((NORMAL+1))
                        elif [ $VAL -gt $NORMALLIMIT ] && [ $VAL -le $TELELIMIT ]; then
                                TELE=$((TELE+1))
                        elif [ $VAL -gt $TELELIMIT ]; then
                                ULTRATELE=$((ULTRATELE+1))
                        fi

                        COUNT=$((COUNT+1))
                        SUBCOUNT=$((SUBCOUNT+1))
                  else
                        COUNTNOEXIF=$((COUNTNOEXIF+1))
                  
                  fi

                done
        fi

	# If there are any subdirectories, go inside them recursively
	EXISTS=`ls -1 */ 2>/dev/null | wc -l`
        if [ $EXISTS != 0 ]; then
		for SUBFOLDER in `ls -d */`; do
			cd `pwd`/$SUBFOLDER
			countfiles
			cd .. 
		done
	fi

	#echo "Processed $SUBCOUNT"
	SUBCOUNT=0
}

command -v exiftool >/dev/null 2>&1 || { echo >&2 "I require 'exiftool', but it's not installed.  Aborting."; exit 1; }

if [ "$1" == "-h" ]; then
	showhelp
	exit 0
fi

# Vars to loop through directories
OLDIFS=$IFS
IFS=$'\n' # This is to use only \n as spacer, and not other spaces or tabs (useful for the 'for' loop)

# Default values
WORKDIR=`pwd`
EXIFSTRING="Focal Length"
CAMFORMAT="m43"


# Analize params
ARGG=""
while test $# -gt 0
do  
    case "$1" in 
        -d) ARGG="WORKDIR"
            ;;
        -s) ARGG="EXIFSTRING"
            ;;
        -f) ARGG="CAMFORMAT"
            ;;
	-*) echo "Bad option $1"
		showhelp
		exit 1
            ;;
	--*) echo "Bad option $1"
		showhelp
		exit 1
            ;;
        *)  eval $ARGG='$1'
            ;;
    esac
    shift
done

# Set focal lenghts depending on camera format. The reference is the 35mm format (Full Frame)
# UltraWide: < 28mm equiv
# Wide: 29-40mm equiv
# Normal: 41-60mm equiv
# Tele: 61-130mm equiv
# UltraTele: > 131mm equiv

case "$CAMFORMAT" in
	m43)
		# Factor = x2
		ULTRAWIDELIMIT=14
		WIDELIMIT=20
		NORMALLIMIT=30
		TELELIMIT=65
		;;
	apsc)
		# Factor = x1.5
		ULTRAWIDELIMIT=18
		WIDELIMIT=27
		NORMALLIMIT=40
		TELELIMIT=86
		;;
	ff)
		# Factor = x1
		ULTRAWIDELIMIT=28
		WIDELIMIT=40
		NORMALLIMIT=60
		TELELIMIT=130
		;;
	mf)
		# Factor = x0.651
		ULTRAWIDELIMIT=43
		WIDELIMIT=62
		NORMALLIMIT=92
		TELELIMIT=200
		;;
esac

# Loop through directories
for FOLDER in `ls -d $WORKDIR/*/`; do
	# Delete quotation marks, if exists
	PROCESSDIR=`echo $FOLDER | sed "s/\"//g"`

	cd $PROCESSDIR

	countfiles

	#echo "Processsed $COUNT files"
done

IFS=$OLDIFS # Undo this change

# Show final report

echo -e "\n======================================\n"

echo "Total de archivos: `echo $COUNT+$COUNTNOEXIF | bc`"
echo "Total de archivos procesados: $COUNT"
echo "Total de archivos sin datos EXIF: $COUNTNOEXIF"
echo -e "\n======================================\n"
echo "Ultra angular: $ULTRAWIDE"
echo "Angular: $WIDE"
echo "Normal: $NORMAL"
echo "Tele: $TELE"
echo "Ultra tele: $ULTRATELE"
echo ""

# Go back to the former path
cd $HEREIAM

exit 0
