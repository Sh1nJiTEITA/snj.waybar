#!/bin/bash

STATE_FILE="/tmp/waybar_clock_state"

if [ ! -f "$STATE_FILE" ]; then
    echo "default" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")

if [ "$CURRENT_STATE" == "default" ]; then
    echo "active" > "$STATE_FILE"
else
    echo "default" > "$STATE_FILE"
fi

pkill -USR1 waybar
