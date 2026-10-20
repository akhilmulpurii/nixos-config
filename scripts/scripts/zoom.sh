#!/usr/bin/env bash

# zoom --in: step cursor zoom up, zoom --reset: back to 1x

if [[ "$1" == "--reset" ]]; then
    hyprctl keyword cursor:zoom_factor 1
else
    hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor -j | jq '.float + 1')"
fi
