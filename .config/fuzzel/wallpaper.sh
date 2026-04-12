#!/usr/bin/env bash
# wallpaper-picker.sh — fuzzel + matugen wallpaper switcher

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
STATE_FILE="$HOME/.local/state/wallpaper-picker/state.conf"

# ── Defaults ─────────────────────────────────────────────────────────────────

SCHEME="scheme-neutral"
MODE="dark"
LAST_WALLPAPER=""

# ── State ─────────────────────────────────────────────────────────────────────

load_state() {
  [[ -f "$STATE_FILE" ]] && source "$STATE_FILE"
}

save_state() {
  mkdir -p "$(dirname "$STATE_FILE")"
  cat >"$STATE_FILE" <<EOF
SCHEME="$SCHEME"
MODE="$MODE"
LAST_WALLPAPER="$LAST_WALLPAPER"
EOF
}

# ── Helpers ───────────────────────────────────────────────────────────────────

fuzzel_menu() {
  local prompt="$1"
  shift
  printf '%s\n' "$@" | fuzzel --dmenu --prompt="$prompt " --width=44
}

get_wallpapers() {
  if [[ "$1" == "hidden" ]]; then
    find "$WALLPAPER_DIR" -maxdepth 1 -type f -name '.*'
  else
    find "$WALLPAPER_DIR" -maxdepth 1 -type f ! -name '.*'
  fi
}

apply() {
  local img="$1"
  [[ -z "$img" || ! -f "$img" ]] && return
  LAST_WALLPAPER="$img"
  save_state
  notify-send -t 2000 "🖼 Обои" "$(basename "$img")" 2>/dev/null
  awww img "$img" -t=any --transition-step=30 --transition-duration=2
  pkill -x matugen 2>/dev/null
  matugen --type "$SCHEME" --mode "$MODE" --source-color-index 0 image "$img" &
}

# ── Sub-menus ─────────────────────────────────────────────────────────────────

pick_scheme() {
  local schemes=(
    "scheme-content"
    "scheme-expressive"
    "scheme-fidelity"
    "scheme-fruit-salad"
    "scheme-monochrome"
    "scheme-neutral"
    "scheme-rainbow"
    "scheme-tonal-spot"
  )
  local picked
  picked=$(fuzzel_menu "Схема >" "${schemes[@]}")
  [[ -n "$picked" ]] && SCHEME="$picked" && save_state
}

pick_mode() {
  local picked
  picked=$(fuzzel_menu "Режим >" "dark" "light")
  [[ -n "$picked" ]] && MODE="$picked" && save_state
}

search_wallpaper() {
  local label="$1"
  local files=()
  while IFS= read -r f; do
    files+=("$f")
  done < <(get_wallpapers "$label" | xargs ls -t 2>/dev/null)
  [[ ${#files[@]} -eq 0 ]] && return
  local picked
  picked=$(for f in "${files[@]}"; do
    printf '%s\0icon\x1f%s\n' "$(basename "$f")" "$f"
  done | fuzzel --dmenu --prompt="Поиск > " --width=60)
  [[ -z "$picked" ]] && return
  for f in "${files[@]}"; do
    if [[ "$(basename "$f")" == "$picked" ]]; then
      apply "$f"
      return
    fi
  done
}
# search_wallpaper() {
#     local label="$1"
#     local files=()
#
#     while IFS= read -r f; do
#         files+=( "$f" )
#     done < <(get_wallpapers "$label" | sort)
#
#     [[ ${#files[@]} -eq 0 ]] && return
#
#     local picked
#     picked=$(for f in "${files[@]}"; do
#         printf '%s\0icon\x1f%s\n' "$(basename "$f")" "$f"
#     done | fuzzel --dmenu --prompt="Поиск > " --width=60)
#
#     [[ -z "$picked" ]] && return
#
#     for f in "${files[@]}"; do
#         if [[ "$(basename "$f")" == "$picked" ]]; then
#             apply "$f"
#             return
#         fi
#     done
# }

random_wallpaper() {
  local img
  img=$(get_wallpapers "$1" | shuf -n 1)
  [[ -n "$img" ]] && apply "$img" ||
    notify-send -t 2000 "⚠ Обои" "Файлы не найдены в $WALLPAPER_DIR"
}

# ── Main loop ─────────────────────────────────────────────────────────────────

load_state

while true; do
  choice=$(fuzzel_menu "Обои >" \
    "🎲  rand wall" \
    "🎲  rand .wall" \
    "🔍  find wall" \
    "🔍  find .wall" \
    "🎨  scheme:  $SCHEME" \
    "🌙  mode:  $MODE" \
    "❌  exit")

  case "$choice" in
  "🎲  rand wall") random_wallpaper "normal" ;;
  "🎲  rand .wall") random_wallpaper "hidden" ;;
  "🔍  find wall") search_wallpaper "normal" ;;
  "🔍  find .wall") search_wallpaper "hidden" ;;
  "🎨  scheme:  $SCHEME") pick_scheme ;;
  "🌙  mode:  $MODE") pick_mode ;;
  "❌  exit" | "") break ;;
  esac
done
