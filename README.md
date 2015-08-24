# photo-focal-stats-script
A simple bash script to extract a report on the most used focal lenghts from a folder full of photos

# Motivation

I wanted to analyze my photographic habits relating to the most used focal lengths. I wanted to know if I used to shoot most angular, normal or tele, and in which proportions. So, I made a script to analyze the EXIF data of all the JPG files from a folder in the system (i.e. I put my photos organized by years, so I can execute the script in the 2015 folder to analize the focal lengths used in 2015).

# Usage

Usage: stats_focal.sh [-d DIR] [-s STRING] [-f FORMAT]
  -d DIR: root directory where the photos directories live, WITHOUT trailing slash; by default it's the current directory.
  -s STRING: sets the STRING to look for in the EXIF data; default: 'Focal Length'.
  -f FORMAT: sets the FORMAT of the camera; available values: 'm43', 'apsc', 'ff', 'mf'; default is 'm43'.

Examples:
   ./stats_focal.sh -d /media/Fotos/2014 -> will proccess the *.jpg and *.JPG inside all the subdirectories under /media/Fotos/2014/.
   ./stats_focal.sh -d /media/Fotos/2014 -s "Focal size" -> will proccess the *.jpg and *.JPG inside all the subdirectories under /media/Fotos/2014/ looking for string 'Focal size' in the EXIF data.
   ./stats_focal.sh -f "apsc" -> will proccess the *.jpg and *.JPG inside all the subdirectories under the current directory, using format Full Frame to calculate the focal lenght.


# How it works

The script will loop through all the subdirectories under the marked one. Inside each subdir, the script will look for *.jpg and *.JPG files, and for each file will look their EXIF data using exiftool; if it founds a "Focal Length" item, the script will count it in one of the counters: Ultrawide, Wide, Normal, Tele or Ultratele.

You can change the string to search for in the EXIF using the -s parameter.

To avoid "equivalent" items in EXIF, the script discards EXIF entries with text "equivalent" o "35mm Format".

The script can decide about which counter use according to the camera format: micro4/3, APS-C, Full Frame or Medium Format; the values used, relating to 35mm (Full Frame) are:

  * UltraWide: < 28mm
  * Wide: 29-40mm 
  * Normal: 41-60mm
  * Tele: 61-130mm
  * UltraTele: > 131mm


