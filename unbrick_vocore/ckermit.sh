#!/usr/bin/ckermit +
set port \%1
set speed \%2
set carrier-watch off
set flow-control none
set prefixing all

echo {Sending...}
PAUSE 1
OUTPUT loadb;erase linux;cp.linux \%3\{13}

send ./vocore.bin

quit
