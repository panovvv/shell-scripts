#!/bin/bash

# * Works with media files (images and videos), extension is case-insensitive
# * If the date can not be extracted from file's name, the file will be renamed according to
# either creation date, modification date or skipped altogether

# How to treat files where date can't be extracted from name
FLAG=s

function sharearrays() {
  # Array of regexes that match timestamp in filename
  TIMESTAMP_REGEXES=(
    "[0-9]{14}"
    "[0-9]{8}_[0-9]{6}"
    "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]\.[0-9]{2}\.[0-9]{2} [aApP][mM]"
    "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}\.[0-9]{2}\.[0-9]{2} [aApP][mM]"
    "[0-9]{4}-[0-9]{2}-[0-9]{2} at [0-9]\.[0-9]{2}\.[0-9]{2} [aApP][mM]"
    "[0-9]{4}-[0-9]{2}-[0-9]{2} at [0-9]{2}\.[0-9]{2}\.[0-9]{2} [aApP][mM]"
    "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}\.[0-9]{2}\.[0-9]{2}"
    "[0-9]{8}-[0-9]{6}"
  )

  # This is what we show on each script run to demonstrate what kind of timestamps we can find.
  TIMESTAMP_EXAMPLES=(
    "20191224190356"
    "20191224_190356"
    "2019-12-24 7.03.56 pm"
    "2019-12-24 11.03.56 am"
    "2019-12-24 at 6.03.56 am"
    "2019-12-24 at 10.03.56 pm"
    "2019-12-24 22.03.56"
    "20250905-213240"
  )
  TIMESTAMP_EXAMPLES_RESOLVED=(
    "2019-12-24_19-03-56"
    "2019-12-24_19-03-56"
    "2019-12-24_19-03-56"
    "2019-12-24_11-03-56"
    "2019-12-24_06-03-56"
    "2019-12-24_22-03-56"
    "2019-12-24_22-03-56"
    "2025-09-05_21-32-40"
  )

  # Above regexes will single out timestamp from name.
  # Variables below define where in this string we have
  # every portion of date and time.
  YEAR_POSITION=(0 0 0 0 0 0 0 0)
  MONTH_POSITION=(4 4 5 5 5 5 5 4)
  DAY_POSITION=(6 6 8 8 8 8 8 6)
  HOUR_POSITION=(8 9 11 11 14 14 11 9)
  HOUR_NUM_DIGITS=(2 2 1 2 1 2 2 2)
  HOUR_MODIFIER_POSITION=(-1 -1 19 20 22 23 -1 -1)
  MINUTE_POSITION=(10 11 13 14 16 17 14 11)
  SECOND_POSITION=(12 13 16 17 19 20 17 13)
}

renameFile() {
  echo
  filename=$(basename -- "$1")
  ext="${filename##*.}"
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

  found=false
  for i in "${!TIMESTAMP_REGEXES[@]}"; do
    ts=$(basename "$1" | grep -oE "${TIMESTAMP_REGEXES[$i]}")

    #any datetime stamp will contain at least 14 digits: 8 for date and 6 for time
    if [[ ${#ts} -gt 13 ]]; then
      y=${ts:${YEAR_POSITION[$i]}:4}
      mo=${ts:${MONTH_POSITION[$i]}:2}
      d=${ts:${DAY_POSITION[$i]}:2}
      h=${ts:${HOUR_POSITION[$i]}:${HOUR_NUM_DIGITS[$i]}}
      if [[ ${HOUR_MODIFIER_POSITION[$i]} -gt -1 ]]; then
        mod=${ts:${HOUR_MODIFIER_POSITION[$i]}:2}
        mod=$(echo "$mod" | tr '[:lower:]' '[:upper:]')
        if [[ "${mod:0:1}" == "P" ]]; then
          h=$((h + 12))
        else
          h=${h/ /0}
        fi
      fi
      mi=${ts:${MINUTE_POSITION[$i]}:2}
      s=${ts:${SECOND_POSITION[$i]}:2}
      finalName="${y}-${mo}-${d}_${h}-${mi}-${s}.${ext}"
      echo "Processing \"$(basename "$1")\"... Found timestamp \"${ts}\"! Renaming to ${finalName}"
      DIR=$(dirname "$1")

      if [ -s "${DIR}/${finalName}" ]; then
        echo "File with name '${finalName}' is already present in ${DIR}!"
        for ind in $(seq 1 100000); do
          finalName="${y}-${mo}-${d}_${h}-${mi}-${s}_${ind}.${ext}"
          if [ ! -s "${DIR}/${finalName}" ]; then
            if mv -vn "$1" "${DIR}/${finalName}"; then
              echo "Renamed $1 to the first available name: ${finalName}"
              break
            else
              echo "Can't rename $1 to ${finalName}... This shouldn't have happened."
              break
            fi
          fi
        done
      else
        mv -vn "$1" "${DIR}/${finalName}"
      fi

      found=true
      break
    fi
  done

  if [ "$found" = false ]; then
    case "${FLAG}" in
    c*)
      echo "Processing \"$(basename "$1")\"... Can't find timestamp in name!
      Will set file name to \"$(stat -f %SB -t %Y-%m-%d_%H-%M-%S "$1").${ext}\""
      mv -vn "$1" "${fullDirName}/$(stat -f %SB -t %Y-%m-%d_%H-%M-%S "$1").${ext}"
      ;;
    m*)
      echo "Processing \"$(basename "$1")\"... Can't find timestamp in name!
      Will set file name to \"$(date -r "$1" +"%Y-%m-%d_%H-%M-%S").${ext}\""
      mv -vn "$1" "${fullDirName}/$(date -r "$1" +"%Y-%m-%d_%H-%M-%S").${ext}"
      ;;
    s*) echo "Processing \"$(basename "$1")\"... Can't find timestamp in name! Skipping..." ;;
    *)
      echo "Bad FLAG specified!"
      exit 1
      ;;
    esac
  fi
}

