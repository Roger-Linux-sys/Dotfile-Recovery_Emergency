#!/bin/bash
PIDFILE="/tmp/autoclicker.pid"

if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    kill $(cat "$PIDFILE")
    rm -f "$PIDFILE"
    notify-send -u low -a Autoclicker "Stopped"
else
    (
    while true; do
        ydotool click 0xC0
        sleep 0.02
    done
    ) &
    echo $! > "$PIDFILE"
    notify-send -u low -a Autoclicker "Started (50 CPS)"
fi
