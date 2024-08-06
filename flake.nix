{
  description = "Home directory configurations";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = { self, nixpkgs, ... }:
  let
    # system = builtins.currentSystem;
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    # pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
    pythonEnv = pkgs.python3.withPackages (ps: with ps; [ mkdocs pygments ]);
  in
  {
    formatter.${system} = pkgs.alejandra;

    # DevShell
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        pythonEnv
      ];
    };
  };
}

