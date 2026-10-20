---
name: nixos-config
description: Operates Akhil's flake-based NixOS and Home Manager configuration in ~/nixos-config (Hyprland, Waybar, Rofi, swaync, Ghostty, Zed, zsh with powerlevel10k, Gruvbox Dark Hard theme, Maple Mono font; hosts desktop, laptop, p14s, vm). Use when adding or removing packages, editing system (modules/core) or home-manager (modules/home) modules, changing Hyprland keybinds, window rules or autostart, adding helper scripts, hosts, custom packages or flake inputs, retheming, updating flake.lock, or validating and rebuilding with nh or nixos-rebuild. Also use when the user mentions their dotfiles, rice, desktop setup, or asks "where is X configured". Do NOT use for generic Nix questions unrelated to this repository.
license: MIT
compatibility: NixOS with flakes and nix-command enabled; repo checked out at ~/nixos-config; nix, nh, nixfmt and shfmt on PATH. Applying changes needs sudo.
metadata:
  author: Sai Akhil Mulpuri
  version: 1.0.0
  upstream: github.com/Frost-Phoenix/nixos-config (forked; now owned by akhilmulpurii)
---

# nixos-config

Single-user NixOS flake. Every host imports the same system modules (`modules/core`), which pull in one shared Home Manager profile (`modules/home`). Per-machine differences are small and live in `hosts/<host>/default.nix` or behind `host == "..."` conditionals.

## Critical rules

Read these before making any change:

1. **Run `git add` on new files before evaluating.** Flakes only see files tracked by git, and an untracked module fails with `Path '...' is not tracked by Git`. Modified tracked files are picked up without staging.
2. **`modules/core` applies to every host.** That includes the NVIDIA driver (`core/hardware.nix`) and the `/mnt/data` disk mount (`core/filesystem.nix`), which only exist on the desktop. Put hardware-specific config in `hosts/<host>/default.nix`, not in core.
3. **Never hand-edit `hosts/*/hardware-configuration.nix`.** Regenerate it with `nixos-generate-config --show-hardware-config`. Never change `system.stateVersion` or `home.stateVersion` (`26.05`).
4. **Format only the files you touched**, with `nixfmt <file>` and `shfmt -w -ci -sr -i 4 <file>`. Do NOT run `treefmt` on the whole tree: `treefmt.toml` passes `-s` (strict) to nixfmt, which rewrites about 67 files into a style the repo doesn't use. `modules/home/packages/*.nix` is intentionally unformatted (it has aligned comments).
5. **Validate by evaluation before anything touches the live system.** Run `scripts/validate.sh` (it never builds or switches). `nh os switch` and `nixos-rebuild switch` change the running machine and need sudo, so only run them when the user asks.
6. **Prefer upstream modules.** Use `programs.<name>` or `services.<name>` (Home Manager first, NixOS second) before falling back to `home.packages` plus `xdg.configFile`.
7. **Keep the Gruvbox palette.** New UI config uses the colors in [references/theming.md](references/theming.md) and the `Maple Mono` font.

## Repo map

```
flake.nix                 inputs + 4 nixosConfigurations (desktop, laptop, p14s, vm); username = "akhil"
hosts/<host>/             default.nix (host tweaks) + hardware-configuration.nix (generated)
modules/core/             NixOS system modules; default.nix is the import list
modules/home/             Home Manager modules; default.nix is the import list (one tool per entry)
  hyprland/               WM: binds, exec-once, settings, windowrules, variables (env), monitors, hyprlock
  waybar/ zed/ zsh/       multi-file modules with their own default.nix
  packages/               plain package lists: cli.nix, dev.nix, gui.nix, nix.nix
pkgs/                     custom derivations, exposed through an overlay (pkgs.maple-mono-custom, pkgs.pomo)
scripts/scripts/*.sh      each file becomes a command named after it (foo.sh -> foo) via scripts/scripts.nix
wallpapers/               copied to ~/Pictures/wallpapers by install.sh (not managed declaratively)
```

## How it is wired

- `flake.nix` builds `nixosSystem` per host with `specialArgs = { host, self, inputs, username }`.
- `hosts/<host>/default.nix` imports its `hardware-configuration.nix` and `../../modules/core`.
- `core/user.nix` imports the home-manager NixOS module and sets `users.akhil.imports = [ ../home ]` with `extraSpecialArgs = { inputs, username, host }`, `useGlobalPkgs = true`, `useUserPackages = true`, and `backupFileExtension = "hm-backup"`.
- `core/nixpkgs.nix` overlays `pkgs/default.nix`, so custom packages are plain `pkgs.<name>` everywhere.
- Module function arguments available: system modules get `pkgs lib config inputs username host self`; home modules get `pkgs lib config inputs username host` (no `self`).
- `allowUnfree = true` is set system-wide. Home Manager reuses the system pkgs, so a `nixpkgs.config` inside a home module has no effect.

