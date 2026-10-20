{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    ## AI
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-with-fhs # Claude Desktop (FHS env for MCP servers)

    ## Multimedia
    gimp
    media-downloader

    pavucontrol
    video-trimmer
    vlc

    newsflash

    ## Office
    libreoffice
    gnome-calculator

    ## Utility
    dconf-editor
    gnome-disk-utility
    popsicle
    mission-center # GUI resources monitor
    zenity
  ];
}
