#!/bin/sh
# Noctalia wallpaperChange hook: run pywal on the new wallpaper and refresh
# noctalia's colors. Noctalia fires this once per monitor, so identical calls
# within a few seconds are deduplicated.

wallpaper="$1"
[ -f "$wallpaper" ] || exit 0

state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/noctalia"
mkdir -p "$state_dir"
state_file="$state_dir/last-wal-wallpaper"

exec 9>"$state_file.lock"
flock 9

if [ -f "$state_file" ] && [ "$(cat "$state_file")" = "$wallpaper" ]; then
    now=$(date +%s)
    mtime=$(stat -c %Y "$state_file")
    [ $((now - mtime)) -lt 5 ] && exit 0
fi
printf '%s' "$wallpaper" >"$state_file"

wal -n -i "$wallpaper"
cp "${XDG_CACHE_HOME:-$HOME/.cache}/wal/colors-noctalia.json" "$HOME/.config/noctalia/colors.json"
