#!/usr/bin/env bash

# Cycle Hyprland layouts: dwindle -> scrolling -> master (--reverse to go back)

layouts=(dwindle scrolling master)
current=$(hyprctl getoption general:layout -j | jq -r '.str')

index=0
for i in "${!layouts[@]}"; do
    if [[ "${layouts[$i]}" == "$current" ]]; then
        index=$i
    fi
done

if [[ "$1" == "--reverse" ]]; then
    next=$(( (index - 1 + ${#layouts[@]}) % ${#layouts[@]} ))
else
    next=$(( (index + 1) % ${#layouts[@]} ))
fi

hyprctl keyword general:layout "${layouts[$next]}"
notify-send -t 1500 "Layout" "${layouts[$next]}"
