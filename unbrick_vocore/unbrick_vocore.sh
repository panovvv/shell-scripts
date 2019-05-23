#!/usr/bin/bash 

SERIALPORT=$1
if [ -z "$1" ]
  then
    echo "No serial port supplied! This script should be invoked like this:"
    echo "./unbrick_vocore.sh /dev/ttyUSB0 [57600] [vocore.bin]"
    echo "[57600] is the baud rate - optional parameter defaulting to 57600"
    echo "[vocore.bin] is the name of your firmware - optional parameter too."
    exit 1
  else
    printf "Connecting to serial device %s\n" "$SERIALPORT"
fi

BAUDRATE=$2
if [ -z "$2" ]
  then
    echo "Baud rate not supplied, using 57600 as default."
    BAUDRATE=57600
  else
    printf "Baud rate is  %s\n" "$BAUDRATE"
fi
putty -serial -sercfg $BAUDRATE,8,n,1,N $SERIALPORT &

FILENAME=$3
if [ -z "$3" ]
  then
    echo "Firmware file name not supplied, using vocore.bin as default."
  else
    printf "Firmware file name is  %s\n" "$FILENAME"
fi
FILESIZE=$(printf "%x\n" `stat -c%s "$FILENAME"`)
printf "Firmware file size is  %s\n" "$FILESIZE"

read  -n 1 -p "Power up your Vocore board after putty window's popped up.
You should see bootloader saying \"Press X to console\" - do it,
then switch to this console and press any key here."

echo "Starting firmware upload process with ckermit..."
sudo ./ckermit.sh $SERIALPORT $BAUDRATE $FILESIZE

echo "When the uploading is finished, you may type 'reset' in putty window."
echo "'cp.linux' invocation might report wrong file size. In this case,
 type 'tftpboot' then Ctrl + C out of it immediately and call cp.linux
 [hex size] again, this should get rid of the error about wrong file size."
