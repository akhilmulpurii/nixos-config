#!/usr/bin/env bash

# Defaults must match modules/home/hyprland/settings.nix
gaps_in=6
gaps_out=12
border=2

current=$(hyprctl getoption general:gaps_out -j | jq -r '.custom' | awk '{print $1}')

if [[ "$current" == "0" ]]; then
    hyprctl --batch "keyword general:gaps_in $gaps_in; keyword general:gaps_out $gaps_out; keyword general:border_size $border"
else
    hyprctl --batch "keyword general:gaps_in 0; keyword general:gaps_out 0; keyword general:border_size 0"
fi
