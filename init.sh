#!/bin/sh
 
################################################################################
#
#      cloneXcodeProject.sh
#
# morphed from the original renameXcodeProject.sh by Monte Ohrt (see below)
# by Rudi Farkas <rudi.farkas@gmail.com>
# version : 1.01
# date : 22 Jul 2011
#
# purpose : copy and rename an XCode project
#
# features (over and above those of renameXcodeProject.sh) :
#
# 1- makes the copied files writable before attempting to modify their content
#
# 2- works even if the new project name contains the old project name, for instance
#     cloneXcodeProject.sh "MyStuff" "MyStuff2"
#
# installation :
#
# copy this file to a directory in your PATH, and make it executable with :
#
#   chmod +x cloneXcodeProject.sh
#
# usage :
#
#   cloneXcodeProject.sh <OldProjectName> <NewProjectName>
#
# example :
#
#   cloneXcodeProject.sh MyStuff MyNewStuff
#
# use at your own risk
# let me know if something does not work as advertized
#
################################################################################
 
################################################################################
#
# renameXcodeProject.sh
#
# author: Monte Ohrt <monte@ohrt.com>
# date: Jan 27, 2009
# version: 1.0
# http://www.phpinsider.com/xcode/renameXcodeProject.sh.txt
#
# This script will copy an xcode project to a new project directory name
# and replace/rename all files within to work as expected under the new name.
# Project names that contain characters other than alpha-numeric, spaces or
# underscores MAY not work properly with this script. Use at your own risk!
# Be CERTAIN to backup your project(s) before renaming.
#
# One simple rule:
#
# 1) The old project name cannot contain the new project name, so for instance,
#    renaming "MyStuff" to "MyStuff2" will not work. If you really need to do
#    this, rename the project to a temp name, then rename again.
#
# I have instructions for manually renaming an xcode project here:
#
# http://mohrt.blogspot.com/2008/12/renaming-xcode-project.html
#
#
# Installation:
#
# Copy (this) file "renameXcodeProject.sh" to your file system, and invoke:
#
#   chmod 755 renameXcodeProject.sh
#
# to make it executable.
#
# usage:
#
#   renameXcodeProject.sh <OldProjectName> <NewProjectName>
#
# example:
#
#   ./renameXcodeProject.sh MyStuff MyNewStuff
#
################################################################################
 
NEWNAME=$1
#NEWNAME=$2
 
# remove bad characters
iOSSwiftStarterPack=`echo "${iOSSwiftStarterPack}" | sed -e "s/[^a-zA-Z0-9_ -]//g"`
NEWNAME=`echo "${NEWNAME}" | sed -e "s/[^a-zA-Z0-9_ -]//g"`
 
echo ${iOSSwiftStarterPack}
echo ${NEWNAME}
 
TMPFILE=/tmp/xcodeRename.$$
TMPPROJNAME="D401CB997FCB4CB4AABFAC60E754C7B2"
 
if [ "$iOSSwiftStarterPack" = "" -o "$NEWNAME" = "" ]; then
	echo "usage: $0 <OldProjectName> <NewProjectName>"
	exit
fi
 
if [ ! -d "${iOSSwiftStarterPack}" ]; then
	echo "ERROR: \"${iOSSwiftStarterPack}\" must be a directory"
	exit
fi
 
# set new project directory
if [ -d "${NEWNAME}" ]; then
	echo "ERROR: project directory \"${NEWNAME}\" exists. Terminating."
	exit
fi
 
# does NEWNAME contain iOSSwiftStarterPack ?
echo "${NEWNAME}" | grep "${iOSSwiftStarterPack}" > /dev/null
if [ $? -eq 0 ]; then
	# yes : set up names for the two-pass operation
	FINALNAME="${NEWNAME}"
	NEWNAME="401CB99D-7FCB-4CB4-AABF-AC60E754C7B2"
	echo "Warning: New project name contains old project name. Project will be renamed in two passes."
else
	# no : one pass operation is sufficient
	FINALNAME=""
fi
 
# be sure tmp file is writable
cp /dev/null ${TMPFILE}
if [ $? -ne 0 ]; then
	echo "tmp file ${TMPFILE} is not writable. Terminating."
	exit
fi
 
