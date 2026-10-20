#!/usr/bin/env bash

# Print the evaluated value of a NixOS or Home Manager option for a host.
#
# usage: query-option.sh [--names] <host> <option.path>
#   hm.<path>  expands to home-manager.users.<username>.<path>
#   --names    print attribute names instead of the value (to explore sets)
#
# examples:
#   query-option.sh desktop networking.firewall.allowedTCPPorts
#   query-option.sh p14s hm.programs.ghostty.settings.font-size
#   query-option.sh --names desktop hm.programs

set -uo pipefail

names=0
if [[ "${1:-}" == "--names" ]]; then
    names=1
    shift
fi

if (($# != 2)); then
    sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'
    exit 2
fi

host=$1
path=$2

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2> /dev/null) || {
    echo "error: not inside the nixos-config git repository" >&2
    exit 2
}
cd "$root" || exit 2

username=$(sed -n 's/^ *username = "\([^"]*\)";.*/\1/p' flake.nix | head -n 1)
if [[ "$path" == hm.* ]]; then
    path="home-manager.users.${username}.${path#hm.}"
fi

attr=".#nixosConfigurations.${host}.config.${path}"

if ((names == 1)); then
    nix eval --json "$attr" --apply 'v: if builtins.isAttrs v then builtins.attrNames v else v'
else
    if command -v jq > /dev/null; then
        nix eval --json "$attr" | jq .
    else
        nix eval --json "$attr"
    fi
fi
