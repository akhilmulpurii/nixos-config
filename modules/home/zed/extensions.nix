{ ... }:
{
  # Names come from https://github.com/zed-industries/extensions/tree/main/extensions
  # Zed installs them on first launch (needs network access).
  programs.zed-editor.extensions = [
    ## Languages
    "nix"
    "zig"
    "assembly"

    ## Icon theme (the Gruvbox color theme is bundled with Zed)
    "gruvbox-material-icons"
  ];
}