# create project name with unscores for spaces
iOSSwiftStarterPackUSCORE=`echo "${iOSSwiftStarterPack}" | sed -e "s/ /_/g"`
NEWNAMEUSCORE=`echo "${NEWNAME}" | sed -e "s/ /_/g"`
 
# copy project directory
echo copying project directory from "${iOSSwiftStarterPack}" to "${NEWNAME}"
cp -rp "${iOSSwiftStarterPack}" "${NEWNAME}"
 
# remove build directory
echo removing build directory from "${NEWNAME}"
rm -rf "${NEWNAME}/build"
 
# find text files, replace text
find "${NEWNAME}/." | while read currFile
do
	# find files that are of type text
	file "${currFile}" | grep "text" > /dev/null
	if [ $? -eq 0 ]; then
		# make sure it is writable
		chmod +w "${currFile}"
		# see if old proj name with underscores is in the text
		grep "${iOSSwiftStarterPackUSCORE}" "${currFile}" > /dev/null
		if [ $? -eq 0 ]; then
			# replace the text with new proj name
			echo replacing "${iOSSwiftStarterPackUSCORE}" in "${currFile}"
			sed -e "s/${iOSSwiftStarterPackUSCORE}/${NEWNAMEUSCORE}/g" "${currFile}" > ${TMPFILE}
			mv ${TMPFILE} "${currFile}"
			cp /dev/null ${TMPFILE}
		fi
		# see if old proj name is in the text
		grep "${iOSSwiftStarterPack}" "${currFile}" > /dev/null
		if [ $? -eq 0 ]; then
			# replace the text with new proj name
			echo replacing "${iOSSwiftStarterPack}" in "${currFile}"
			sed -e "s/${iOSSwiftStarterPack}/${NEWNAME}/g" "${currFile}" > ${TMPFILE}
			mv ${TMPFILE} "${currFile}"
			cp /dev/null ${TMPFILE}
		fi
	fi
done
 
# rename directories with underscores
find "${NEWNAME}/." -type dir | while read currFile
do
	echo "${currFile}" | grep "${iOSSwiftStarterPackUSCORE}" > /dev/null
	if [ $? -eq 0 ]; then
		MOVETO=`echo "${currFile}" | sed -e "s/${iOSSwiftStarterPackUSCORE}/${NEWNAMEUSCORE}/g"`
		echo renaming "${currFile}" to "${MOVETO}"
		mv "${currFile}" "${MOVETO}"
	fi
done
 
# rename directories with spaces
find "${NEWNAME}/." -type dir | while read currFile
do
	echo "${currFile}" | grep "${iOSSwiftStarterPack}" > /dev/null
	if [ $? -eq 0 ]; then
		MOVETO=`echo "${currFile}" | sed -e "s/${iOSSwiftStarterPack}/${NEWNAME}/g"`
		echo renaming "${currFile}" to "${MOVETO}"
		mv "${currFile}" "${MOVETO}"
	fi
done
 
# rename files with underscores
find "${NEWNAME}/." -type file | while read currFile
do
	echo "${currFile}" | grep "${iOSSwiftStarterPackUSCORE}" > /dev/null
	if [ $? -eq 0 ]; then
		MOVETO=`echo "${currFile}" | sed -e "s/${iOSSwiftStarterPackUSCORE}/${NEWNAMEUSCORE}/g"`
		echo renaming "${currFile}" to "${MOVETO}"
		mv "${currFile}" "${MOVETO}"
	fi
done
 
# rename files with spaces
find "${NEWNAME}/." -type file | while read currFile
do
	echo "${currFile}" | grep "${iOSSwiftStarterPack}" > /dev/null
	if [ $? -eq 0 ]; then
		MOVETO=`echo "${currFile}" | sed -e "s/${iOSSwiftStarterPack}/${NEWNAME}/g"`
		echo renaming "${currFile}" to "${MOVETO}"
		mv "${currFile}" "${MOVETO}"
	fi
done
 
rm -f ${TMPFILE}
 
if [ "$FINALNAME" = "" ]; then
	# this is the second pass : remove temp project directory
	if [ "${iOSSwiftStarterPack}" = "${TMPPROJNAME}" ]; then
		rm -rf "${TMPPROJNAME}"
	fi
	echo finished.
	exit
else
	echo
	echo starting the second pass...
	$0 "$NEWNAME" "$FINALNAME"
fi