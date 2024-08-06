{ pkgs ? import <nixpkgs> { } }:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [ mkdocs pygments ]);

in
pkgs.mkShell {
  packages = [
    pythonEnv
  ];

  shellHook = ''
  echo mkdocs installed
  '';
}
