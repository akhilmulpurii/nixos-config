# Architecture

## Contents
- Flake inputs
- Outputs and argument flow
- Hosts matrix
- Core (NixOS) modules
- Home Manager integration
- Overlay and custom packages
- State outside Nix

## Flake inputs

| Input | Source | Used in | Purpose |
|---|---|---|---|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-unstable` | everywhere | Package set (unstable channel) |
| `home-manager` | `github:nix-community/home-manager` (follows nixpkgs) | `core/user.nix` | User environment, as a NixOS module |
| `nix-flatpak` | `github:gmodena/nix-flatpak` | `core/flatpak.nix` | Declarative flatpaks. Imported but `services.flatpak.enable = false` |
| `nix-index-database` | `github:nix-community/nix-index-database` (follows nixpkgs) | `home/packages/nix.nix` | Prebuilt nix-index database and `comma` (`, cmd`) |
| `maple-mono` | `github:subframe7536/maple-font?ref=v7.8`, `flake = false` | `pkgs/maple-mono` | Font source tree, built locally with custom features |
| `superfile` | `github:yorukot/superfile` | `home/superfile/superfile.nix` | Terminal file manager (`inputs.superfile.packages.${system}.default`) |
| `zen-browser` | `github:0xc000022070/zen-browser-flake/beta` | `home/browser.nix` | Default browser (`inputs.zen-browser.homeModules.beta`, binary `zen-beta`) |

`superfile` and `zen-browser` do not follow nixpkgs, so each brings its own nixpkgs copy into `flake.lock`.

The flake `description` still reads "FrostPhoenix's nixos configuration". The `let` bindings `pkgs` and `lib` in `outputs` are unused.

## Outputs and argument flow

```
flake.nix
└─ nixosConfigurations.<host> = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     modules = [ ./hosts/<host> ];
     specialArgs = { host = "<host>"; inherit self inputs username; };   # username = "akhil"
   }
   └─ hosts/<host>/default.nix
        imports: ./hardware-configuration.nix, ../../modules/core
        └─ modules/core/default.nix  (imports every core module)
             └─ user.nix → home-manager.users.akhil.imports = [ ../home ]
                  extraSpecialArgs = { inputs, username, host }
                  └─ modules/home/default.nix (imports every home module + ../../scripts/scripts.nix)
