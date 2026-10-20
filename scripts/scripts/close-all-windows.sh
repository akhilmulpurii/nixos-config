#!/usr/bin/env bash

hyprctl clients -j | jq -r '.[].address' | xargs -r -I{} hyprctl dispatch closewindow address:{}
