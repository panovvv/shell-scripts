How to unbrick Vocore v 1.0:

0) Requirements: putty and ckermit binary in $PATH.
1) Connect serial to usb converter to Vocore's serial pins (that's pins 14 and 15) and ground (GND)
2) Don't power up Vocore yet. Launch the unbrick_vocore.sh script.
It should be invoked like this:
    ./unbrick_vocore.sh /dev/ttyUSB0 [57600] [vocore.bin]
    [57600] is the baud rate - optional parameter defaulting to 57600.
    [vocore.bin] is the location of Vocore firmware binary, defaults to vocore.bin in the same folder.
3) Follow the instructions that this script issues. Good luck!
    
Refer to
https://www.shortn0tes.blogspot.com/2015/11/vocore-tutorial-blinking-led-using.html
for more details.
