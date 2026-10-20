#!/usr/bin/env bash

# List every Hyprland bind (bind, binde, bindl, bindel, bindr, bindm, ...) from
# the evaluated config, with $mod expanded. Use it to check for conflicts.
#
# usage: keybinds.sh [host] [filter]
#   host    nixosConfiguration (default: this machine's hostname, else desktop)
#   filter  case-insensitive; 'MODS, KEY' (contains a comma) matches that exact
#           combo, e.g. 'SUPER SHIFT, D'; anything else is a substring search,
#           e.g. 'screenshot' or 'Print'

set -uo pipefail

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2> /dev/null) || {
    echo "error: not inside the nixos-config git repository" >&2
    exit 2
}
cd "$root" || exit 2

host=${1:-}
filter=${2:-}
if [[ -z "$host" ]]; then
    host=$(hostname)
    [[ -d "hosts/$host" ]] || host=desktop
fi

username=$(sed -n 's/^ *username = "\([^"]*\)";.*/\1/p' flake.nix | head -n 1)

expr='s:
  let
    mod = s."$mod" or "SUPER";
    isBindList = k: builtins.match "bind[a-z]*" k != null && builtins.isList s.${k};
    fmt = k: b: k + " = " + builtins.replaceStrings [ "$mod" ] [ mod ] b;
  in
  builtins.concatStringsSep "\n" (
    builtins.concatLists (map (k: map (fmt k) s.${k}) (builtins.filter isBindList (builtins.attrNames s)))
  )'

binds=$(nix eval --raw \
    ".#nixosConfigurations.${host}.config.home-manager.users.${username}.wayland.windowManager.hyprland.settings" \
    --apply "$expr") || exit 1

if [[ -n "$filter" ]]; then
    pattern=$filter
    [[ "$filter" == *,* ]] && pattern="= ${filter%,},"
    grep -iF -- "$pattern" <<< "$binds" || {
        echo "no bind matches '$filter' on $host (key looks free)"
        exit 0
    }
else
    echo "$binds"
fi
