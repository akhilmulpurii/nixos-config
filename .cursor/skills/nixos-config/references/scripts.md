# Helper scripts (`scripts/scripts/*.sh`)

## How packaging works

`scripts/scripts.nix` (imported by `modules/home/default.nix`) reads `scripts/scripts/`, keeps regular files that end in `.sh`, and wraps each one with `pkgs.writeScriptBin "<name without .sh>" (readFile file)`. The results go into `home.packages`.

Consequences:
- Every `foo.sh` becomes a `foo` command on PATH after a rebuild. No list needs updating, but the file must be `git add`-ed.
- The file is copied verbatim, so **the shebang matters** (`#!/usr/bin/env bash` or `zsh`). Its executable bit in git is irrelevant.
- **Runtime dependencies are not declared.** Scripts rely on tools installed elsewhere in the profile. If a script needs a new tool, add it to `modules/home/packages/*.nix` (or the module that owns that domain).
- Scripts call each other by name (for example `random-wallpaper` calls `wall-change`).
- Formatting: `shfmt -w -ci -sr -i 4 <file>` (4-space indent, indented case, space after redirects).

For a script that needs pinned dependencies, write it as `pkgs.writeShellApplication { name; runtimeInputs; text; }` in a module instead. That is not the current pattern, but it is the right choice for anything non-trivial.

## Inventory

| Command | Purpose | Called from | Depends on |
|---|---|---|---|
| `ascii` | Print a colored ASCII table (zsh) | terminal | tput |
| `compress <dir>` | `tar -czf <dir>.tar.gz` | terminal | tar |
| `extract <file>` | `tar -xzf` the first argument | terminal | tar |
| `init-wallpaper` | Start `awww-daemon` if needed and set `~/Pictures/wallpapers/wallpaper` | exec-once, monitor-watcher | awww |
| `maxfetch` | Minimal fetch (user, distro, kernel, WM, uptime, store paths) | terminal | nix-store, tput |
| `monitor-watcher` | Listens on the Hyprland socket2; disables eDP-1 while HDMI/DP is connected; restarts awww, Waybar and swayosd | exec-once (laptop and p14s) | hyprctl, socat |
| `nh-notify <cmd...>` | Run a command, time it, and send a notification when it finishes if you switched away (on failure the notification has a "focus" action) | `nfs`, `nft`, `nfu`, `nc` aliases | hyprctl, jq, notify-send |
| `ocr` | grimblast region capture, tesseract, result to the clipboard | `$mod CTRL O` | grimblast, tesseract, wl-copy |
| `power-menu` | Rofi menu: shutdown, reboot, lock (swaylock), suspend (hyprlock + suspend). The confirm step is stubbed to always answer yes | `$mod SHIFT Escape`, Waybar power button | rofi, `~/.config/rofi/powermenu-theme.rasi` |
| `power-profile-menu` | Rofi menu for power-saver, balanced, performance | `$mod P` | powerprofilesctl (power-profiles-daemon is only enabled on laptop and p14s) |
| `random-wallpaper` | Random wallpaper from `others/` that differs from the current one | Waybar launcher click | wall-change |
| `runbg <cmd>` | Run a command detached from the terminal | toggle-waybar | which |
| `screenshot --copy\|--save\|--swappy` | grimblast region capture to the clipboard, to `~/Pictures/Screenshots/Screenshot_<date>.png`, or into swappy | Print keys | grimblast, swappy |
| `show-keybinds` | Rofi list of `bind=` lines from `~/.config/hypr/hyprland.conf` | `$mod F1` | rofi |
| `toggle-blur` | Toggle `decoration:blur:enabled` | not bound | hyprctl |
| `toggle-display` | Toggle eDP-1 | `$mod XF86Display` | hyprctl |
| `toggle-float` | Float, resize to 1111x700, center | `$mod Space` | hyprctl |
| `toggle-mic` | Mute the mic through swayosd and sync the mic-mute LED | `XF86AudioMicMute` | swayosd-client, wpctl, brightnessctl (laptop and p14s only) |
| `toggle-oppacity` | Switch window opacity between 0.9 and 1.0 (the misspelling is the command name) | `$mod T` | hyprctl |
| `toggle-rofi <cmd>` | Kill rofi if it's running, otherwise `eval` the command | `$mod D`, `$mod V` | rofi |
| `toggle-waybar` | Kill or start Waybar | `$mod SHIFT B` | runbg |
| `vm-start` | Go to workspace 6, `virsh start win10`, open virt-viewer fullscreen (zsh) | bind commented out | libvirt, virt-viewer |
| `wall-change <file>` | `awww img` with a random transition | wallpaper scripts | awww |
| `wallpaper-picker` | Rofi list of `~/Pictures/wallpapers/others`, then update the symlink and call wall-change | `$mod W` | rofi, wall-change |

## Known script issues

- `toggle-mic.sh` starts with `#/usr/bin/env bash` (the `!` is missing). It only works because Hyprland's `exec` goes through `sh -c`, which falls back to running the file as a shell script. Fix it to `#!/usr/bin/env bash`.
- `extract.sh` only handles `.tar.gz` and stops after the first argument; `compress.sh` doesn't quote its argument.
- `power-menu.sh` skips confirmation (`rofi_confirm` just echoes yes).
- Process names are matched against Nix wrapper names (`.waybar-wrapped`, `.awww-daemon-wr`, `.swayosd-server`, `.waypaper-wrapp`). These can change when nixpkgs changes how it wraps the binaries.

## Template for a new script

```bash
#!/usr/bin/env bash

set -euo pipefail

# usage: my-tool <arg>
if (($# < 1)); then
    echo "usage: $(basename "$0") <arg>" >&2
    exit 1
fi

notify-send "my-tool" "done: $1"
```

Then `git add scripts/scripts/my-tool.sh`, make sure every external command it calls is installed, bind it if needed (`"$mod, X, exec, my-tool"`), and run `validate.sh`.