Full detail, including inputs, every core module and the hosts matrix: [references/architecture.md](references/architecture.md).

## Where does a change go?

| Change | File |
|---|---|
| CLI tool, no config | `modules/home/packages/cli.nix` (or `dev.nix`, `gui.nix`, `nix.nix`), under the matching `##` group |
| App with config | new `modules/home/<app>.nix` (or `<app>/<app>.nix` plus assets), added to `modules/home/default.nix` |
| System service, driver, kernel, boot | the matching `modules/core/<topic>.nix`; new topics are added to `modules/core/default.nix` |
| One machine only | `hosts/<host>/default.nix`, or `if host == "p14s" then ... else ...` inside a shared module |
| Keybind | `modules/home/hyprland/binds.nix` (volume, brightness and lock keys are in `modules/home/swayosd.nix`) |
| Window rule, autostart, env var | `hyprland/windowrules.nix`, `hyprland/exec-once.nix`, `hyprland/variables.nix` |
| Shell alias | `modules/home/zsh/zsh_alias.nix` (git aliases are in `git.nix`) |
| Helper command | `scripts/scripts/<name>.sh` (needs a shebang; its dependencies must be installed somewhere) |
| Package not in nixpkgs | `pkgs/<name>/default.nix` plus a line in `pkgs/default.nix` |
| New flake | `flake.nix` inputs (with `inputs.nixpkgs.follows = "nixpkgs"` when supported), used through `inputs.<name>` |
| Default app (MIME type) | `modules/home/xdg-mimes.nix` (`defaultApps` and `mimeMap`) |

Step-by-step procedures for each row: [references/recipes.md](references/recipes.md).

## Standard workflow

Copy this checklist and track progress:

```
- [ ] 1. Locate: read the target file and its default.nix import list; grep for an existing definition first
- [ ] 2. Edit, following the conventions below
- [ ] 3. git add any new files
- [ ] 4. Format the touched files (nixfmt / shfmt)
- [ ] 5. Run .cursor/skills/nixos-config/scripts/validate.sh  (add host names to limit it, e.g. "desktop")
- [ ] 6. Optionally confirm a value: scripts/query-option.sh <host> <option.path>
- [ ] 7. Hand off: tell the user to run `nfs` (switch) or `nft` (test), or run it if they asked
```

**Step 5, validation loop.** `validate.sh` warns about untracked files, checks formatting of changed files, and evaluates `nixosConfigurations.<host>.config.system.build.toplevel.drvPath` for each host. If it fails, read the **last** `error:` line (the root cause; the lines above it are trace context), fix the problem, and re-run. Only continue once it passes. A full evaluation of all four hosts takes about 30 to 120 seconds. The `programs.ssh.matchBlocks is deprecated` warning comes from existing code and does not count as a failure.

**Building without switching** (catches build-time failures such as hash mismatches): `nh os build . -H <host>`, or `nix build .#nixosConfigurations.<host>.config.system.build.toplevel --no-link`. This can take a long time on the first run (the Maple Mono font is built from source).

## Commands

| Purpose | Command |
|---|---|
| Switch current host (hostname = host) | `nh os switch` (zsh alias `nfs`, wrapped by `nh-notify`, which sends a notification when done) |
| Test without adding a boot entry | `nh os test` (`nft`) |
| Update all inputs and switch | `nh os switch --update` (`nfu`) |
| Update one input | `nix flake update <input>` |
| Garbage collect | `nh clean all --keep 5` (`nc`); automatic weekly clean keeps 7 days or 5 generations |
| Diff two system closures | `nvd diff /run/current-system result` |
| Find a package | `nh search <name>`, or run it once with `, <cmd>` (comma via nix-index-database) |
| Inspect an option | `scripts/query-option.sh desktop hm.programs.ghostty.settings.font-size` |
| List or check keybinds | `scripts/keybinds.sh desktop 'SUPER, D'` |

`nh` resolves the flake from `programs.nh.flake = /home/akhil/nixos-config` and picks the configuration that matches the hostname.

## Conventions

