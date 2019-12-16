#!/bin/bash

# * Works with media files (images and videos), extension is case-insensitive
# * If the date can not be extracted from file's name, the file will be renamed according to
# either creation date, modification date or skipped altogether

# How to treat files where date can't be extracted from name
FLAG=s

# Regex that matches timestamp in filename
#TIMESTAMP_REGEX="[0-9]{8}_[0-9]{6}"
TIMESTAMP_REGEX="[0-9]{14}"

renameFile () {
	# Above regex will single out timestamp from name.
	# Variables below define where in this string we have 
	# every portion of date and time.
	YEAR_POSITION=0
	MONTH_POSITION=4
	DAY_POSITION=6
	HOUR_POSITION=8
	MINUTE_POSITION=10
	SECOND_POSITION=12

	echo
	filename=$(basename -- "$1")
	ext="${filename##*.}"
	ext=`echo "$ext" | tr '[:upper:]' '[:lower:]'`;

	ts=`echo $(basename "$1") | grep -oE $TIMESTAMP_REGEX`

	#any datetime stamp will contain at least 14 difits: 8 for date and 6 for time
	if [[ ${#ts} -lt 14 ]] 
	then
		case "${FLAG}" in
			c*)	echo "Processing \"$(basename "$1")\"... Can't find timestamp in name! Will set file name to \"$(stat -f %SB -t %Y-%m-%d_%H-%M-%S "$1").${ext}\""
				mv -vn "$1" "${fullDirName}/$(stat -f %SB -t %Y-%m-%d_%H-%M-%S "$1").${ext}"
				;;
			m*)	echo "Processing \"$(basename "$1")\"... Can't find timestamp in name! Will set file name to \"$(date -r "$1" +"%Y-%m-%d_%H-%M-%S").${ext}\""
				mv -vn "$1" "${fullDirName}/$(date -r "$1" +"%Y-%m-%d_%H-%M-%S").${ext}"
				;;
			s*)	echo "Processing \"$(basename "$1")\"... Can't find timestamp in name! Skipping...";;
			*)	echo "Bad FLAG specified!";
				exit 1
		esac
	else
		y=${ts:$YEAR_POSITION:4}
		mo=${ts:$MONTH_POSITION:2}
		d=${ts:$DAY_POSITION:2}
		h=${ts:$HOUR_POSITION:2}
		mi=${ts:$MINUTE_POSITION:2}
		s=${ts:$SECOND_POSITION:2}
		finalName="${y}-${mo}-${d}_${h}-${mi}-${s}.${ext}"
		echo "Processing \"$(basename "$1")\"... Found timestamp \"${ts}\"! Renaming to ${finalName}"
		DIR=$(dirname "$1")
		mv -vn "$1" "${DIR}/${finalName}"
	fi
} 

if [[ -z "$1" ]] || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]] ;
then
	echo "Usage: $(basename "$0") <directory> FLAG"
	echo "	where FLAG defines how this script treats media files without"
	echo "	valid dates in their names. FLAG can be one of the following:"
	echo "		c - set file name based on its creation date"
	echo "		m - set file name based on its modification date"
	echo "		s - skip these files"
	echo "	FLAG is set to s by default."
	exit 1
fi

if ! [ -d "$1" ] ;
then 
	echo "Please provide a valid directory!"
	exit 1
fi

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

fullDirName="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
echo "Target directory: \"${fullDirName}\""

countImg="$(find "$fullDirName" \( -iname '*.jpg' -o -iname '*.jpeg' \) | wc -l | tr -d '[:space:]')"
countVid="$(find "$fullDirName" -iname '*.mts' | wc -l | tr -d '[:space:]')"
countInDir=$(( $countImg + $countVid ))

if ! [ -z ${2} ] ;
then 
	echo "Parsing user-provided FLAG..."
	case "${2}" in
		c*)	FLAG=$2;;
		m*)	FLAG=$2;;
		s*)	FLAG=$2;;
		*)	echo "Bad FLAG specified! Defaulting to s (keep old name)"
	esac
fi

case "${FLAG}" in
	c*)		echo "Will set file name to CREATION DATE if date can't be extracted from filename";;
	m*)		echo "Will set file name to MODIFICATION DATE if date can't be extracted from filename";;
	s*)		echo "Will KEEP OLD file name if date can't be extracted from filename";;
	*)		echo "Bad FLAG specified!"; exit 1
esac

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

message="Are you sure you want to rename ${countInDir} media files? (${countImg} images and ${countVid} videos)"
message="$message in \"${fullDirName}\"? (y or Y to proceed)`echo $'\n> '`"

read -p "$message" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	export -f renameFile
	export FLAG
	export TIMESTAMP_REGEX
	export fullDirName
	# Show a line of dashes
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	
	find "${fullDirName}" -type f -iname '*.jpg' -exec bash -c 'renameFile "$0"' {} \;
	find "${fullDirName}" -type f -iname '*.jpeg' -exec bash -c 'renameFile "$0"' {} \;
    find "${fullDirName}" -type f -iname '*.mts' -exec bash -c 'renameFile "$0"' {} \;
	
	# Show a line of dashes
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi

