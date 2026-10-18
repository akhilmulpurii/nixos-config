{ ... }:
{
  imports = [
    ./aseprite/aseprite.nix # pixel art editor
    ./bat.nix # better cat command
    ./browser.nix # firefox based browser
    ./btop.nix # resouces monitor
    ./cava.nix # audio visualizer
    ./direnv.nix
    ./discord.nix # discord
    ./fastfetch/fastfetch.nix # fetch tool
    ./fzf.nix # fuzzy finder
    ./ghostty/ghostty.nix # terminal
    ./git.nix # version control
    ./gnome.nix # gnome apps
    ./gtk.nix # gtk theme
    ./hyprland # window manager
    ./lazygit.nix
    ./micro.nix # nano replacement
    ./nemo.nix # file manager
    ./nvim.nix # neovim editor
    ./p10k/p10k.nix
    ./packages # other packages
    ./pomo/pomo.nix # TUI Pomodoro timer
    ./rofi/rofi.nix # launcher
    ./../../scripts/scripts.nix # personal scripts
    ./ssh.nix # ssh config
    ./superfile/superfile.nix # terminal file manager
    ./swaylock.nix # lock screen
    ./swayosd.nix # brightness / volume wiget
    ./swaync/swaync.nix # notification deamon
    ./waybar # status bar
    ./waypaper.nix # GUI wallpaper picker
    ./xdg-mimes.nix # xdg config
    ./zed # code editor
    ./zsh # shell
  ];
}