```

There are no other outputs (no `packages`, `devShells`, `formatter`, `checks`, or `homeConfigurations`). Home Manager only runs as part of the NixOS rebuild; there is no standalone `home-manager switch`.

To add a reusable argument for every module, add it to both `specialArgs` (in all four host entries in `flake.nix`) and `extraSpecialArgs` (in `core/user.nix`).

## Hosts matrix

| Host | Hardware | Root filesystem | Host-specific config (`hosts/<host>/default.nix`) |
|---|---|---|---|
| `desktop` | Intel CPU, NVIDIA GPU (the machine currently in use, hostname `desktop`) | btrfs (root on the top-level volume, `home` and `nix` subvolumes), plus swap and the `/mnt/data` ext4 disk | `cpuFreqGovernor = "performance"` |
| `laptop` | Intel | ext4 + swap | acpi, brightnessctl, cpupower-gui, powertop; power-profiles-daemon; upower (critical action PowerOff); `tlp.settings` (tlp is NOT enabled, so these settings do nothing); `acpi_call` kernel module |
| `p14s` | ThinkPad P14s, AMD CPU/GPU | ext4 + swap | amdgpu_top, nvtop (AMD), lm_sensors; power-profiles-daemon; upower (HybridSleep); `amd_pstate=active`; `thinkpad_acpi`; a systemd oneshot and udev rules that switch the power profile on AC/battery (balanced vs power-saver) |
| `vm` | QEMU/KVM guest | ext4, no swap | GRUB on `/dev/vda` (systemd-boot is force-disabled with `lib.mkForce false`); openssh with password auth and root login enabled |

Shared modules use `host` conditionally in these places:
- `home/ghostty/ghostty.nix`: font-size 20 on p14s, otherwise 16
- `home/gtk.nix`: GTK font size 14 on p14s, otherwise 12
- `home/hyprland/exec-once.nix`: `monitor-watcher` only runs on `p14s` and `laptop`
- `core/network.nix`: `networking.hostName = host`

## Core (NixOS) modules

All are imported by `modules/core/default.nix` (`qmk.nix` is commented out). They apply to EVERY host.

| File | What it does |
|---|---|
| `nixpkgs.nix` | Overlay that injects `pkgs/default.nix` (custom packages) |
| `bootloader.nix` | systemd-boot (EFI, keeps 10 generations), `linuxPackages_latest`, kernel module `hid-nintendo`, NTFS support |
| `hardware.nix` | Graphics with 32-bit support, redistributable firmware, **NVIDIA proprietary driver** (`open = false`, `branch = "legacy_580"`, modesetting), `nvidia-container-toolkit`. Desktop-only hardware applied to all hosts |
| `xserver.nix` | X server (needed for LightDM, the implicit display manager), `xkb.layout = "us,fr"`, no xterm, **autologin** for `username`, libinput, systemd stop timeout 10s |
| `wayland.nix` | `programs.hyprland.enable` (the system Hyprland package), xdg-desktop-portal with gtk + hyprland |
| `network.nix` | hostname, NetworkManager, static DNS (8.8.8.8, 8.8.4.4, 1.1.1.1), firewall open on TCP 22/80/443/59010/59011 and UDP 59010/59011, nm-applet |
| `bluetooth.nix` | Bluetooth (not powered on at boot), blueman |
| `fonts.nix` | fontconfig defaults: monospace Maple Mono then JetBrainsMono Nerd Font; sans Public Sans; serif Noto Serif; emoji Noto Color Emoji. Installs `maple-mono-custom`, noto, public-sans, nerd-fonts (jetbrains-mono, symbols-only) |
| `nh.nix` | `programs.nh` with flake path `/home/${username}/nixos-config`; weekly automatic clean with `--keep-since 7d --keep 5` |
| `pipewire.nix` | PipeWire with pulse, ALSA (32-bit), wireplumber; ALSA state persistence; alsa-utils |
| `program.nix` | dconf, system zsh, gnupg agent with SSH support, AppImage, nix-ld (no extra libs) |
| `security.nix` | rtkit, sudo, and gnome-keyring unlock through PAM for swaylock and hyprlock |
| `services.nix` | gvfs, tinysparql, gnome-keyring, dbus (with gcr and gnome-settings-daemon), fstrim, fwupd, udisks2; logind ignores the power key and ignores lid close when docked |
| `system.nix` | Nix settings (auto-optimise, flakes, 500 MB download buffer), extra binary caches (nix-community, hyprland, ghostty cachix), wget and git, timezone `Europe/Paris`, locale `en_US.UTF-8`, `allowUnfree`, `stateVersion = "26.05"` |
| `flatpak.nix` | nix-flatpak module; disabled; if enabled it installs Flatseal and forces Wayland |
| `user.nix` | Home Manager wiring (see below) and the user `akhil` (groups networkmanager, wheel; shell zsh); `nix.settings.allowed-users` |
| `virtualization.nix` | Docker (CDI enabled for the NVIDIA toolkit), libvirtd with swtpm, SPICE USB redirection, spice-vdagentd, virt-manager/viewer, virtio-win; user added to `libvirtd` and `docker` groups |
| `filesystem.nix` | Mounts `/mnt/data` (ext4, UUID `0da7cad3-...`). **This disk only exists on the desktop**, and without `nofail` other hosts wait for it at boot |
| `qmk.nix` (disabled) | via, vial, qmk with their udev rules |

## Home Manager integration

From `core/user.nix`:
- `useGlobalPkgs = true`: Home Manager uses the system `pkgs`, including the overlay and `allowUnfree`.
- `useUserPackages = true`: `home.packages` installs to `/etc/profiles/per-user/akhil`.
- `backupFileExtension = "hm-backup"`: conflicting files are renamed instead of causing a failure.
- `home.stateVersion = "26.05"`, `programs.home-manager.enable = true`.

To reach Home Manager options from the NixOS side (in evals): `config.home-manager.users.akhil.<option>`.

## Overlay and custom packages

`core/nixpkgs.nix`:

```nix
nixpkgs.overlays = [
  (final: prev: (import ../../pkgs { inherit inputs; inherit pkgs; inherit (prev) system; }))
];
```

`pkgs/default.nix` returns an attribute set of `pkgs.callPackage` calls:
- `maple-mono-custom`: builds Maple Mono v7.8 from the `maple-mono` input with Python tooling: `build.py --no-nerd-font --feat cv66,ss05 --remove-tag-liga --ttf-only`. Installs TTF-AutoHint fonts. It defines three Python packages inline (`ufo_extractor`, `foundrytools`, `foundrytools_cli`). Slow to build; not cached anywhere.
- `pomo`: `buildGoModule` of Bahaaio/pomo v0.9.0 (TUI Pomodoro timer).

## State outside Nix

These are not reproduced by a rebuild and must exist (or be recreated) by hand:

| Path | Created by | Used by |
|---|---|---|
| `~/Pictures/wallpapers/others/*` | `install.sh` copies `wallpapers/otherWallpaper/{gruvbox,nixos}/*` | wallpaper-picker, random-wallpaper, waypaper |
| `~/Pictures/wallpapers/wallpaper` (symlink) | `install.sh`, then the wallpaper scripts | init-wallpaper (awww) |
| `~/.config/hypr/monitors.conf`, `workspaces.conf` | `nwg-displays` GUI | sourced by `hyprland/monitors.nix` (missing files are ignored) |
| `~/.ssh/id_github` | user | `home/ssh.nix` GitHub host block (connects over port 443 via ssh.github.com) |
| Browser profile and extensions | user | zen-browser (only installation and default-browser are declarative) |
| `~/Pictures/Screenshots` | `screenshot` script (`mkdir -p`) | screenshot |
| libvirt VM `win10` | user | `vm-start` script |

Hyprlock's background, on the other hand, is referenced from the repo itself (`wallpapers/otherWallpaper/gruvbox/forest_road.jpg`), so it is copied into the store.
