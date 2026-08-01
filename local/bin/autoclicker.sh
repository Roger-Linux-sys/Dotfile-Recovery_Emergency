#!/bin/bash
PIDFILE="/tmp/autoclicker.pid"

if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    ydotool mouseup 0xC0
    kill $(cat "$PIDFILE")
    rm -f "$PIDFILE"
    notify-send -u low -a Autoclicker "Released"
else
    (
    ydotool mousedown 0xC0
    while true; do
        sleep 1
    done
    ) &
    echo $! > "$PIDFILE"
    notify-send -u low -a Autoclicker "Holding (toggle off to release)"
fi
