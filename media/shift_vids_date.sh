#!/bin/bash

# Either add or subtract
SIGN=add

# Number of hours to add/subtract
SHIFT_BY=0

# Which timestamp to change
TIMESTAMP_TO_CHANGE=c

showUsage () {
  echo "Usage:"
  echo "	$(basename "$0") <directory> SIGN SHIFT_BY TIMESTAMP_TO_CHANGE"
  echo "	SIGN can be either 'add' or 'subtract', SHIFT_BY is the number of hours to add or subtract"
  echo "	TIMESTAMP_TO_CHANGE is 'c' to shift creation date or 'm' for modification date"
  echo "IMPORTANT CAVEATS:"
  echo "	1) For now it only works on Macs. Will update it to work on Linux when I have enough time."
  echo "	2) Creation date can't be later than modification date. Don't be surprised when subtracting "
  echo "	from modification date causes creation date to become equal to mod. date - OS fixes the logic"
  echo "	fault for you."
  echo "Example usage:"
  echo "	$(basename "$0") ~/114___04/vids/ subtract 1 m"
  echo "	shift file modification date back by 1 hour"
  echo
  echo "	$(basename "$0") ~/114___04/vids/ add 5 c"
  echo "	shift file creation date forward by 5 hours"
}

shiftDate () {
  echo
  if [[ "$TIMESTAMP_TO_CHANGE" = "c" ]] ;
  then
      ts="$(GetFileInfo -d "$1")"
  else
      ts="$(GetFileInfo -m "$1")"
  fi
    e="$(date -j -f "%m/%d/%Y %H:%M:%S" "$ts" +%s)"
    ((o=60*60*$SHIFT_BY))
    if [[ "$SIGN" = "add" ]] ;
  then
      ((e+=o))
  else
      ((e-=o))
  fi
    nd="$(date -r $e "+%m/%d/%Y %H:%M:%S")"
    echo "Processing \"$(basename "$1")\"...Old date:"
    echo "	${ts}, new date:"
    echo "	${nd}"
  if [[ "$TIMESTAMP_TO_CHANGE" = "c" ]] ;
  then
    SetFile -d "$nd" "$1"
  else
      SetFile -m "$nd" "$1"
  fi
}

# main()
if [[ -z "$1" ]] || [[ "$1" = "-h" ]] || [[ "$1" = "--help" ]] ;
then
  showUsage
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
countInDir="$(find "$fullDirName" -type f \( -iname "*.mov" -or -iname "*.mp4" -or -iname "*.3gp" -or -iname "*.mts" \) | wc -l | tr -d '[:space:]')"

if ! [ -z ${2} ] ;
then 
  case "${2}" in
    add*)		SIGN=$2;;
    subtract*)	SIGN=$2;;
    *)	echo "Can not parse SIGN!"
      showUsage
      exit 1
  esac
else
  showUsage
  exit 1
fi

if ! [ -z ${3} ] ;
then
  regexNumber='^[0-9]+$'
  if ! [[ ${3} =~ $regexNumber ]] ;
  then
      echo "Can not parse SHIFT_BY!"
    showUsage
    exit 1
    else
      SHIFT_BY=$3
  fi
else
  showUsage
  exit 1
fi

if ! [ -z ${4} ] ;
then 
  case "${4}" in
    c*)	TIMESTAMP_TO_CHANGE=$4;;
    m*)	TIMESTAMP_TO_CHANGE=$4;;
    *)	echo "Can not parse TIMESTAMP_TO_CHANGE!"
      showUsage
      exit 1
  esac
else
  showUsage
  exit 1
fi

MSG="Will $SIGN $SHIFT_BY hour(s)"
if [[ "$SIGN" = "add" ]] ;
then
  MSG="$MSG to"
else
  MSG="$MSG from"
fi
if [[ "$TIMESTAMP_TO_CHANGE" = "c" ]] ;
then
  MSG="$MSG creation date"
else
  MSG="$MSG modification date"
fi
echo "$MSG"

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

message="Change the timestamp for ${countInDir} videos"
message="$message in \"${fullDirName}\"? (y or Y to proceed)`echo $'\n> '`"

read -p "$message" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  export -f shiftDate
  export SIGN
  export SHIFT_BY
  export TIMESTAMP_TO_CHANGE

  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

  find "${fullDirName}" -type f \( -iname "*.mov" -or -iname "*.mp4" -or -iname "*.3gp" -or -iname "*.mts" \) -exec bash -c 'shiftDate "$0"' {} \;

  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi

