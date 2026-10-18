{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Multimedia
    amberol # music player
    audacity
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

    ## Level editor
    ldtk
    tiled
  ];
}
