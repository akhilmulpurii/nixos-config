# Desktop (Hyprland session)

## Contents
- Session startup
- Hyprland module layout
- Keybinds
- Window rules
- Environment variables
- Monitors
- Waybar
- Rofi, swaync, swayosd, lock screens
- Wallpaper system

## Session startup

LightDM autologin (`core/xserver.nix`), then the Hyprland session (`programs.hyprland` in `core/wayland.nix`, HM `systemd.enable = true`), then `exec-once` runs `hyprlock` immediately, so **hyprlock acts as the login screen**. gnome-keyring is unlocked through PAM (`core/security.nix`).

`exec-once` order (`hyprland/exec-once.nix`, plus `swayosd-server` from `swayosd.nix`):
1. `dbus-update-activation-environment` / `systemctl --user import-environment` (WAYLAND_DISPLAY, XDG_CURRENT_DESKTOP)
2. `hyprlock`
3. `nm-applet`, `poweralertd`, `wl-clip-persist --clipboard both`, `wl-paste --watch cliphist store`, `waybar`, `swaync`, `udiskie --automount --notify --smart-tray`, `hyprctl setcursor Bibata-Modern-Ice 24`, `init-wallpaper`
4. `monitor-watcher` (laptop and p14s only; an empty string on other hosts)
5. A background Ghostty single-instance server (`--initial-window=false`), so later `ghostty --gtk-single-instance=true` windows open instantly
6. `zen-beta` on workspace 1, `ghostty` on workspace 2

## Hyprland module layout (`modules/home/hyprland/`)

| File | Content |
|---|---|
| `hyprland.nix` | `wayland.windowManager.hyprland.enable`, `package = null` and `portalPackage = null` (uses the NixOS package), `configType = "hyprlang"`, xwayland, systemd integration; installs Wayland utilities |
| `settings.nix` | `$mod = SUPER`; input (us,fr with Alt+Caps to switch, repeat delay 300, `follow_mouse = 0`, natural touchpad scroll); general (dwindle, gaps 6/12, border 2, green to red gradient active border); decoration (rounding 0, blur, shadow); animations (custom beziers, window in/out disabled); `force_zero_scaling` |
| `binds.nix` | `bind`, `bindm`, `bindl` (lid switch) |
| `exec-once.nix` | autostart (above) |
| `windowrules.nix` | `windowrule`, `layerrule`, `workspace` rules |
| `variables.nix` | `home.sessionVariables` (env) |
| `monitors.nix` | `monitor = ",preferred,auto,auto"` and sources `~/.config/hypr/{monitors,workspaces}.conf`; installs nwg-displays |
| `hyprlock.nix` | `programs.hyprlock`: forest_road.jpg (blurred), large time and date labels, username box, Gruvbox input field |

Hyprland options are merged across modules: `swayosd.nix` also appends to `bind`, `bindl`, `bindel`, `binde`, `bindr`, and `exec-once`. Before adding a bind, check what's already taken with `scripts/keybinds.sh`.

## Keybinds

`$mod` = SUPER. The list reflects the repo at the time of writing; for the current state run `scripts/keybinds.sh desktop`.

