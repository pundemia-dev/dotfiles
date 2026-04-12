#!/bin/bash

HISTORY_FILE="/tmp/hypr_colsize_history"
touch "$HISTORY_FILE"

WINDOW=$(hyprctl activewindow -j)
ADDR=$(echo "$WINDOW" | jq -r '.address')

if [ -z "$ADDR" ] || [ "$ADDR" = "null" ]; then
    exit 1
fi

SAVED=$(grep "^$ADDR " "$HISTORY_FILE" | tail -1 | awk '{print $2}')

if [ -n "$SAVED" ]; then
    sed -i "/^$ADDR /d" "$HISTORY_FILE"
    hyprctl dispatch layoutmsg "colresize $SAVED"
else
    MON_W=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .width')
    WIN_W=$(echo "$WINDOW" | jq -r '.size[0]')
    # Округляем до 1 знака — убирает дрейф от gaps
    RATIO=$(awk "BEGIN {printf \"%.1f\", $WIN_W / $MON_W}")

    IS_ALREADY_MAX=$(awk "BEGIN {print ($RATIO >= 0.9) ? 1 : 0}")
    if [ "$IS_ALREADY_MAX" -eq 1 ]; then
        RATIO="0.5"
    fi

    sed -i "/^$ADDR /d" "$HISTORY_FILE"
    printf '%s %s\n' "$ADDR" "$RATIO" >> "$HISTORY_FILE"
    hyprctl dispatch layoutmsg "colresize 1.0"
fi
