How to unbrick Vocore v 1.0:

1) Connect serial to usb converter to Vocore's serial pins (don't forget
common GND!).  That's pins 14 and 15.
2) Don't power up Vocore yet. Launch the unbrick_ckermit_uart.sh script.
It should be invoked like this:
    ./unbrick_vocore.sh /dev/ttyUSB0 [57600]
[57600] is the baud rate - optional parameter defaulting to 57600.
3) Follow the instructions. Good luck!
    
Refer to
https://www.shortn0tes.com/2015/11/vocore-tutorial-blinking-led-using.html
for more details.
