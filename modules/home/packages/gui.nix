{ pkgs, ... }:
{
  home.packages = with pkgs; [
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
