#!/bin/bash
PIDFILE="/tmp/hold.pid"

if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
    xdotool mouseup 1
    kill $(cat "$PIDFILE")
    rm -f "$PIDFILE"
    notify-send -u low -a Hold "Released"
else
    (
    xdotool mousedown 1
    while true; do
        sleep 1
    done
    ) &
    echo $! > "$PIDFILE"
    notify-send -u low -a Hold "Holding left click"
fi