- **Nix style:** RFC-style `nixfmt`, 2-space indent, header `{ pkgs, ... }:` followed by `{` on its own line. Use `{ ... }:` when no arguments are needed. Bind locals in `let ... in` (see `gtk.nix` and `waybar/settings.nix`).
- **One concern per file.** Each import in `modules/home/default.nix` carries a short trailing comment, e.g. `./bat.nix # better cat command`. Keep that list alphabetical.
- **Package lists:** group under `## Heading` comments, with optional aligned `# description` comments.
- **Dotfiles that are not Nix** (rasi, css, json, toml, yaml) sit next to their module and are linked with `xdg.configFile."<app>/<file>".source = ./<file>;`. Use `.text = '' ... ''` for small inline files.
- **Host conditionals** are inline expressions, e.g. `font-size = if (host == "p14s") then 20 else 16;`.
- **Hyprland:** settings go through `wayland.windowManager.hyprland.settings` (hyprlang, pinned with `configType = "hyprlang"`; upstream deprecated it in favor of Lua, so don't switch formats as a side effect; see [references/desktop.md](references/desktop.md)). The modifier is `$mod` (SUPER). Window rules use the new `match:` syntax: `"match:class ^(mpv)$, float on"`. Don't use the legacy `windowrulev2` form.
- **Commit messages** follow the repo history: `pkgs: add <pkg>`, `pkgs(<group>): ...`, `config(<app>): <change>`, `fix: <what>`, `chore: update` (for flake.lock bumps).

## Examples

**Example 1: "install btop alternative `bottom`"**
1. Add `bottom` under `## Monitoring / fetch` in `modules/home/packages/cli.nix`.
2. Run `validate.sh desktop`. Result: the evaluation passes, and the user runs `nfs`.

**Example 2: "bind SUPER+O to an OCR-to-clipboard script"**
1. Check for conflicts with `keybinds.sh desktop 'SUPER, O'`. `$mod CTRL, O` already runs `ocr`, so check whether the user wants a duplicate.
2. If a script is needed, create `scripts/scripts/<name>.sh` with `#!/usr/bin/env bash`, `git add` it, and make sure its tools (for example `tesseract` or `grimblast`) are installed (`hyprland/hyprland.nix` installs both).
3. Add `"$mod, O, exec, <name>"` to `bind` in `hyprland/binds.nix`, then run `validate.sh`.

**Example 3: "add my new ThinkPad as host `t14`"**
Follow "Add a host" in [references/recipes.md](references/recipes.md). In short: create `hosts/t14/` with a generated hardware config, add a `t14 = nixpkgs.lib.nixosSystem { ... }` entry in `flake.nix`, and decide whether the desktop-only core modules (NVIDIA, `/mnt/data`) need to move into `hosts/desktop` first.

## Troubleshooting (most common)

| Symptom | Fix |
|---|---|
| `Path 'modules/home/foo.nix' ... is not tracked by Git` | Run `git add` on the file |
| `The option 'x' does not exist` | Wrong option path or a module isn't imported. Check with `query-option.sh`; options under `programs.*` in home modules belong to Home Manager, not NixOS |
| `Existing file '~/.config/...' is in the way` | Home Manager backs it up as `*.hm-backup`. If that backup already exists, remove the stale `*.hm-backup` file |
| `hash mismatch ... got: sha256-...` | Paste the `got:` hash into the derivation (`pkgs/*/default.nix` or `fetchFromGitHub`) |
| Laptop or VM boot hangs on `/mnt/data` | Move `core/filesystem.nix` into `hosts/desktop`, or add `"nofail"` to its options |

More, including known inherited issues: [references/troubleshooting.md](references/troubleshooting.md).

## References

- [references/architecture.md](references/architecture.md): flake inputs, specialArgs flow, every core module, hosts matrix, overlay, state that lives outside Nix
- [references/components.md](references/components.md): inventory of every Home Manager module and what it configures
- [references/desktop.md](references/desktop.md): Hyprland keybinds, autostart, window rules, env vars, monitors, Waybar, Rofi, swaync, lock screens, wallpapers
- [references/scripts.md](references/scripts.md): every helper command, what it does, what calls it, and its dependencies
- [references/theming.md](references/theming.md): Gruvbox palette, fonts, GTK, icons and cursor, and every file with hardcoded colors
- [references/recipes.md](references/recipes.md): step-by-step procedures (packages, modules, hosts, scripts, inputs, custom packages, updates, rollbacks)
- [references/troubleshooting.md](references/troubleshooting.md): error to cause to fix, plus the known tech-debt list

## Bundled scripts (run them; you don't need to read them)

- `scripts/validate.sh [host ...]`: untracked-file check, format check of changed files, eval of all or the named hosts. Exits non-zero on failure.
- `scripts/query-option.sh <host> <option.path>`: prints the evaluated value as JSON. The `hm.` prefix expands to `home-manager.users.<username>.`.
- `scripts/keybinds.sh [host] [filter]`: lists every Hyprland bind (`bind`, `binde`, `bindl`, `bindel`, `bindr`, `bindm`) from the evaluated config, with an optional case-insensitive filter.

All three run from any directory; they locate the repo root through git.
