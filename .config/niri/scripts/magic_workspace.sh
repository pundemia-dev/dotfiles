#!/usr/bin/env bash
CURRENT_NAME=$(niri msg -j workspaces | jq -r 'first(.[] | select(.is_active == true) | .name // "")')

if [[ "$CURRENT_NAME" == "magic" ]]; then
    niri msg action focus-workspace-previous
else
    niri msg action focus-workspace "magic"
fi
