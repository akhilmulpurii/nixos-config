# Troubleshooting

## Contents
- Evaluation errors
- Build errors
- Activation and runtime problems
- Known issues and tech debt (inherited from the fork)

## Evaluation errors

**`error: Path '<file>' in the repository "/home/akhil/nixos-config" is not tracked by Git.`** (older Nix: `path '/nix/store/...-source/<file>' does not exist`)
Cause: the file is new and untracked, so the flake source doesn't include it.
Fix: `git add <file>` (staging is enough; no commit needed). `validate.sh` warns about this.

**`error: The option 'programs.foo' does not exist`**
Cause: the option name is wrong, belongs to the other module system (NixOS vs Home Manager), or comes from a flake module that isn't imported.
Fix: look up the option on [search.nixos.org/options](https://search.nixos.org/options) (NixOS) or the Home Manager options search. Home modules can only use HM options; to set a NixOS option from home code, move that code to `modules/core`. Check existing values with `scripts/query-option.sh`.

**`error: The option '...' is defined multiple times` / `conflicting definition values`**
Cause: two modules set the same scalar option. Lists and attribute sets merge; strings and booleans don't.
Fix: keep one definition, or use `lib.mkForce` in the more specific place (as `hosts/vm` does for systemd-boot) or `lib.mkDefault` in the generic one.

**`error: undefined variable 'host'` (or `inputs`, `username`)**
Cause: the variable isn't in the module's argument list.
Fix: add it to the header (`{ pkgs, host, ... }:`). Home modules do not get `self`.

**`error: attribute 'foo' missing` on `pkgs.foo`**
Cause: the package was renamed or removed in nixpkgs unstable, or it's a custom package that isn't registered in `pkgs/default.nix`.
Fix: `nh search foo`; for custom packages, add `callPackage` to `pkgs/default.nix`.

**`error: infinite recursion encountered`**
Common cause: using `config` inside `imports`, or `pkgs` inside a top-level `imports` path.
Fix: imports must be static paths or come from `inputs`.

**Evaluation warning: `programs.ssh.matchBlocks ... is deprecated. Use programs.ssh.settings`**
This is a known warning from existing code (`modules/home/ssh.nix`) and is harmless. Migrating it is a good first cleanup.

## Build errors

**`hash mismatch in fixed-output derivation` / `specified: sha256-AAA... got: sha256-...`**
Fix: copy the `got:` value into `hash`/`sha256`/`vendorHash`. For `fetchFromGitHub`, the hash changes whenever `rev` changes.

**The Maple Mono build is slow or fails**
`pkgs/maple-mono` builds the font from source with Python tooling, and no cache has it. If a Python dependency breaks after a nixpkgs bump, check `ufo_extractor`/`foundrytools`/`foundrytools_cli` (inline in that file) against upstream versions. As a temporary workaround, switch `fonts.nix` to `pkgs.maple-mono.truetype` (the nixpkgs build).

**The NVIDIA module fails to build against the kernel**
Cause: `linuxPackages_latest` moved ahead of the `legacy_580` driver branch.
Fix: pin `boot.kernelPackages` on the desktop (for example `pkgs.linuxPackages_6_12`), or update the NVIDIA branch.

**Out of memory during a large build**
Add `--cores 4` (nixos-rebuild) or `-- --cores 4` (nh), or reduce `max-jobs`.

## Activation and runtime problems

**`Existing file '/home/akhil/.config/X' is in the way of '/nix/store/...'`**
Home Manager moves it to `X.hm-backup`. If that backup already exists, activation fails. Delete or merge the old `.hm-backup` and retry.

**`home-manager-akhil.service` failed after a switch**
Check `journalctl -u home-manager-akhil.service -b`. It's usually a file conflict (above) or a dconf write outside a session.

**A new command isn't found after a switch**
Open a new shell (or run `hash -r`). For session variables, log out and back in.

**A Hyprland bind does nothing**
Check that the command exists (`which <cmd>`), that its dependencies are installed, and look at `hyprctl configerrors`. A key also won't fire if it's already taken; check with `scripts/keybinds.sh`.

**A window rule doesn't apply**
Check the exact class or title with `hyprctl clients`. Rules use regex inside `^( )$`, and the `match:` syntax is required (the legacy `windowrulev2` form isn't supported).

**Laptop or VM waits about 90 s at boot for `/dev/disk/by-uuid/0da7cad3-...`**
The desktop's `/mnt/data` mount is in core. See "Move desktop-only hardware out of core" in [recipes.md](recipes.md).

**The VM has a black screen or Hyprland won't start**
Hyprland needs working GPU acceleration (virtio-gl / 3D acceleration). The core NVIDIA settings don't help in a VM. See the Hyprland wiki VM guide.

**SSH or git push asks for a passphrase every time, or the agent is confused**
Two agents are configured: `programs.gnupg.agent.enableSSHSupport` (system) and `services.ssh-agent` (HM, socket `/run/user/1000/ssh-agent`, which is what `SSH_AUTH_SOCK` points to). Keep one of them.

## Known issues and tech debt (inherited from the fork)

These are leftovers from Frost-Phoenix's upstream. Mention them when they're relevant to the task, but don't fix them unless asked:

| Item | Location |
|---|---|
| NVIDIA driver and container toolkit applied to all hosts | `modules/core/hardware.nix` |
| `/mnt/data` mount applied to all hosts, without `nofail` | `modules/core/filesystem.nix` |
| `treefmt.toml` passes `-sv` to nixfmt; strict mode conflicts with the repo style | `treefmt.toml` (drop `-s`, keep `-v -w 80`) |
| Three `.nix` files fail a plain `nixfmt --check` | `hosts/desktop/hardware-configuration.nix` (generated), `modules/home/xdg-mimes.nix`, `scripts/scripts.nix` |
| Flake description still says "FrostPhoenix's"; unused `pkgs`/`lib` let bindings | `flake.nix` |
| README and install banner are upstream's (links, screenshots, credits) | `README.md`, `install.sh` |
| `install.sh`: `CURRENT_USERNAME='frostphoenix'` (the username sed is a no-op now), host list lacks `p14s`, clears the upstream git identity with sed, toggles aseprite with a sed on line 3 | `install.sh` |
| `fp:` git URL alias points to frost-phoenix | `modules/home/git.nix` |
| `discord` MIME handler is `webcord.desktop`, but Vesktop is installed | `modules/home/xdg-mimes.nix` |
| `tlp.settings` set without `services.tlp.enable` (and tlp conflicts with power-profiles-daemon) | `hosts/laptop/default.nix` |
| `pkgs.cpupower-gui` listed in `boot.extraModulePackages` (it isn't a kernel module) | `hosts/laptop/default.nix` |
| `programs.ssh.matchBlocks` deprecated | `modules/home/ssh.nix` |
| Two SSH agents (gnupg and ssh-agent) | `core/program.nix`, `home/ssh.nix` |
| `QT_QPA_PLATFORMTHEME=qt5ct` and `QT_STYLE_OVERRIDE=kvantum` set, but neither is installed | `home/hyprland/variables.nix` |
| `SSH_AUTH_SOCK` hardcodes uid 1000 | `home/hyprland/variables.nix` |
| Timezone `Europe/Paris` and the `us,fr` layouts come from upstream; confirm with the owner before changing | `core/system.nix`, `core/xserver.nix`, `hyprland/settings.nix` |
| `toggle-mic.sh` shebang is missing `!` | `scripts/scripts/toggle-mic.sh` |
| No idle lock or suspend daemon (hypridle) | none |
| `aseprite.nix` is an empty module; `qmk.nix` and flatpak are disabled | `modules/home/aseprite/`, `modules/core/` |
| VM host allows root and password SSH login | `hosts/vm/default.nix` |
| Firewall opens 22/80/443/59010/59011 on all hosts, even though sshd only runs on vm | `modules/core/network.nix` |
