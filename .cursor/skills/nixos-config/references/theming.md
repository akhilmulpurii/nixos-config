# Theming

The theme is Gruvbox Dark Hard everywhere, with square corners (rounding 0), Maple Mono, the Colloid GTK theme, Papirus-Dark icons and the Bibata-Modern-Ice cursor. There is **no central palette or theming framework** (no Stylix or nix-colors): colors are hardcoded in each file.

## Palette

| Role | Hex | Typical use |
|---|---|---|
| bg0_h (background) | `#1D2021` | Ghostty background, rofi `bg-col`, Waybar `background_0` |
| bg0 | `#282828` | Waybar bar, tooltips, swayosd, rofi `bg-col-light`, fzf `bg+` |
| bg1 | `#3C3836` | selections, swaylock inside, micro cursor-line |
| bg3 / bg4 | `#665C54` / `#7C6F64` | borders, line numbers |
| gray | `#928374` | comments, Waybar settings border |
| fg4 / fg3 | `#A89984` / `#BDAE93` | borders (Waybar style, rofi, hyprlock), muted text |
| fg1 | `#EBDBB2` | secondary foreground |
| fg0 (main text) | `#FBF1C7` | text in Ghostty, Waybar, rofi, swayosd, swaylock |
| red / bright | `#CC241D` / `#FB4934` | power icon, errors, active-border gradient end |
| green / bright | `#98971A` / `#B8BB26` | accents (rofi prompt, CPU icon, active-border start, today in calendar) |
| yellow / bright | `#D79921` / `#FABD2F` | workspaces, battery, keyboard layout |
| blue / bright | `#458588` / `#83A598` | volume |
| purple / bright | `#B16286` / `#D3869B` | network |
| aqua / bright | `#689D6A` / `#8EC07C` | memory, swaylock ring |
| orange / bright | `#D65D0E` / `#FE8019` | active workspace, fzf marker |

## Where colors live

| File | Format |
|---|---|
| `modules/home/hyprland/settings.nix` | `col.active_border = "rgb(98971A) rgb(CC241D) 45deg"` |
| `modules/home/hyprland/hyprlock.nix` | `rgba(r, g, b, a)` decimal values |
| `modules/home/waybar/settings.nix`, `waybar/style.nix` | a `custom` attribute set in `let`, interpolated with `${green}` and so on |
| `modules/home/ghostty/ghostty.nix` | `themes.gruvbox` palette 0-15 (no `#`) |
| `modules/home/ghostty/styles/tabs.css` | CSS |
| `modules/home/rofi/theme.rasi` | rasi variables (`@bg-col`, `@green`, ...) used by `config.rasi` and `powermenu-theme.rasi` |
| `modules/home/swaync/style.css` | CSS |
| `modules/home/swayosd.nix` | inline CSS |
| `modules/home/swaylock.nix` | `RRGGBBAA`, no `#` |
| `modules/home/fzf.nix` | `--color=` flags |
| `modules/home/micro.nix` | inline `gruvbox.micro` colorscheme |
| `modules/home/cava.nix` | gradient, quoted as `"'#rrggbb'"` |
| `scripts/scripts/power-menu.sh`, `power-profile-menu.sh` | Pango `<span color=...>` |
| Built-in themes by name | bat `gruvbox-dark`, btop `TTY`, Zed `Gruvbox Dark Hard`, superfile `gruvbox-dark-hard`, GNOME Text Editor `builder-dark` |

To retheme, grep for the hex values (case-insensitive) across `modules/` and `scripts/`, and update the named themes listed above. If a central palette is wanted, the cleanest option is a `modules/home/theme.nix` that defines options (or a `_module.args.palette`) consumed by these files. That is a refactor, so suggest it to the user rather than doing it silently.

## Fonts

- **Maple Mono** (custom build `pkgs.maple-mono-custom`, features `cv66` + `ss05`, ligature tag removed, no Nerd Font glyphs). Used by Ghostty, Waybar, rofi, hyprlock, swaylock, GTK, Zed, and GNOME Text Editor.
- Icon glyphs come from `nerd-fonts.symbols-only` and the JetBrainsMono Nerd Font fallback (fontconfig monospace order: Maple Mono, then JetBrainsMono Nerd Font).
- Sizes: Ghostty 16 (20 on p14s), GTK 12 (14 on p14s), Zed 18, Waybar 18px bold, rofi 16 bold, hyprlock clock 115.
- Ghostty requests `font-feature = calt cv66 ss05`. If you change the font build features in `pkgs/maple-mono/default.nix`, keep them in sync.

## GTK, icons, cursor

- GTK theme: `pkgs.colloid-gtk-theme.override { colorVariants = ["dark"]; themeVariants = ["green"]; tweaks = ["gruvbox" "rimless" "float"]; }`, named `Colloid-Green-Dark-Gruvbox`. The name is also set in `GTK_THEME` (`hyprland/variables.nix`) and in dconf. If you change it, change all three places.
- Icons: `papirus-icon-theme.override { color = "green"; }`, named `Papirus-Dark` (also referenced in rofi `config.rasi` as `Papirus-dark`).
- Cursor: `Bibata-Modern-Ice` size 24 in `gtk.cursorTheme`, `home.pointerCursor`, and `exec-once` (`hyprctl setcursor`).
- Qt: the env vars request qt5ct/kvantum, but neither is installed, so Qt apps fall back to their default look.
