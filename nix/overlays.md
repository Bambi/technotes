## Overriding And Overlays
Overriding consist of modifying a package and producing a new separate package.
Overlays consist of modifying a package without producing a separate package, the new
package will replace the original one.

There are 2 main functions that can be used: `override` overrides arguments of a function
(i.e. the dependencies of a package), and `overrideAttrs` overrides the package definition itself:
```nix
{ stdenv, bar, baz }: # this part gets overriden by `override`
stdenv.mkDerivation { # This part gets overriden by overrideAttrs
  pname = "test";
  version = "0.0.1";
  buildInputs = [bar baz];
  phases = ["installPhase"];
  installPhase = "touch $out";
}
```