| Keys | Action |
|---|---|
| `$mod F1` | `show-keybinds` (rofi list of `bind=` lines from the generated hyprland.conf) |
| `$mod Return` / `ALT Return` / `$mod SHIFT Return` | Ghostty: single-instance / floating 1111x700 / fullscreen |
| `$mod B` | zen-beta on workspace 1 |
| `$mod Q` | kill the active window |
| `$mod F` / `$mod SHIFT F` | fullscreen / maximize |
| `$mod Space` | `toggle-float` (float, resize to 1111x700, center) |
| `$mod D` | rofi drun (toggles) |
| `$mod SHIFT D` | Vesktop |
| `$mod Escape` / `ALT Escape` / `$mod SHIFT Escape` | hyprlock / hyprlock and suspend / `power-menu` |
| `$mod P` | `power-profile-menu` |
| `$mod T` | `toggle-oppacity` (0.9 or 1.0 window opacity) |
| `$mod E` / `ALT E` | nemo / floating nemo |
| `$mod SHIFT B` | `toggle-waybar` |
| `$mod C` | hyprpicker (copies the color) |
| `$mod W` / `$mod SHIFT W` | `wallpaper-picker` (rofi) / waypaper GUI |
| `$mod N` | swaync panel |
| `CTRL SHIFT Escape` | Mission Center on workspace 9 |
| `$mod equal` | woomer (screen zoom) |
| `$mod XF86Display` | `toggle-display` (eDP-1 on/off) |
| `Print` / `$mod Print` / `$mod SHIFT Print` | `screenshot --copy` / `--save` / `--swappy` |
| `$mod CTRL O` | `ocr` (region to clipboard text) |
| `$mod` + arrows or `hjkl` | move focus (also raises the z-order) |
| `CTRL ALT Up` / `Down` | focus floating / tiled windows |
| `$mod 1..0` / `$mod SHIFT 1..0` | go to workspace 1-10 / move the window there silently |
| `$mod CTRL C` | move the window to an empty workspace |
| `$mod SHIFT` + arrows or `hjkl` | move the window |
| `$mod CTRL` + arrows or `hjkl` | resize by 80 px |
| `$mod ALT` + arrows or `hjkl` | move a floating window by 80 px |
| `XF86AudioPlay/Next/Prev/Stop` | playerctl |
| `$mod` mouse wheel | cycle workspaces |
| `$mod` LMB / RMB drag (`bindm`) | move / resize the window |
| `$mod V` | cliphist history in rofi, copies the selection |
| Lid switch (`bindl`) | hyprlock if it isn't already running |
| From `swayosd.nix`: `XF86AudioMute`, `XF86AudioMicMute` (`toggle-mic`), `XF86AudioRaise/LowerVolume` and `$mod F11/F12` (±2%), `XF86MonBrightnessUp/Down` (with `$mod`: 100% / 0%), Caps/Num/Scroll Lock OSD |

Bind syntax: `"MODS, key, dispatcher, args"`. Use `exec` for commands. Prefix with window rules in brackets for spawn rules: `"$mod, X, exec, [float; size 900 600] app"`. Wrap with `hyprctl dispatch exec '[...] app'` when the command contains extra quoting.

`show-keybinds` only parses lines that start with `bind=`, so `binde`, `bindl`, and similar binds don't appear in the F1 list.

## Window rules (`windowrules.nix`)

The `match:` syntax used by the pinned Hyprland (0.55.x) is used throughout. Don't copy older `windowrulev2 = float, class:^(x)$` examples from the internet:

```nix
"match:class ^(mpv)$, float on"
"match:title ^(Picture-in-Picture)$, pin on"
"match:class ^(dev.zed.Zed)$, workspace 3"
"match:class ^(zen-beta)$, match:title ^(.*YouTube.*)$, idle_inhibit focus"
"border_size 0, match:float 0, match:workspace w[tv1]"   # "no gaps when only"
```

Current assignments: floating windows are imv, mpv, zenity (850x500), waypaper, GNOME Calculator, File Roller, pavucontrol ("Volume Control" is 700x450 at `40 55%`), and Picture-in-Picture (also pinned). Pinned: rofi, waypaper. Workspaces: zen-beta → 1, Zed → 3, GIMP/Aseprite → 4, Discord/WebCord/Vesktop → 10. idle_inhibit for mpv, YouTube in Zen, and fullscreen Zen. `dim_around` for the GTK portal, the rofi layer, and the swaync control center. "No gaps when only" through `workspace = [ "w[tv1], gapsout:0, gapsin:0" "f[1], ..." ]`.

To find a window's class or title, run `hyprctl clients` (or `hyprctl activewindow`).

