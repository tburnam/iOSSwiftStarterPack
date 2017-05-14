#!/bin/sh
 
# Adatped from: https://rudifa.wordpress.com/2011/07/23/clonexcodeproject-sh/
 
NEWNAME=$1
 
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