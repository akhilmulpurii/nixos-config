{ ... }:
let
  # Omarchy-style web apps, opened in a new zen window
  webapp = url: "zen-beta --new-window ${url}";
in
{
  # Keybinds follow Omarchy defaults (https://omarchy.org/manual/hotkeys/).
  # Older personal binds are kept only where they don't clash with Omarchy.
  wayland.windowManager.hyprland.settings = {
    binds = {
      scroll_event_delay = 100;
      movefocus_cycles_fullscreen = true;
    };

    bind = [
      # show keybinds list
      "$mod, F1, exec, show-keybinds"

      ########## Omarchy: navigating ##########
      "$mod, Space, exec, toggle-rofi rofi -show drun"
      "$mod ALT, Space, exec, toggle-rofi rofi -show drun"
      "$mod, Escape, exec, power-menu"
      "$mod CTRL, L, exec, hyprlock"
      "$mod, W, killactive,"
      "$mod, Q, killactive,"
      "CTRL ALT, Delete, exec, close-all-windows"

      "$mod, T, exec, toggle-float"
      "$mod, J, layoutmsg, togglesplit"
      "$mod, O, pin,"
      "$mod, L, exec, cycle-layout"
      "$mod ALT, L, exec, cycle-layout --reverse"
      "$mod, P, pseudo,"
      "$mod, F, fullscreen, 0"
      "$mod ALT, F, fullscreen, 1"
      "$mod CTRL, F, fullscreenstate, 0 2"

      # switch workspace
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"
      "$mod, 9, workspace, 9"
      "$mod, 0, workspace, 10"
      "$mod, Tab, workspace, e+1"
      "$mod SHIFT, Tab, workspace, e-1"
      "$mod CTRL, Tab, workspace, previous"

      # move window to workspace (and follow)
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"

      # move window to workspace without following
      "$mod SHIFT ALT, 1, movetoworkspacesilent, 1"
      "$mod SHIFT ALT, 2, movetoworkspacesilent, 2"
      "$mod SHIFT ALT, 3, movetoworkspacesilent, 3"
      "$mod SHIFT ALT, 4, movetoworkspacesilent, 4"
      "$mod SHIFT ALT, 5, movetoworkspacesilent, 5"
      "$mod SHIFT ALT, 6, movetoworkspacesilent, 6"
      "$mod SHIFT ALT, 7, movetoworkspacesilent, 7"
      "$mod SHIFT ALT, 8, movetoworkspacesilent, 8"
      "$mod SHIFT ALT, 9, movetoworkspacesilent, 9"
      "$mod SHIFT ALT, 0, movetoworkspacesilent, 10"

      # scratchpad
      "$mod, S, togglespecialworkspace, scratchpad"
      "$mod, grave, togglespecialworkspace, scratchpad"
      "$mod ALT, S, movetoworkspacesilent, special:scratchpad"
      "$mod SHIFT, grave, movetoworkspacesilent, special:scratchpad"

      # monitors
      "$mod SHIFT CTRL, left, movewindow, mon:l"
      "$mod SHIFT CTRL, right, movewindow, mon:r"
      "$mod SHIFT CTRL, up, movewindow, mon:u"
      "$mod SHIFT CTRL, down, movewindow, mon:d"
      "$mod SHIFT ALT, left, movecurrentworkspacetomonitor, l"
      "$mod SHIFT ALT, right, movecurrentworkspacetomonitor, r"
      "$mod SHIFT ALT, up, movecurrentworkspacetomonitor, u"
      "$mod SHIFT ALT, down, movecurrentworkspacetomonitor, d"

      # focus
      "$mod, left,  movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up,    movefocus, u"
      "$mod, down,  movefocus, d"

      # swap window
      "$mod SHIFT, left,  swapwindow, l"
      "$mod SHIFT, right, swapwindow, r"
      "$mod SHIFT, up,    swapwindow, u"
      "$mod SHIFT, down,  swapwindow, d"

      # mouse wheel workspaces
      "$mod, mouse_down, workspace, e-1"
      "$mod, mouse_up, workspace, e+1"

      # groups
      "$mod, G, togglegroup,"
      "$mod ALT, G, moveoutofgroup,"
      "$mod ALT, Tab, changegroupactive, f"
      "$mod ALT SHIFT, Tab, changegroupactive, b"
      "$mod ALT, mouse_down, changegroupactive, f"
      "$mod ALT, mouse_up, changegroupactive, b"
      "$mod ALT, 1, changegroupactive, 1"
      "$mod ALT, 2, changegroupactive, 2"
      "$mod ALT, 3, changegroupactive, 3"
      "$mod ALT, 4, changegroupactive, 4"
      "$mod ALT, 5, changegroupactive, 5"
      "$mod ALT, left,  moveintogroup, l"
      "$mod ALT, right, moveintogroup, r"
      "$mod ALT, up,    moveintogroup, u"
      "$mod ALT, down,  moveintogroup, d"
      "$mod CTRL, left,  changegroupactive, b"
      "$mod CTRL, right, changegroupactive, f"

      # zoom
      "$mod CTRL, Z, exec, zoom --in"
      "$mod CTRL ALT, Z, exec, zoom --reset"

      # cycle windows / monitors
      "ALT, Tab, cyclenext,"
      "ALT, Tab, bringactivetotop,"
      "ALT SHIFT, Tab, cyclenext, prev"
      "ALT SHIFT, Tab, bringactivetotop,"
      "CTRL ALT, Tab, focusmonitor, +1"
      "CTRL ALT SHIFT, Tab, focusmonitor, -1"

      ########## Omarchy: system controls ##########
      "$mod CTRL, A, exec, pavucontrol"
      "$mod CTRL, B, exec, blueman-manager"
      "$mod CTRL, W, exec, ghostty -e nmtui"
      "$mod CTRL, P, exec, power-profile-menu"
      "$mod CTRL, T, exec, ghostty -e btop"

      ########## Omarchy: launching apps ##########
      "$mod, Return, exec, ghostty --gtk-single-instance=true"
      "$mod SHIFT, Return, exec, zen-beta"
      "$mod SHIFT ALT, B, exec, zen-beta --private-window"
      "$mod SHIFT, F, exec, nemo"
      "$mod SHIFT, N, exec, ghostty -e nvim"
      "$mod SHIFT, A, exec, ${webapp "https://chatgpt.com"}"
      "$mod SHIFT ALT, A, exec, ${webapp "https://grok.com"}"
      "$mod SHIFT, P, exec, ${webapp "https://photos.google.com"}"
      "$mod SHIFT ALT, S, exec, ${webapp "https://maps.google.com"}"
      "$mod SHIFT ALT, G, exec, ${webapp "https://web.whatsapp.com"}"
      "$mod SHIFT CTRL, G, exec, ${webapp "https://messages.google.com/web"}"
      "$mod SHIFT, X, exec, ${webapp "https://x.com"}"
      "$mod SHIFT ALT, X, exec, ${webapp "https://x.com/compose/post"}"
      "$mod SHIFT, Y, exec, ${webapp "https://youtube.com"}"

      ########## Omarchy: universal clipboard ##########
      "$mod, C, sendshortcut, CTRL, Insert,"
      "$mod, V, sendshortcut, SHIFT, Insert,"
      "$mod, X, sendshortcut, CTRL, X,"
      "$mod CTRL, V, exec, toggle-rofi \"cliphist list | rofi -dmenu -theme-str 'window {width: 50%;} listview {columns: 1;}' | cliphist decode | wl-copy\""

      ########## Omarchy: capture ##########
      ", Print, exec, screenshot --copy"
      "$mod SHIFT, S, exec, screenshot --copy"
      "$mod, Print, exec, hyprpicker -a"
      "$mod CTRL, Print, exec, ocr"

      ########## Omarchy: notifications ##########
      "$mod, comma, exec, swaync-client --close-latest"
      "$mod SHIFT, comma, exec, swaync-client --close-all"
      "$mod CTRL, comma, exec, swaync-client --toggle-dnd"
      "$mod SHIFT ALT, comma, exec, swaync-client -t -sw"

      ########## Omarchy: style ##########
      "$mod CTRL, Space, exec, wallpaper-picker"
      "$mod, BackSpace, exec, toggle-oppacity"

      ########## Omarchy: toggles ##########
      "$mod SHIFT, Space, exec, toggle-waybar"
      "$mod SHIFT, BackSpace, exec, toggle-gaps"
      "$mod CTRL, Delete, exec, toggle-display"

      ########## Omarchy: notices ##########
      "$mod CTRL ALT, T, exec, notify-send \"$(date +'%A %H:%M')\" \"$(date +'%d %B %Y')\""
      "$mod CTRL ALT, B, exec, notify-send \"Battery\" \"$(cat /sys/class/power_supply/BAT*/capacity)%\""

      ########## Personal (non-conflicting) ##########
      "ALT, Return, exec, [float; size 1111 700] ghostty"
      "$mod, B, exec, [workspace 1 silent] zen-beta"
      "$mod, D, exec, toggle-rofi rofi -show drun"
      "$mod SHIFT, D, exec, vesktop --enable-features=UseOzonePlatform --ozone-platform=wayland"
      "ALT, Escape, exec, hyprlock & systemctl suspend"
      "$mod SHIFT, Escape, exec, power-menu"
      "$mod, E, exec, nemo"
      "ALT, E, exec, hyprctl dispatch exec '[float; size 1111 700] nemo'"
      "$mod SHIFT, B, exec, toggle-waybar"
      "$mod SHIFT, W,exec, hyprctl dispatch exec '[float; size 925 615] waypaper'"
      "$mod, N, exec, swaync-client -t -sw"
      "CTRL SHIFT, Escape, exec, hyprctl dispatch exec '[workspace 9] missioncenter'"
      "$mod CTRL, O, exec, ocr"
      "$mod CTRL, C, movetoworkspace, empty"
      "$mod SHIFT, Print, exec, screenshot --swappy"
      "CTRL, Print, exec, screenshot --save"
      "$mod, XF86Display, exec, toggle-display"

      # vim-style focus/move (J and L belong to Omarchy)
      "$mod, h, movefocus, l"
      "$mod, k, movefocus, u"
      "$mod SHIFT, h, movewindow, l"
      "$mod SHIFT, j, movewindow, d"
      "$mod SHIFT, k, movewindow, u"
      "$mod SHIFT, l, movewindow, r"

      # media controls
      ", XF86AudioPlay,exec, playerctl play-pause"
      ", XF86AudioNext,exec, playerctl next"
      ", XF86AudioPrev,exec, playerctl previous"
      ", XF86AudioStop,exec, playerctl stop"
      "ALT, XF86AudioPlay, exec, playerctl next"
      "ALT SHIFT, XF86AudioPlay, exec, playerctl previous"
    ];

    # resize (Omarchy: minus/equal, ALT = small steps, CTRL = big steps)
    binde = [
      "$mod, minus, resizeactive, -100 0"
      "$mod, equal, resizeactive, 100 0"
      "$mod SHIFT, minus, resizeactive, 0 -100"
      "$mod SHIFT, equal, resizeactive, 0 100"
      "$mod ALT, minus, resizeactive, -25 0"
      "$mod ALT, equal, resizeactive, 25 0"
      "$mod CTRL, minus, resizeactive, -300 0"
      "$mod CTRL, equal, resizeactive, 300 0"
    ];

    # mouse binding
    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindl = [ ",switch:on:Lid Switch, exec, pidof hyprlock || hyprlock" ];
  };
}
