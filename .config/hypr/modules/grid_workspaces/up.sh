#!/bin/bash

id=$(hyprctl activeworkspace | awk -F'[()]' '/workspace ID/ {print $2}')

if (( id - 3 > 0)); then
    hyprctl keyword animation "workspaces, 1, 2.5, myBezier, slidefadevert, 20%"
    hyprctl dispatch workspace -3
fi
