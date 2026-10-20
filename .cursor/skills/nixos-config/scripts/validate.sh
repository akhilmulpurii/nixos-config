#!/usr/bin/env bash

# Validate nixos-config changes without building or switching.
#
# usage: validate.sh [--skip-eval] [host ...]
#   host ...     nixosConfigurations to evaluate (default: all of them)
#   --skip-eval  only run the untracked-file and formatting checks
#
# exit: 0 = all checks passed, 1 = a check failed, 2 = usage / environment error

set -uo pipefail

skip_eval=0
hosts=()
for arg in "$@"; do
    case "$arg" in
        --skip-eval) skip_eval=1 ;;
        -h | --help)
            sed -n '3,9p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) hosts+=("$arg") ;;
    esac
done

root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel 2> /dev/null) || {
    echo "error: not inside the nixos-config git repository" >&2
    exit 2
}
cd "$root" || exit 2

failed=0

# --- 1. untracked files ------------------------------------------------------
echo "==> Untracked files (the flake cannot see these until 'git add')"
untracked=$(git ls-files --others --exclude-standard -- flake.nix modules hosts pkgs scripts wallpapers)
if [[ -n "$untracked" ]]; then
    echo "$untracked" | sed 's/^/  UNTRACKED  /'
    echo "  -> run: git add <files>   (staging is enough)"
    failed=1
else
    echo "  ok"
fi

# --- 2. formatting of changed files ------------------------------------------
changed=$(
    {
        git diff --name-only --diff-filter=d HEAD 2> /dev/null
        echo "$untracked"
    } | sort -u | sed '/^$/d'
)

# Same exclusions as treefmt.toml, plus generated hardware configs.
is_fmt_excluded() {
    case "$1" in
        */packages/* | modules/home/default.nix | */hardware-configuration.nix | .cursor/*) return 0 ;;
    esac
    return 1
}

echo "==> Formatting of changed files"
fmt_checked=0
while IFS= read -r f; do
    [[ -z "$f" || ! -f "$f" ]] && continue
    is_fmt_excluded "$f" && continue
    case "$f" in
        *.nix)
            fmt_checked=1
            if ! nixfmt --check "$f" > /dev/null 2>&1; then
                echo "  NOT FORMATTED  $f   -> nixfmt $f"
                failed=1
            fi
            ;;
        *.sh)
            fmt_checked=1
            if [[ -n "$(shfmt -l -ci -sr -i 4 "$f" 2> /dev/null)" ]]; then
                echo "  NOT FORMATTED  $f   -> shfmt -w -ci -sr -i 4 $f"
                failed=1
            fi
            ;;
    esac
done <<< "$changed"
((fmt_checked == 0)) && echo "  no changed .nix/.sh files"
((fmt_checked == 1 && failed == 0)) && echo "  ok"

# --- 3. evaluation -----------------------------------------------------------
if ((skip_eval == 0)); then
    if ((${#hosts[@]} == 0)); then
        read -r -a hosts <<< "$(nix eval --raw .#nixosConfigurations \
            --apply 'c: builtins.concatStringsSep " " (builtins.attrNames c)' 2> /dev/null)"
    fi
    if ((${#hosts[@]} == 0)); then
        echo "error: could not list nixosConfigurations (run: nix eval .#nixosConfigurations --apply builtins.attrNames)" >&2
        exit 1
    fi

    err=$(mktemp)
    trap 'rm -f "$err"' EXIT

    for host in "${hosts[@]}"; do
        echo "==> Evaluating $host"
        if drv=$(nix eval --raw ".#nixosConfigurations.${host}.config.system.build.toplevel.drvPath" 2> "$err"); then
            echo "  ok  $drv"
            grep -i 'evaluation warning' "$err" | sort -u | sed 's/^/  warning: /;s/evaluation warning: //'
        else
            failed=1
            echo "  FAILED"
            grep -v -i 'Git tree .* is dirty' "$err" | tail -n 40 | sed 's/^/  | /'
        fi
    done
fi

echo
if ((failed == 0)); then
    echo "RESULT: PASS"
else
    echo "RESULT: FAIL"
fi
exit "$failed"
