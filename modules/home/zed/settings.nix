{ ... }:
{
  programs.zed-editor.userSettings = {
    # Updates are handled by nix
    auto_update = false;
    telemetry = {
      diagnostics = false;
      metrics = false;
    };

    ## Look
    theme = "Gruvbox Dark Hard";
    icon_theme = "Gruvbox Material Icon Theme";
    buffer_font_family = "Maple Mono";
    buffer_font_size = 18;
    mouse_wheel_zoom = true;
    wrap_guides = [ 100 ];

    ## Minimal UI
    minimap.show = "never";
    tab_bar.show = false;
    toolbar.breadcrumbs = false;
    scrollbar.show = "never";
    project_panel.dock = "right";

    ## Editing
    format_on_save = "on";
    use_on_type_format = true;
    ensure_final_newline_on_save = true;
    autosave = "on_window_change";
    max_tabs = 10;
    inlay_hints.enabled = false;

    terminal.font_family = "Maple Mono";

    ## C/C++
    lsp.clangd.binary.arguments = [
      "--clang-tidy"
      "--inlay-hints=false"
    ];

    ## Zig
    lsp.zls.settings.warn_style = true;

    ## Nix
    languages.Nix = {
      language_servers = [
        "nixd"
        "!nil"
      ];
      formatter.external = {
        command = "nixfmt";
        arguments = [ ];
      };
    };
  };
}
