{ ... }:
{
  programs.zed-editor.userKeymaps = [
    {
      context = "Editor && mode == full";
      bindings = {
        "ctrl-q" = "editor::ToggleComments";
      };
    }
    {
      context = "Workspace";
      bindings = {
        "ctrl-s" = "workspace::SaveAll";
      };
    }
  ];
}
