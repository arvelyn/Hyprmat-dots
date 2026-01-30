#!/bin/bash

# Rofi theme (optional)
THEME="$HOME/.config/rofi/config.rasi"

options="⏻ Shutdown\n🔄 Reboot\n💤 Suspend\n🔒 Lock\n🚪 Logout\n🌙 Hibernate"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme "$THEME")

case "$chosen" in
    "⏻ Shutdown")
        systemctl poweroff
        ;;
    "🔄 Reboot")
        systemctl reboot
        ;;
    "💤 Suspend")
        systemctl suspend
        ;;
    "🔒 Lock")
        # change this to your locker (swaylock, hyprlock, i3lock, etc.)
       # hyprlock || swaylock || i3lock
        ;;
    "🚪 Logout")
        hyprctl dispatch exit
        ;;
    "🌙 Hibernate")
        systemctl hibernate
        ;;
esac
