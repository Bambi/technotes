## Home Manager
Specify a user environment (software and configuration) with the Nix language.
Can be used with or without NixOS.

### Home Manager as a NixOS Module
Can be used only on NixOS with the folowing procedure:
- add home-manager channel with `sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager`
  followed by `sudo nix-channel --update`.
- add home-manager to your NixOS `configuration.nix` file with `import <home-manager/nixos>`.
- add user configuration with:
```nix
home-manager.users.as = { pkgs, ... }: {
  home.stateVersion = "23.05";
  home.packages = [ pkgs.bat pkgs.git ];
}
```
- update configuration with `sudo nixos-rebuild switch`

With this solution you update your home configuration together with your
system configuration. This might be an advantage when building a virtual
machine or a container.

### Standalone Home Manager
Only solution if you do not use NixOS:
- add and update home-manager channel with same commands as previous without `sudo`.
- install home-manager with either:
  - `nix-env -iA nixos.home-manager` if you use nix without NixOS.
  - `nix-shell '<home-manager>' -A install` if you use NixOS.
- configure your environment with the `~/.config/home-manager/home.nix` file.
- update your configuration with the command `home-manager switch`.

### Schema
There is a [manual](https://nix-community.github.io/home-manager/) and an
[option search](https://mipmip.github.io/home-manager-option-search/).
Most important data are:
- `home.username`
- `home.homeDirectory`
- `stateVersion`
- `xdg.*`: to manage XDG directories
- `wayland.windowManager.*`: to manage either hyprland or sway
- `services.*`: to manage some services
- `programs.*`: to install and configure some programs

### References
- [journal Linuxfr NixOS/Home-manager](https://linuxfr.org/users/nokomprendo-3/journaux/gerer-son-environnement-utilisateur-nixos-avec-home-manager)
- [Simple NixOS/Home-manager Configuration](https://gitlab.com/nokomprendo/nixos-20.09_config)
- [Home Manager Options](https://mynixos.com/home-manager/options)
- [Home Manager Example](https://github.com/behoof4mind/nix-home-manager-example)
