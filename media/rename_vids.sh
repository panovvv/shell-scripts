#!/bin/bash

# Where to take timestamp from
TIMESTAMP_SOURCE=n

# Regex that matches timestamp in filename
TIMESTAMP_REGEX="[0-9]{14}"

renameVideo () {
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
	case "${TIMESTAMP_SOURCE}" in
		n*)	ts=`echo $(basename "$1") | grep -oE $TIMESTAMP_REGEX`
			#any datetime stamp will contain at least 14 difits: 8 for date and 6 for time
			if [[ ${#ts} -lt 14 ]] 
			then
				echo "Processing \"$(basename "$1")\"... Can't find timestamp in name! Skipping..."
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
			;;
		c*)	finalName="$(stat -f %SB -t %Y-%m-%d_%H-%M-%S "$1").${ext}"
			if [[ "${finalName}" = "$(basename "$1")" ]] ;
			then
				echo "Processing \"$(basename "$1")\"... This looks correct! No need to rename it."
			else
				echo "Processing \"$(basename "$1")\"... Will rename to \"${finalName}\""
				DIR=$(dirname "$1")
				mv -vn "$1" "${DIR}/${finalName}"
			fi
			;;
		m*)	finalName="$(date -r "$1" +"%Y-%m-%d_%H-%M-%S").${ext}"
			if [[ "${finalName}" = "$(basename "$1")" ]] ;
			then
				echo "Processing \"$(basename "$1")\"... This looks correct! No need to rename it."
			else
				echo "Processing \"$(basename "$1")\"... Will rename to \"${finalName}\""
				DIR=$(dirname "$1")
				mv -vn "$1" "${DIR}/${finalName}"
			fi
			;;
		*)	echo "Bad TIMESTAMP_SOURCE specified!";
			exit 1
	esac

} 

if [[ -z "$1" ]] || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]] ;
then
	echo "Usage: $(basename "$0") <directory> TIMESTAMP_SOURCE"
	echo "	TIMESTAMP_SOURCE defines where the date that video will be renamed to is coming from."
	echo "	Possible values:"
	echo "	n: file name contains the timestamp already."
	echo "	   Extract the timestamp and rename accordingly."
	echo "	   Likely use case: video from mobile phones."
	echo "	   Example filename: V_20181118_192009_N0.mp4 - will be renamed to 2018-11-18_19-20-09.mp4"
	echo "	   Make sure that TIMESTAMP_REGEX variable contains a regex matching the timestamp format."
	echo "	c: file doesn't contain timestamp in filename."
	echo "	   Will rename files to their CREATION date."
	echo "	   Likely use case: video from compact cameras."
	echo "	   Example filename: MVI_5037.MP4 - will be renamed to whatever date it was created on."
	echo "	m: same as 'c' but renaming files to their MODIFICATION date."
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

countInDir="$(find "$fullDirName" -type f \( -iname "*.mov" -or -iname "*.mp4" -or -iname "*.3gp" -or -iname "*.mts" -or -iname "*.avi" -or -iname "*.dat" \) | wc -l | tr -d '[:space:]')"

if ! [ -z ${2} ] ;
then 
	echo "Parsing user-provided TIMESTAMP_SOURCE..."
	case "${2}" in
		n*)	TIMESTAMP_SOURCE=$2;;
		c*)	TIMESTAMP_SOURCE=$2;;
		m*)	TIMESTAMP_SOURCE=$2;;
		*)	echo "Bad TIMESTAMP_SOURCE specified! Defaulting to 'n' (name contains timestamp)"
			TIMESTAMP_SOURCE=n
	esac
fi

case "${TIMESTAMP_SOURCE}" in
	n*)		echo "Sourcing timestamp from file name, regular expression: ${TIMESTAMP_REGEX}";;
	c*)		echo "Sourcing timestamp from file's creation date";;
	m*)		echo "Sourcing timestamp from file's modification date";;
	*)		echo "Bad TIMESTAMP_SOURCE specified!"; exit 1
esac

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

message="Are you sure you want to rename ${countInDir} videos"
message="$message in \"${fullDirName}\"? (y or Y to proceed)`echo $'\n> '`"

read -p "$message" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	export -f renameVideo
	export TIMESTAMP_SOURCE
	export TIMESTAMP_REGEX
	export fullDirName

	# Show a line of dashes
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	
	find "${fullDirName}" -type f \( -iname "*.mov" -or -iname "*.mp4" -or -iname "*.3gp" -or -iname "*.mts" -or -iname "*.avi" -or -iname "*.dat" \) -exec bash -c 'renameVideo "$0"' {} \;
	
	# Show a line of dashes
	printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi

