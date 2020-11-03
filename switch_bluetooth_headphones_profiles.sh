#!/bin/bash

CARD_NAME=$(pacmd list-sinks | grep card | grep bluez | cut -d "<" -f2 | cut -d ">" -f1)
if [[ ${#CARD_NAME} -lt 1 ]]
then
    notify-send 'Bluetooth headphone profile switcher' 'I could not find any bluetooth headphones...' --icon=face-sad -t 1
else
    CURRENT_SINK=$(pacmd list-sinks | grep bluez_sink | cut -d "<" -f2 | cut -d ">" -f1)
    if [[ $CURRENT_SINK == *"a2dp_sink"* ]]; then
        pactl set-card-profile ${CARD_NAME} headset_head_unit
        notify-send 'Bluetooth headphone profile switcher' 'Switched to headset mode!' --icon=audio-input-microphone -t 1
    else
        pactl set-card-profile ${CARD_NAME} a2dp_sink
        notify-send 'Bluetooth headphone profile switcher' 'Switched to listening mode!' --icon=media-playback-start -t 1
    fi
    pacmd set-default-sink $(pacmd list-sinks | grep bluez_sink | cut -d "<" -f2 | cut -d ">" -f1)
fi