## Environment variables (`variables.nix`)

`EDITOR=micro`; Wayland everywhere (`NIXOS_OZONE_WL`, `GDK_BACKEND`, `QT_QPA_PLATFORM`, `SDL_VIDEODRIVER`, `CLUTTER_BACKEND`, `MOZ_ENABLE_WAYLAND`, `XDG_*=Hyprland`); NVIDIA-related (`__GL_GSYNC_ALLOWED=0`, `__GL_VRR_ALLOWED=0`, `WLR_NO_HARDWARE_CURSORS=1`, `WLR_RENDERER=vulkan`, `WLR_DRM_NO_ATOMIC=1`); `QT_QPA_PLATFORMTHEME=qt5ct` and `QT_STYLE_OVERRIDE=kvantum` (neither qt5ct nor kvantum is installed); `GTK_THEME=Colloid-Green-Dark-Gruvbox`; `SSH_AUTH_SOCK=/run/user/1000/ssh-agent` (hardcoded uid 1000, matching the HM ssh-agent).

Session variables apply on the next login, not on `nh os switch`.

## Monitors

Declarative default: `,preferred,auto,auto`. Per-machine layouts are made in the `nwg-displays` GUI, which writes `~/.config/hypr/monitors.conf` and `workspaces.conf`; both files are sourced with `hyprlang noerror` so a missing file is fine. On laptops, `monitor-watcher` disables `eDP-1` while an HDMI/DP monitor is connected and restarts awww, Waybar and swayosd on changes.

## Waybar (`waybar/`)

The bar sits at the bottom, 28 px high, layer top.
- Left: `custom/launcher` (left click: `random-wallpaper`; right click: rofi), `hyprland/workspaces` (Roman numerals I-X, workspaces 1-5 persistent), `tray`
- Center: `clock` (`%H:%M`; alternate format `%d/%m`; calendar tooltip)
- Right: `cpu`, `memory` (right click: floating btop in Ghostty), `pulseaudio` (click: mute through pamixer; right click: pavucontrol), `network`, `battery`, `hyprland/language` (FR/US; click switches the layout of `at-translated-set-2-keyboard`), `custom/notification` (swaync-client JSON), `custom/power-menu`
- `disk` is defined but not in the module list.
- `settings.nix` and `style.nix` each define their own `custom` palette set (border colors differ: `#928374` in settings, `#A89984` in style).

## Rofi, swaync, swayosd, lock screens

- **Rofi** is configured through raw `.rasi` files (`modules/home/rofi/`). `toggle-rofi <cmd>` kills a running rofi or runs the command, so the same key opens and closes it.
- **swaync**: `config.json` + `style.css`. Toggle the panel with `swaync-client -t -sw`.
- **swayosd**: the server is autostarted; the client is called from binds. It crashes on monitor changes, so `monitor-watcher` restarts it.
- **Lock screens**: hyprlock (primary; keybinds, lid, startup) and swaylock-effects (power menu "lock" entry). There is no idle daemon (hypridle/swayidle are not configured), so the screen never auto-locks.

## Wallpaper system

The daemon is `awww` (the renamed swww): `awww-daemon` + `awww img`.

- `init-wallpaper`: starts the daemon if needed, waits for it, then sets `~/Pictures/wallpapers/wallpaper` with no transition.
- `wallpaper-picker` (`$mod W`): rofi list of `~/Pictures/wallpapers/others`, updates the symlink, calls `wall-change`.
- `random-wallpaper` (Waybar launcher click): picks a random wallpaper different from the current one.
- `wall-change <file>`: `awww img` with a random transition (outer, center, any, or wipe at 135°).
- waypaper GUI (`$mod SHIFT W`): same folder, `awww` backend.

New wallpapers go into `~/Pictures/wallpapers/others/` (runtime) or `wallpapers/otherWallpaper/` (repo, copied only by `install.sh`).
