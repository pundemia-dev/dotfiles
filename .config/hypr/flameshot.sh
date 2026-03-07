#!/bin/bash

if command -v hyprctl &>/dev/null; then
  monitor_count=$(hyprctl monitors -j | jq 'length')
  
  if [ "$monitor_count" -eq 1 ]; then
    current_y=$(hyprctl monitors -j | jq -r '.[0].y')
    if [ "$current_y" -ne 0 ]; then
      hyprctl keyword monitor eDP-1,1920x1080@60,0x0,1
      qs -c pShell kill
      sleep 1.0
      qs -c pShell -n
      sleep 6.0
    fi
  elif [ "$monitor_count" -gt 1 ]; then
    edp_y=$(hyprctl monitors -j | jq -r '.[] | select(.name=="eDP-1") | .y')
    if [ "$edp_y" -eq 0 ]; then
      hyprctl keyword monitor eDP-1,1920x1080@60,0x1080,1
      qs -c pShell kill
      sleep 1.0
      qs -c pShell -n
      sleep 6.0
    fi
  fi

  read -r monitor move_x move_y width height < <(
    hyprctl monitors -j | jq -r '
      map(. + {
        eff_w: (if .transform % 2 != 0 then .height else .width end),
        eff_h: (if .transform % 2 != 0 then .width else .height end)
      })
      | (map(.x) | min) as $min_x
      | (map(.y) | min) as $min_y
      | (map(.x + .eff_w) | max) as $max_x
      | (map(.y + .eff_h) | max) as $max_y
      | map(. + { norm_x: (.x - $min_x), norm_y: (.y - $min_y) })
      | (map(select(.norm_x == 0 and .norm_y == 0)) | first // first) as $anchor
      | ($max_x - $min_x) as $width
      | ($max_y - $min_y) as $height
      | "\($anchor.name) \(-$anchor.norm_x) \(-$anchor.norm_y) \($width) \($height)"
    '
  )

  hyprctl --batch "
    keyword windowrulev2 monitor $monitor,initialTitle:^(flameshot);
    keyword windowrulev2 move $move_x $move_y,initialTitle:^(flameshot);
    keyword windowrulev2 size $width $height,initialTitle:^(flameshot);
    keyword windowrulev2 pin,initialTitle:^(flameshot);
    keyword windowrulev2 float,initialTitle:^(flameshot);
    keyword windowrulev2 rounding 0,initialTitle:^(flameshot);
    keyword windowrulev2 border_size 0,initialTitle:^(flameshot);
    keyword windowrulev2 stayfocused,initialTitle:^(flameshot);
    keyword windowrulev2 suppress_event fullscreen,initialTitle:^(flameshot)"
fi

flameshot "$@"