sharearrays

if [[ -z "$1" ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  echo "Usage: $(basename "$0") <directory> FLAG"
  echo "	where FLAG defines how this script treats media files without"
  echo "	valid dates in their names. FLAG can be one of the following:"
  echo "		c - set file name based on its creation date"
  echo "		m - set file name based on its modification date"
  echo "		s - skip these files"
  echo "	FLAG is set to s by default."
  exit 1
fi

if ! [ -d "$1" ]; then
  echo "Please provide a valid directory!"
  exit 1
fi

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

fullDirName="$(
  cd "$(dirname "$1")"
  pwd
)/$(basename "$1")"
echo "Target directory: \"${fullDirName}\""

countImg="$(find "$fullDirName" \( -iname '*.jpg' -or -iname '*.jpeg' -or -iname '*.png' \) | wc -l | tr -d '[:space:]')"
countVid="$(find "$fullDirName" \( -iname '*.mp4' -or -iname '*.mts' -or -iname '*.mov' -or -iname '*.3gp' -or -iname '*.avi' -or -iname '*.m2ts' \) | wc -l | tr -d '[:space:]')"
countInDir=$(($countImg + $countVid))

echo
echo "Regular expressions to extract timestamp from file name:"
for ((i = 0; i < ${#TIMESTAMP_REGEXES[@]}; i++)); do
  echo "${TIMESTAMP_REGEXES[$i]}"
  echo "   └──── example: ${TIMESTAMP_EXAMPLES[$i]} -> ${TIMESTAMP_EXAMPLES_RESOLVED[$i]}"
  echo
done

if [ -n "${2}" ]; then
  echo
  echo "Parsing user-provided FLAG..."
  case "${2}" in
  c*) FLAG=$2 ;;
  m*) FLAG=$2 ;;
  s*) FLAG=$2 ;;
  *) echo "Bad FLAG specified! Defaulting to s (keep old name)" ;;
  esac
fi

case "${FLAG}" in
c*) echo "Will set file name to CREATION DATE if date can't be extracted from filename" ;;
m*) echo "Will set file name to MODIFICATION DATE if date can't be extracted from filename" ;;
s*) echo "Will KEEP OLD file name if date can't be extracted from filename" ;;
*)
  echo "Bad FLAG specified!"
  exit 1
  ;;
esac

# Show a line of dashes
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

message="Are you sure you want to rename ${countInDir} media files? (${countImg} images and ${countVid} videos)"
message="$message in \"${fullDirName}\"? (y or Y to proceed)$(echo $'\n> ')"

read -p "$message" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  export -f sharearrays
  export -f renameFile
  export FLAG
  export fullDirName
  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

  find "${fullDirName}" -type f \
    \( -iname "*.jpg" -or -iname "*.jpeg" -or -iname "*.png" -or -iname "*.mp4" -or -iname "*.mts" -or \
    -iname "*.mov" -or -iname "*.3gp" -or -iname "*.avi" -or -iname "*.m2ts" \) \
    -exec bash -c 'sharearrays; renameFile "$0"' {} \;

  # Show a line of dashes
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
fi
