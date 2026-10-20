# Recipes

Each recipe ends with the same gate: format the touched files, run `.cursor/skills/nixos-config/scripts/validate.sh`, and hand off the rebuild (`nfs`).

## Contents
- Add or remove a package
- Configure an app (new home module)
- Add a system-level module
- Add a keybind / window rule / autostart entry
- Add a helper script
- Add a custom package (pkgs/)
- Add a flake input
- Add a host
- Move desktop-only hardware out of core
- Update inputs, roll back, clean up
- Change the username, timezone, or keyboard layout

## Add or remove a package

1. Check that the package exists and get its attribute name: `nh search <name>`, or `nix eval --raw nixpkgs#<attr>.name` (uses the system registry nixpkgs; close enough to the pinned input).
2. Check that it isn't already declared: `rg -n '\b<attr>\b' modules hosts`.
3. Choose the file: a user tool goes in `modules/home/packages/{cli,dev,gui,nix}.nix` under the right `##` group. A tool that needs root or system integration (udev, services, setuid) goes in `environment.systemPackages` in a core module or host. One machine only goes in `hosts/<host>/default.nix`.
4. If a Home Manager module exists (`programs.<name>`), prefer a dedicated `modules/home/<name>.nix` with `programs.<name>.enable = true;` over a bare package.
5. When removing a package, grep for its binary in `modules/home/hyprland/`, `waybar/`, and `scripts/scripts/` first, because scripts and binds call tools by name.

## Configure an app (new home module)

1. Create `modules/home/<app>.nix` (single file) or `modules/home/<app>/<app>.nix` plus assets (multi-file). Use `<app>/default.nix` when the module itself is split across several Nix files (like `hyprland/` or `zed/`).
   ```nix
   { pkgs, ... }:
   {
     programs.<app> = {
       enable = true;
       settings = { };
     };
   }
   ```
   With no HM module, use a package plus a raw config file:
   ```nix
   { pkgs, ... }:
   {
     home.packages = with pkgs; [ <app> ];

     xdg.configFile."<app>/config.toml".source = ./config.toml;
   }
   ```
2. Add `./<app>.nix # short description` to `modules/home/default.nix`, keeping alphabetical order.
3. `git add` the new files, then validate.
4. If the app should open on a workspace or float, add window rules. If it should start at login, add it to `exec-once`. If it handles file types, add it to `xdg-mimes.nix`.
5. Theme it with the Gruvbox palette and Maple Mono ([theming.md](theming.md)).

## Add a system-level module

1. Create `modules/core/<topic>.nix` with `{ pkgs, username, host, ... }:` (only take the arguments you use).
2. Add it to `modules/core/default.nix`.
3. Remember that this applies to all four hosts. If it shouldn't, put it in the host file, or guard it with `lib.mkIf (host == "desktop") { ... }`.
4. To add the user to a group, append `users.users.${username}.extraGroups = [ "<group>" ];` (lists merge across modules, as `virtualization.nix` does).

## Add a keybind / window rule / autostart entry

1. Check for conflicts: `scripts/keybinds.sh desktop '<MODS>, <key>'`, e.g. `'SUPER SHIFT, D'` or `', Print'`. `$mod` is expanded to SUPER; a filter with a comma matches that exact combo, case-insensitive.
2. Keybind: append to `bind` in `modules/home/hyprland/binds.nix`, under the comment group that fits. Use `binde` for repeat, `bindl` for "works while locked", and `bindm` for mouse. Media and OSD keys belong in `swayosd.nix`.
3. Window rule: append to `windowrule` in `windowrules.nix` using the `match:` syntax. Get the class with `hyprctl clients`.
4. Autostart: append to `exec-once` in `exec-once.nix`. Daemons get a trailing ` &`. Use `"[workspace N silent] app"` to place apps.
5. Changes take effect after a switch, because Hyprland auto-reloads its config. Env vars in `variables.nix` need a re-login.

## Add a helper script

See [scripts.md](scripts.md). In short: create `scripts/scripts/<name>.sh` with a shebang, `git add` it, make sure its dependencies are installed, then call `<name>` from binds or Waybar.

## Add a custom package (pkgs/)

1. Create `pkgs/<name>/default.nix` as a `callPackage`-style function (see `pkgs/pomo/default.nix` for Go; `stdenv.mkDerivation`, `buildPythonPackage`, `rustPlatform.buildRustPackage` and the like work the same way).
2. Use `lib.fakeHash` (or `""`) for `hash`/`vendorHash`, run `nix build .#nixosConfigurations.desktop.pkgs.<name> --no-link`, and copy the `got:` hash from the error. Repeat for each hash.
3. Register it in `pkgs/default.nix`: `<name> = pkgs.callPackage ./<name> { };` (pass `inherit inputs;` if the source comes from a flake input).
4. Use it as `pkgs.<name>` in any module. `git add pkgs/<name>`.
5. Build test: `nix build .#nixosConfigurations.desktop.pkgs.<name> --no-link -L`.

