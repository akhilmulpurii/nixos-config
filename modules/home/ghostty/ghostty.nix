{ host, ... }:
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      ##### Font #####
      font-family = [
        "Maple Mono"
        # "DejaVu Sans"
      ];
      font-size = if (host == "p14s") then 20 else 16;
      font-feature = [
        "calt"
        "cv66"
        "ss05"
      ];

      scrollback-limit = 100000000;

      ##### Theme #####
      theme = "gruvbox";
      background-opacity = 0.5;
      adjust-cursor-thickness = 1;

      selection-clear-on-copy = true;
      mouse-hide-while-typing = true;

      ##### Window #####;
      window-padding-balance = true;
      window-padding-color = "extend";
      window-decoration = "none";
      window-theme = "ghostty";
      window-inherit-working-directory = false;

      resize-overlay = "never";
      confirm-close-surface = false;
      app-notifications = "no-clipboard-copy";

      bell-features = "no-attention,no-audio,no-system,no-title,no-border";

      gtk-single-instance = false;
      gtk-tabs-location = "bottom";
      gtk-wide-tabs = false;
      gtk-custom-css = "styles/tabs.css";

      auto-update = "off";

      clipboard-read = "allow";
      clipboard-write = "allow";
      clipboard-paste-protection = false;

      ##### Keybinds #####
      keybind = [
        "clear"

        "ctrl+shift+a=select_all"
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"

        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_tab:this"
        "alt+digit_1=goto_tab:1"
        "alt+digit_2=goto_tab:2"
        "alt+digit_3=goto_tab:3"
        "alt+digit_4=goto_tab:4"
        "alt+digit_5=goto_tab:5"
        "alt+digit_6=goto_tab:6"
        "alt+digit_7=goto_tab:7"
        "alt+digit_8=goto_tab:8"
        "alt+digit_9=goto_tab:9"
        "ctrl+shift+arrow_left=previous_tab"
        "ctrl+shift+arrow_right=next_tab"

        # Omarchy splits
        "ctrl+shift+e=new_split:down"
        "ctrl+shift+o=new_split:right"
        "ctrl+alt+arrow_left=goto_split:left"
        "ctrl+alt+arrow_right=goto_split:right"
        "ctrl+alt+arrow_up=goto_split:up"
        "ctrl+alt+arrow_down=goto_split:down"
        "super+ctrl+shift+arrow_left=resize_split:left,10"
        "super+ctrl+shift+arrow_right=resize_split:right,10"
        "super+ctrl+shift+arrow_up=resize_split:up,10"
        "super+ctrl+shift+arrow_down=resize_split:down,10"
        "super+ctrl+shift+alt+arrow_left=resize_split:left,100"
        "super+ctrl+shift+alt+arrow_right=resize_split:right,100"
        "super+ctrl+shift+alt+arrow_up=resize_split:up,100"
        "super+ctrl+shift+alt+arrow_down=resize_split:down,100"

        "ctrl+equal=increase_font_size:1"
        "ctrl++=increase_font_size:1"
        "ctrl+-=decrease_font_size:1"
        "ctrl+0=reset_font_size"

        "shift+page_down=scroll_page_down"
        "shift+page_up=scroll_page_up"
      ];
    };

    themes.gruvbox = {
      background = "1d2021";
      foreground = "fbf1c7";

      cursor-color = "D5C4A1";

      selection-background = "cell-foreground";
      selection-foreground = "cell-background";

      palette = [
        "0=32302f"
        "1=cc241d"
        "2=98971a"
        "3=d79921"
        "4=458588"
        "5=b16286"
        "6=689d6a"
        "7=ebdbb2"

        "8=928374"
        "9=fb4934"
        "10=b8bb26"
        "11=fabd2f"
        "12=83a598"
        "13=d3869b"
        "14=8ec07c"
        "15=fbf1c7"
      ];
    };
  };

  xdg.configFile."ghostty/styles/tabs.css".source = ./styles/tabs.css;
}
