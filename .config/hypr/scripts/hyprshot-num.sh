#!/bin/bash

DIR="$HOME/code/uust/lvl3/spit/lab2/assets"
mkdir -p "$DIR"

i=1
while [ -f "$DIR/$i.png" ]; do
  ((i++))
done

hyprshot -m region -o "$DIR" -f "$i.png"
