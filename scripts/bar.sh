#!/bin/bash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/gruvchad

# Update checking function (Arch Linux)
pkg_updates() {
  updates=$(checkupdates 2>/dev/null | wc -l)
  if [[ -z "$updates" ]]; then
    printf "  ^c$green^    Fully Updated"
  else
    printf "  ^c$green^    $updates updates"
  fi
}

battery() {
  get_capacity="$(cat /sys/class/power_supply/BAT0/capacity)"
  printf "^c$blue^   $get_capacity%%"
}

brightness() {
  printf "^c$red^   "
  printf "^c$red^%.0f\n" "$(cat /sys/class/backlight/*/brightness)"
}

volume() {
  vol=$(amixer get Master | grep -o '[0-9]*%' | head -n 1)
  muted=$(amixer get Master | grep -o '\[off\]' | head -n 1)

  if [[ "$muted" == "[off]" ]]; then
    printf "^c$yellow^  Muted"  # Muted glyph
  else
    printf "^c$green^   $vol"  # Larger volume glyph
  fi
}

mem() {
  printf "^c$blue^^b$black^  "
  printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
  case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
    up) printf "^c$black^ ^b$blue^   ^d^%s" " ^c$blue^Connected" ;;
    down) printf "^c$black^ ^b$blue^ 睊 ^d^%s" " ^c$blue^Disconnected" ;;
  esac
}

clock() {
  printf "^c$black^ ^b$darkblue^  "
  printf "^c$black^^b$blue^ $(date '+%H:%M') "
}

# Main loop
while true; do
  updates=$(pkg_updates) # Update every loop now. Less resource intensive than checking every second.
  xsetroot -name "$updates $(battery) $(brightness) $(volume) $(mem) $(wlan) $(clock)"
  sleep 1
done
