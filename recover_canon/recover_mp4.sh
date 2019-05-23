#!/usr/bin/env bash

# Settings

WINEPREFIX_32=~/win32
WINEPREFIX_64=~/win64 
wine64bit=true
recoverMp4Exec=binaries/recover_mp4_1.92/recover_mp4_x64.exe
corruptExt=DAT

# --canon works on some versions, if not try --ext
device='--canon'

# /Settings


# Program code - you shouldn't need to edit anything below this line.

if ! [ -x "$(command -v ffmpeg)" ]; then
	echo 'This script requires ffmpeg to be installed and in PATH'
	exit 1
fi
if ! [ -x "$(command -v wine)" ]; then
	echo 'This script requires wine to be installed and in PATH'
	exit 1
fi

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
if [ ! -f ${scriptDir}/${recoverMp4Exec} ]; then
	echo "recover_mp4 executable not found under ${recoverMp4Exec}! Please supply it."
	exit 1
fi

unameOut="$(uname -s)"
case "${unameOut}" in
	Linux*)     machine=Linux;;
	Darwin*)    machine=MacOS;;
	CYGWIN*)    machine=Cygwin;;
	MINGW*)     machine=MinGw;;
	*)          machine="UNKNOWN:${unameOut}"
esac
echo "Running this script on ${machine} platform."

echo
echo '1) Looking for a good file in `good` folder...'
if [ ! -d ${scriptDir}/good ]; then
	echo "Folder with good file does not exist! Creating..."
	mkdir ${scriptDir}/good
	echo 'Please move your good video file to `good` folder and launch this script again!'
	exit 1
fi
goodFile=$(ls ${scriptDir}/good | head -n1)
if [ -z $goodFile ]; then
	echo 'Please move your good video file to `good` folder and launch this script again!'
	exit 1
fi
echo "Found $goodFile"

echo
echo '2) Looking for damaged files in `dat_files` folder (.DAT extension, case-insensitive)'
corruptDir=${scriptDir}/dat_files
countInDir="`find ${corruptDir} -iname "*.${corruptExt}" | wc -l | tr -d '[:space:]'`"
if [[ $countInDir = 0 ]]
then
	echo "Could not find any damaged files under ${corruptDir}"
	exit 1
fi

if [ ! -d ${scriptDir}/recovered ]; then
	echo "Folder for recovered videos does not exist! Creating..."
	mkdir ${scriptDir}/recovered
fi

read -p "Recover ${countInDir} videos in `basename ${corruptDir}` using `basename ${goodFile}` ? (y or Y to proceed)`echo $'\n> '`" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	cd ${scriptDir}
	echo "--------------------------------------------------------------------------------"
	echo "|"
	echo "| Step 1 - analyzing `basename ${goodFile}` "
	echo "|"
	echo "--------------------------------------------------------------------------------"
    
    if [ ${wine64bit} = "true" ]
	then
    		WINEPREFIX=~/win64 WINEARCH=win64 wine ${recoverMp4Exec} good/${goodFile} --analyze
	else
    		WINEPREFIX=~/win32 WINEARCH=win32 wine ${recoverMp4Exec} good/${goodFile} --analyze
	fi

	echo
	echo "--------------------------------------------------------------------------------"
	echo "|"
    echo "| Step 2 - recover every corrupt file in ${corruptDir}"
	echo "|"
	echo "--------------------------------------------------------------------------------"
	find ${corruptDir} -type f -iname "*.${corruptExt}" -print0 | while IFS= read -r -d $'\0' line; do 
		filename=$(basename -- "$line")
	    echo
	    echo "-------------------------"
	    echo "Processing ${filename}..."
	    echo "-------------------------"
	    echo
		withoutextension="${filename%.*}"
		if [ ${wine64bit} = true ]
		then
	    	WINEPREFIX=~/win64 WINEARCH=win64 wine ${recoverMp4Exec} ${corruptDir}/${filename} ${withoutextension}.h264 ${withoutextension}.aac ${device}
		else
	    	WINEPREFIX=~/win32 WINEARCH=win32 wine ${recoverMp4Exec} ${corruptDir}/${filename} ${withoutextension}.h264 ${withoutextension}.aac ${device}
		fi
      
		# Re-encoding to MP3 seems to heal the gaps in resulting audio file.
		# Opening .aac file in Audacity and just saving it has the same effect.
		ffmpeg -y -i ${withoutextension}.aac -c:a mp3 ${withoutextension}.mp3
		ffmpeg -y -r 30000/1001 -i ${withoutextension}.h264 -i ${withoutextension}.mp3 -c:v copy -c:a copy recovered/${withoutextension}_recovered.mp4
	done

	echo
	echo "--------------------------------------------------------------------------------"
	echo "|"
    echo "| Step 3 - cleaning up"
	echo "|"
	echo "--------------------------------------------------------------------------------"
	rm audio.hdr video.hdr
	find ${corruptDir} -type f -iname "*.${corruptExt}" -print0 | while IFS= read -r -d $'\0' line; do
		filename=$(basename -- "$line")
		withoutextension="${filename%.*}"
		rm ${withoutextension}.h264 ${withoutextension}.mp3 ${withoutextension}.aac
		echo "Removed ${withoutextension}.h264 ${withoutextension}.mp3 ${withoutextension}.aac"
	done

	echo
	echo "--------------------------------------------------------------------------------"
	echo "|"
	echo "| Ready! You may find the recovered files in ${scriptDir}/recovered"
	echo "|"
	echo "--------------------------------------------------------------------------------"
else
	exit 0
fi
