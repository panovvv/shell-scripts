@echo off

REM Settings
SET ffmpegPath=binaries\ffmpeg-20190225-f948082-win64-static
SET recoverMp4Exec=binaries\recover_mp4_1.92\recover_mp4_x64.exe
SET corruptExt=DAT

REM --canon works on some versions, if not try --ext
SET device=--ext
REM End of settings


REM Program code - you shouldn't need to edit anything below this line.
title Restore Canon DAT files

IF NOT EXIST %ffmpegPath%\ (
  ECHO Please download ffmpeg, place it into binaries directory and launch this script again!
  pause
)
IF NOT EXIST %ffmpegPath%\bin\ffmpeg.exe (
  ECHO Please download ffmpeg, place it into binaries directory and launch this script again!
  pause
)
IF NOT EXIST %recoverMp4Exec% (
  ECHO recover_mp4 executable not found under %recoverMp4Exec%! Please supply it.
  pause
)

echo. 
echo 1^) Looking for a good file in `good` folder...
IF EXIST "good\" (
  ECHO Folder with good file exists...
) ELSE (
  ECHO Folder with good file does not exist! Creating...
  mkdir good
  ECHO Please move your good video file to `good` folder and launch this script again!
  pause
  exit 1
)
SET goodFilePath=
for %%f in (good\*) do (
    echo Found %%~f
    SET goodFilePath=%%~f
)
if defined goodFilePath (
    echo Using good file in %goodFilePath%
)else (
  ECHO Please move your good video file to `good` folder and launch this script again!
  pause
  exit 1
)

echo. 
echo 2^) Looking for damaged files in `dat_files` folder (.%corruptExt% extension, case-insensitive)
IF EXIST "dat_files\" (
  ECHO Folder with incomplete videos exists...
) ELSE (
  ECHO Folder for incomplete videos does not exist! Creating...
  mkdir dat_files
  ECHO "Please move your damaged video files (.%corruptExt%) to `dat_files` folder and launch this script again!"
  pause
  exit 1
)
for /f %%a in ('dir /a-d dat_files\*.%corruptExt% ^| find "File(s)"') do set count=%%a
IF %count% GTR 0 (
  echo. 
  echo.
  echo 3^) Restoring %count% files from `dat_files` folder using the file %goodFilePath%. Proceed?
  pause
) ELSE (
  ECHO "Please move your damaged video files (.%corruptExt%) to `dat_files` folder and launch this script again!"
  pause
  exit 1
)

echo. 
echo.
%recoverMp4Exec% %goodFilePath% --analyze
IF NOT EXIST "recovered\" (
  mkdir recovered
)

for %%f in (dat_files\*.dat) do (
    echo Restoring %%~nxf
    %recoverMp4Exec% dat_files\%%~nxf  %%~nf.h264 %%~nf.aac %device%
    
    REM Re-encoding to MP3 seems to heal the gaps in resulting audio file.
    REM Opening .aac file in Audacity and just saving it has the same effect.
    %ffmpegPath%\bin\ffmpeg.exe -y -i %%~nf.aac -c:a mp3 %%~nf.mp3
    %ffmpegPath%\bin\ffmpeg.exe -y -r 30000/1001 -i %%~nf.h264 -i %%~nf.mp3 -bsf:a aac_adtstoasc -c:v copy -c:a aac recovered\%%~nf.mp4
    del %%~nf.h264 %%~nf.aac %%~nf.mp3
)
del audio.hdr video.hdr

echo. 
echo.
echo Done! All videos are in `recovered` folder. If they still appear jittery, use VLC to play them.