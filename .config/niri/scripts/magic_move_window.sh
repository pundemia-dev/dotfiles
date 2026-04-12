#!/usr/bin/env bash
# Mod+Shift+W — move window to/from magic workspace
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri_magic_workspace"

WS_JSON=$(niri msg -j workspaces)
CURRENT=$(printf '%s' "$WS_JSON" | jq -r 'first(.[] | select(.is_active == true))')
CURRENT_NAME=$(printf '%s' "$CURRENT" | jq -r '.name // ""')

if [[ "$CURRENT_NAME" == "magic" ]]; then
    PREV_IDX=$(< "$STATE_FILE")
    niri msg action move-window-to-workspace "$PREV_IDX"
else
    printf '%s' "$CURRENT" | jq -r '.idx' > "$STATE_FILE"
    niri msg action move-window-to-workspace "magic"
fi