## Add a flake input

1. Add it to `inputs` in `flake.nix`. Add `inputs.nixpkgs.follows = "nixpkgs";` when the flake supports it (to avoid a second nixpkgs). For a non-flake source, use `flake = false;` (like `maple-mono`).
2. Lock only that input: `nix flake update <input>` (or `nix flake lock`).
3. Use it through the `inputs` argument: a module via `imports = [ inputs.<x>.homeModules.<y> ];` (home) or `inputs.<x>.nixosModules.<y>` (system), or a package via `inputs.<x>.packages.${pkgs.stdenv.hostPlatform.system}.default`.
4. If the flake has a binary cache, add it to `nix.settings.substituters` and `trusted-public-keys` in `core/system.nix`. Caches only become active after a switch.

## Add a host

1. On the target machine: `nixos-generate-config --show-hardware-config > hosts/<host>/hardware-configuration.nix`.
2. Create `hosts/<host>/default.nix`:
   ```nix
   { pkgs, ... }:
   {
     imports = [
       ./hardware-configuration.nix
       ./../../modules/core
     ];
   }
   ```
   For laptops, copy the power-management block from `hosts/laptop` (Intel) or `hosts/p14s` (AMD).
3. Add a `nixosConfigurations.<host>` entry in `flake.nix` that mirrors the existing ones (`modules = [ ./hosts/<host> ]; specialArgs = { host = "<host>"; inherit self inputs username; };`).
4. Decide on the desktop-only core modules first (next recipe). Otherwise the new host gets the NVIDIA driver and waits for `/mnt/data` at boot.
5. If the host needs different font sizes or monitor-watcher, extend the `host == ...` conditionals in `ghostty.nix`, `gtk.nix`, and `exec-once.nix`.
6. `git add hosts/<host>`, then run `validate.sh <host>`. First install on that machine: `sudo nixos-rebuild switch --flake ~/nixos-config#<host>` (afterwards `nh os switch` works, because hostname = host).
7. `install.sh` only offers desktop, laptop and vm. Add the new host there if you want the installer to know about it.

## Move desktop-only hardware out of core

This is the recommended cleanup, and it changes nothing for the desktop:
1. Move the contents of `modules/core/hardware.nix` that are NVIDIA-specific (`services.xserver.videoDrivers`, `hardware.nvidia`, `hardware.nvidia-container-toolkit`) into `hosts/desktop/default.nix`. Keep `hardware.graphics` and the firmware setting in core. Also move `virtualisation.docker.daemon.settings.features.cdi` if desired.
2. Move `modules/core/filesystem.nix` into `hosts/desktop/` (import it from `hosts/desktop/default.nix`) and remove it from `modules/core/default.nix`, or add `"nofail"` to its options.
3. Verify the desktop is unchanged: the `drvPath` from `validate.sh desktop` should be identical before and after (pure moves). Other hosts' `drvPath`s will change; that's expected.

## Update inputs, roll back, clean up

- Update everything and switch: `nfu`. Update one input: `nix flake update <input>`, then `nfs`. Commit `flake.lock` as `chore: update`.
- Before switching after an update, compare: `nh os build` (prints an nvd diff), or `nvd diff /run/current-system ./result`.
- Roll back: pick an earlier generation in the systemd-boot menu (10 are kept), or run `sudo nixos-rebuild switch --rollback`. To revert config changes, use git (`git revert` / `git checkout <rev> -- <file>`).
- Clean up: `nc` (keeps 5). The automatic weekly clean keeps 5 generations or 7 days.
- Watch out after a nixpkgs bump: renamed options show up as evaluation warnings or errors (as `programs.ssh.matchBlocks` did). The NVIDIA `legacy_580` branch plus `linuxPackages_latest` can fail to build when the kernel moves ahead of the driver. The fix is to pin `boot.kernelPackages` (for example `pkgs.linuxPackages_6_12`) on the desktop.

## Change the username, timezone, or keyboard layout

- Username: `username` in `flake.nix` is the only source; everything else uses it. Exceptions: `SSH_AUTH_SOCK` hardcodes uid `1000`, and `install.sh` has `CURRENT_USERNAME='frostphoenix'`.
- Timezone and locale: `core/system.nix` (`time.timeZone = "Europe/Paris"`, inherited from upstream).
- Keyboard: `core/xserver.nix` (`xkb.layout`) and `hyprland/settings.nix` (`input.kb_layout`, `kb_options = grp:alt_caps_toggle`). The Waybar `hyprland/language` module has `format-fr`/`format-en` and a hardcoded keyboard device name.
