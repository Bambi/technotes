## Nix Flakes
Flake is intended to replace `shell.nix` (`nix-shell` -> `nix shell` / `nix develop`).
It uses the same Nix language but with a different API (stdenv). Its main advantages are:
- sticky verions with the `flake.lock` file for improved reproductinility
- faster (use a cache system)
- make it possible to use sub-project `flake.nix` files.

> **With Flakes, `nix-channel` is ignored and becomes ineffective**
> To enable flakes use `nix.setting.experimental-features = [ "nix-command" "flakes" ];` in your configuration.nix.

A flake is a source tree containing a `flake.nix` file with a specific structure to describe
[inputs and outputs](https://nixos.wiki/wiki/Flakes#Input_schema) for a Nix project.

`flakes.lock` is a manifest that locks inputs and records the exact versions in use.

A [Flake](https://nixos.wiki/wiki/Flakes) is an attribute set with
`inputs` (optional) and `outputs`.
`outputs` is a function with 2 arguments: `self` and `nixpkgs`.
`self` recursively references `outputs`.

The `nix flake init` produces in the current directory a simple `flake.nix` file.
Build it with `nix build`. By default it will build the `packages.<arch>.default`
attribute specified in the outputs attribute but you can specify an other one
with `nix build .#<attribute>`.

> Nix will build in the `$TMPDIR` directory or `/tmp` not set. Make sure you
> have enough space in your temporary directory!

A flake build will produce a `flake.lock` file which can be refreshed with the
`nix flake update` command.

By default `nixpkgs` in the `outputs` is the lastest nixpkgs available. You can
specify a specific version with the `inputs` attribute:
```nix
inputs {
  nixpkgs = {
    url = github:nixos/nixpkgs?ref=nixos_22.11
  };
};
```
A better way to import pkgs (instead of `legacyPackages`) is to define pkgs like this:
```nix
pkgs = import nixpkgs { system = "x86_64-linux"; };
```
A `flake.nix` file is an attribute-set with the followings properties:
- `description`: a string describing the flake
- `inputs`: an attrset specifying the inputs of the flake
- `outputs`: a function that yield the nix values provided by the flake
- `nixConfig`: a set of `nix.conf` options to be set when evaluating the flake

Standard flake input attribute-sets are:
- `type`: `"github", "sourcehut"`
- `id`: `"nixpkgs"`
- `repo`:
- `owner`:
- `flake`: `true/false`, if false the repo does not contain a `flake.nix` file

Standard flake [output schema attributes](https://nixos.wiki/wiki/Flakes) are:
- `devShells.${system}.default`: used with `nix develop command`.
- `formatter.${system}`
- `homeConfigurations`: used with `home-manager` command.
  AttrSet of HM configurations each done with `lib.homeManagerConfiguration` function.
- `homeManagerModules`: modules used by HM.
- `nixosConfigurations.<hostname>`: used with `nixos-rebuild --flake .#<hostname>` command.
- `nixosModules`: modules used by NixOs.
- `packages.${system}.default`: used with `nix build` command.
- `apps.${system}.default`: used with `nix run` command. 
- `overlays`: custom packages and modifications.
- `hydraJobs`:
- `nixConfig`:
- `checks`: executed with `nix flake check`.
- `templates`: used with `nix flake init -t <flake>#<name>`.

`${system}` refers to a string, which corresponds to the runtime system of the package.
For example on a `x86_64-linux` system the `nix build` command will automatically
pick the `packages.x86_64-linux` output.

### Commands
- `nix flake show`: show outputs produced
- `nix flake metadata`: show urls used
- `nix flake check`: perform flake checks
Common nix commands working with flakes:
- `nix develop`: Enters a development shell with all the required development tools
  available.
  uses `outputs.devShells."SYSTEM".default`.
- `nix shell`: Enters a runtime shell where the flake’s executables are available
  on the `$PATH`.
- `nix build`: Builds the flake and puts the output in the `result` directory.
  uses `outputs.packages."SYSTEM".default`.
- `nix run`: Runs the flake’s default executable, rebuilding the package first if needed.
  (runs the version in the Nix store, not the version in `result`).
- `nixos-rebuild`: builds a nixos system.
  uses `outputs.nixosConfigurations."SYSTEM".default`.
- `home-manager`: builds a home configuration.
  uses `outputs.homeConfigurations."SYSTEM".default`.

### References
- [Nix Flakes Tutorial](https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/flakes.html)
- [Nix Flakes](https://edolstra.github.io/talks/nixcon-oct-2019.pdf)
- [Nix Flakes Examples and Tutorial](https://www.tweag.io/blog/2020-05-25-flakes/)
- [Practical Nix Flakes](https://serokell.io/blog/practical-nix-flakes)
- [Nix Flake Architecture in Practice](https://journal.platonic.systems/nix-flake-architecture-in-practice/)
- [Making a dev shell with nix flakes](https://fasterthanli.me/series/building-a-rust-service-with-nix/part-10)
- [Nix Community Templates](https://github.com/nix-community/templates)
- [Nix flake templates](https://github.com/the-nix-way/dev-templates)
- [Packaging Pre-built Binaries with Nix Flake](https://blog.sekun.net/posts/packaging-prebuilt-binaries-with-nix/)
- [How to create your own Neovim flake](https://primamateria.github.io/blog/neovim-nix/)
- [Practical Nix flake anatomy: a guided tour of flake.nix](https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/)
