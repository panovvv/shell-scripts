DISCLAIMER:
I wrote this script as a means to restore unfinished recordings from my Canon SX280 HS camera.
It had a really bad battery life when recording videos, and oftentimes just switched off
mid-recording, leaving only an un-finalized MVI_***.DAT file behind.
This is the only way I found that works and actually creates good videos out of those.
IF IT WORKS FOR YOU - I'M GLAD. IF IT DOESN'T - I DONT TAKE ANY RESPONSIBILITY FOR ANY RESULTS THIS SCRIPT MIGHT OR MIGHT NOT GIVE YOU
recover.bat is distributed under MIT license, see full text here: https://opensource.org/licenses/MIT



How to restore any number of corrupt video files with DAT extension:
1) You need ONE good video file from the same camera. Copy it into folder named "good"

2) All the corrupt .DAT files go to "dat_files" folder.

3) "binaries" directory must contain recover_mp4_x86.exe (or recover_mp4_x64.exe if your operating system/Wine distribution is 64-bit) and ffmpeg (Windows only).

3a) Getting ffmpeg
Windows:
ffmpeg can easily be retrieved here:
https://ffmpeg.zeranoe.com/builds/

Linux:
Install ffmpeg from your package manager:
sudo apt install ffmpeg
or
sudo pacman -S ffmpeg

MacOSX:
Open your Terminal app and install ffmpeg by typing
brew install ffmpeg
If you don't have Brew yet, follow instructions here https://brew.sh/

3b) Gerring recover_mp4
recover_mp4 is harder to find (I assume it was discontinued) but try here
https://web.archive.org/web/20160529083800/http://slydiman.me/download/recover_mp4_to_h264.zip
or here https://www.videohelp.com/software/recover-mp4-to-h264

4) Open the recover_mp4.sh/recover_mp4.bat in text editor and make sure variables at the top
are pointing at the right paths/files:
ffmpegPath, recoverMp4Exec, corruptExt
(Unix only) wine64bit, WINEPREFIX_64, WINEPREFIX_32. Read about WINEPREFIX here: https://wiki.archlinux.org/index.php/wine

5) Launch the script that restores the video files.
Windows
Double-click recover_mp4.bat.

Linux/MacOSX
Execute the following:
chmod +x recover_mp4.sh
./recover_mp4.sh

6) The recovered videos are in the "recovered" folder


Here's an example directory/file layout you might have before launching the script:

│   README.txt
│   recover.bat
├───binaries/
│   ├───recover_mp4_1.92
│   │   ├─recover_mp4_x86.exe
│   │   └─recover_mp4_x64.exe
│   └───ffmpeg-20190225-f948082-win64-static/  <- Windows only
│       │   ...
│       ├───bin/
│       │       ffmpeg.exe
│       │       ...
│       └───...
├───dat_files/
│       2018-11-18_10-41-46.dat
│       2018-11-18_19-17-12.dat
├───good/
│       thisfilecanhaveanyname.mp4
└───recovered/


Common failures/known issues:

* wine: Bad EXE format for Z:\Users\name\...\recover_mp4_x64.exe.
Your Wine installation is set up as 32 bit system. Check the wine64bit flag at top of the script.
* TODO