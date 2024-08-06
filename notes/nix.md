# Nix Ecosystem
Nix is a language, a package manager (written with the Nix language) and a
Linux distribution (NixOS) using the Nix package manager.

## Package Management
Nix stores all packages into a common place called the Nix store, usually located at `/nix/store`.
Each package is stored is stored in a unique subdirectory.
The package path is composed of a cryptographic hash of all the package inputs followed by the package name.
This system allow the presence of multiple version of the same package.
To make package available to the user rely on environment variables manipulation.

### Profiles
A profile describes an environment (a set of packages that are made available to the user).
A user have a default (or current) profile (`~/.nix-profile`) but one can create new profiles.
Profiles are managed with the command `nix-env`.

`nix-env --switch-profile=PATH` makes your default profile point to an other profile.
If PATH does not exist it will be created.
All nix-env commands take an optional `-p PATH` argument which specify the profile
to use. If not present it will use the default profile.

[Nix Packages](https://search.nixos.org/packages) can be installed with the
`nix-env -iA nixpkgs.<pkg>` command.

`nix-env -q` will show currently installed packages.

`nix-env --rollback` go back to the previous modification of the profile.

`nix-env -e <pkg>` to remove a package from the profile.

If you do `nix-env -e '*'` it will remove all packages from the environment,
including `nix`.

Each time a `nix-env` operation is done a new _generation_ is created.
You can list generations with `nix-env --list-generations` and restore a
generation with `nix-env --switch-generation <gen number>`.
(use `nix-env --delete-generations <space-separated gen list>` to free some space
or `nix-env --delete-generations old`).

To rollback you can also locate a nix derivation in the nix store
(`ls /nix/store/*-nix*`) and either:
- rollback: `/nix/store/<nix-path>/bin/nix-env --rollback`
- install nix again: `/nix/store/<nix-path>/bin/nix-env -i /nix/store/<nix path>/bin/nix-env`

### Profiles with `nix profile`
This is the new command for profiles instead of `nix-env`.
- `nix profile install nixpkgs#jq` install the jq package from the `nixpkgs` registry
  in the default profile `~/.nix-profile`. Use the `--profile <path>` arg to use
  an other profile.
- `nix profile remove` uninstall a package.
- `nix profile list` list installed packages.
- `nix store gc` delete packages ony used by deleted profiles or generations.
- `nix profile wipe-history [--older-than 30d]` will delete older generations of
  a profile (by default it will delete all non current).

### Channels
The packages available in Nix are defined in a git repository that contains
the definition of all the packages. A channel, can be seen as a nixpkgs (git) branch.

`nix-channel --list` list channels installed on the system.

The default Nix installer add the unstable nixpkgs channel which is a rolling-release
channel. You can update your packages with:
```console
nix-channel --update
nix-env -iA nixpkgs.nix nixpkgs.cacert
```
if no channel is installed you must add one with the command:
`nix-channel --add https://nixos.org/channels/nixpkgs-unstable`


## Language
You can use `nix repl` to get a Nix language interpretor.

Values in the Nix language can be primitive data types, lists, attribute sets, and functions.

To assign names to values use: attributes sets (structures) or let expression (variables)
with the `=` sign: on the left is the assigned name and on the right is the value
delimitted by a `;`.

### Primitive Data Types
Integers: `1`. Strings are declared between double quotes: `"string"`.

String interpolation `${ ... }` allow inserting a nix expression in a string:
```nix
let
  name = "Nix";
in
"hello ${name}"
```
Multi-line (or indented) strings are denoted by double single quotes:
```nix
''
multi
line
string
''

"multi\nline\nstring\n"
```

File system path are directly inserted (without quotes). Absolute path start
with a `/` and relative path does not but must contains a least one `/`.
Relative path are relative to the file containing the expression.

Search path are between angle brackets: `<nixpkgs>`.

### Lists
Lists are defined with `[]` and each element are separated with spaces.

### Atribute Sets
Attribute sets are a collection of name-value pairs, where names must be unique:
```nix
{
  bool = true;
  int = 1;
  attribute-set = {
    str = "hello";
    lst = [ 1 "val" ];
  };
}
```
Recusive attribute set allows access to attributes from within the set:
```nix
rec {
  one = 1;
  two = one + 1;
}
```
Atributes in a set are accessed with a `.`. Ex: `rec.one`.

### Let Expressions
Let expression allow defining local variables for inner expressions:
`let <variable list>; in <expression>`.

```nix
let
  a = 1;
in
  a + a
```
will evaluate to 2.

### With Expressions
`with` expression allows access to attributes without repeatedly referencing their attribute set:
`with <attribute set>; <expression>`

```nix
with a; [ x y z ];  ~>  [ a.x a.y a.z ];
```
Attributes made available through `with` are only in scope of the expression following the semicolon.

### If Expressions
`if <bool> then <expr> else <expr>`.
```nix
if a > b then "yes" else "no"
```
You can't have only the then branch, you must specify also the else branch,
because an expression must have a value in all cases.

### Inherit
`inherit` is used to repeat an attribute. `inherit perl` is equivalent to `perl = perl`.

### Functions
A function always takes exactly one argument. Argument and function body are separated by a colon (`:`).
on the left is the function argument and on the right is the function body.

Examples: single arg, attribute set arg, with default attributes, additional attributes allowed:
```nix
x: x + 1
{ a, b }: a + b
{ a, b ? 0 }: a + b
{ a, b, ...}: a + b
```
Functions have no names (lambda). Assign them to a variable to reference them:
```nix
f = arg : "prefix ${arg}"
```

To have more than 1 argument, either:

- use multiple functions each with one parameter.
```nix
  x = a: b: "${a} ${b}"  # same as x = a: (b: "${a} ${b}")
  (x "stra") "str b" # same as x "stra" "strb"
```
  You can make partial evaluation:
```nix
  y = x "str a"
  y "str b"
```

- use a structure as the argument.
```nix
  {a, b}: "${toString a} ${toString b}"
```
  and it is possible to declare a default value for an argument:
```nix
  {a, b ? 2}: "${toString a} ${toString b}"
```

### Calling Functions
Write the argument after the function:
```nix
let
  f = x: x + 1;
in f 1
```

### Builtins
`builtins` are functions built into the language. They are described in the
[manual](https://nixos.org/manual/nix/stable/language/builtins.html)
and can be listed with `builtins.toString`. Most used are `toJSON`, `fromJSON`,
`toPath`, `fromPath`, `fetchGit`, `fetchTarball`.

### Import
`import` takes a path to a Nix file, reads it to evaluate the contained Nix expression,
and returns the resulting value.

The [nixpkgs](https://github.com/NixOS/nixpkgs) repository contains an attribute set
called `lib`, which provides a large number of useful functions.
They are described [here](https://nixos.org/manual/nixpkgs/stable/#sec-functions-library).
```nix
let
  pkgs = import <nixpkgs> {};
in
pkgs.lib.strings.toUpper "search paths considered harmful"
```
Import works with a file (`import ./fic.nix`) or NIX_PATH entries (`import <nixpkgs>`)
which contains named aliases for file paths containing Nix expressions.

### Operators
- `++`: List concatenation: `[ a ] ++ [ b ] -> [ a b ]`.
- `//`: Attribute sets merge (union of the 2 sets): `{ a; } // { b; } -> { a; b; }`.
  In case of conflicts between the attributes, the value on the right is prefered.

### Nix Idoms
Not part of the language specification, but will commonly be encountered in the
Nix community.

#### File Lambdas
A Nix file define a function that receives the files dependencies, instead of
importing them directly in the file (allowing users of your code to change some
dependencies with `import ./fic.nix { dep1 = x ... }`).

#### callPackage
Building on the previous pattern, a file (which need for ex `stdenv` as dependency)
can be imported with the `callPackage` function:
`let my-funky-program = pkgs.callPackage ./my-funky-program.nix {};`.
The callPackage function looks at the expected arguments (via builtins.functionArgs,
`stdenv` in this example) and passes the appropriate keys from the set in which
it is defined as the values for each corresponding argument (whithout having to
explicitely specify them).

### Overriding
One of the most powerful features of Nix is that the representation of all build
instructions as data means that they can easily be overridden to get a different result.
(in Nix, overriding functions make change to a package and return only a single package,
while overlays can be used to combine the overridden packages across the entire
package set of Nixpkgs.)


## Nix Files
Nix commands can be stored in a file and interpreted with `nix eval -f <file>`.
A file can only have 1 Nix expression and return 1 result.
Use the `let` operator to have more expressions.

Use the `import` operator to use an expression from an other file:
```nix
let
  a = 1;
  b = 2;
  f = import ./file.nix;
in
  f a b
```
Common Nix files used are:
- `shell.nix`: default file used with the `nix-shell` command.
- `default.nix`: default file used with the `nix-build` command.
  or the `nix-shell` command if no `shell.nix` found.
  Use `callPackage` to import `derivation.nix`.
- `derivation.nix`: nixpkgs style derivation file.
- `flake.nix`: default file used with the `nix shell` and `nix develop` commands.
- `module.nix`: NixOS module file, import `default.nix`.
- `test.nix`: NixOS test file.
- `release.nix`: Hydra jobset declaration.


## Nix Shell
Nix shell has two purposes:
- opening a shell to use a package (ex `nix-shell -p hello`).
- opening a shell to build a project interactively (ex `nix-shell '<nixpkgs>' -A hello`)
  producing a shell where `buildPhase` is available to build `hello`.

If you want a shell to _use_ a package [you should use flakes](https://discourse.nixos.org/t/shell-nix-but-with-flakes/18775).

`shell.nix` file contains a function which takes a package as the parameter:
```nix
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {}
```
The function is evaluated with the `nix-shell <file> [--pure]` command
(the `--pure` option does not import environment variables from the current shell).

Use `mkShell` function with `buildInput` argument to install software:
```nix
{pkgs ? import <nixpkgs> {}}:
  pkgs.mkShell {
    buildInputs = with pkgs; [cowsay sl];
    # buildInputs = [pkgs.cowsay pkgs.sl];  # same expression
  }
```


## Nix Derivation
A derivation is a set of building instructions and associated inputs
(such as the compiler) needded to build a package and is written in the Nix language.
Derivations can be written for packages or even entire systems.
Derivations depends only on pre-defined set of inputs, so they are reproductible.
They are built (realized) with the Nix package manager.

A derivation is a special type of attibute-sets created with the `derivation`
function. The Nix package manger will then evaluate this derivation, and use the
result to copy the built package into the Nix store. The set passed to the
`derivation` function have 3 mandatory attributes:
- `system` which defines the architecture and the OS of the package (`any` if it
  is portable to any architectures).
- `name` which is the package name.
- `builder` is a program to run to build the derivation.
```nix
derivation {
  builder = ./builder.sh;
  src = ./hello.sh;
  system = "any";
}
```
Can be built with `nix build -f <fic.nix>`.
Because a derivation is build in a bare sandbox environment (with only sh and
no coreutils) it is usualy better to use `stdenv.mkDerivation`:
- the default sandbox is provided with a bash interpreter, coreutils, tar, gzip,
  patch, C and C++ compiler, patchelf etc.
- easy way to add extra dpendencies.
- provide a default builder `./configure && make`.
It also provides a few useful environment variables:
- `$name` is the package name.
- `$src` refers to the source directory.
- `$out` is the path to the location in the Nix store where the package will be added.
  This is where build artefacts should be installed.
- `$system` is the system that the package is being built for.
- `$PWD` and `$TMP` both point to a temporary build directories
- `$HOME` and `$PATH` point to nonexistent directories, so the build cannot rely on them.

`nix build .#` will build the entry defined in `packages.<system>.default` in the output of the
`flake.nix` file. You can also build a specific entry with ex `nix build .#packages.x86_64-linux.debug`.

### [mkDerivation](https://blog.ielliott.io/nix-docs/mkDerivation.html)
stdenv.mkDerivation is a function that helps you produce a derivation from source.
It divides the build into _phases_, all of which include a bit of default behavior.
Most important phases are:
- _unpack_: untar, unzip or copy yours sources into the nix store
- _patch_: apply any patch provided in the `patches` variable
- _configure_: runs `./configure` or any equivalent depending on the build system
- _build_: runs `make` or equivalent
- _check_: runs `make check` or equivalent, skipped by default
- _install_: runs `make install` or equivalent
- _fixup_: automagically fixes up things that do not work well with the nix store
  such a incorrect interpreter paths
- _installCheck_: runs `make installCheck` or equivalent

Core attributes:
- `pname`: package name
- `version`: package version
- `name`: derivation name, defaults to `${pname}-${version}`
  either pname+version or name is required
- `src`: path to package source directory
- `buildInputs`: build-time dependencies with the same arch than the hostPlatform.
  Derivation can link agains those inputs. Usually for libraries.
- `nativeBuildInputs`: only available on the buildPlatform and used at build-time.
  Used for cross-compilation. Usually for build tools.
- `*Phase`: bash commands to execute for each phase.
- `checkInputs`, `nativeCheckInputs`: lib/tools used for checks.
- `doCheck`: (true/false), enable checks (disabled by default).

> for generic hash use `hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";`

References:
- [Building a Nix Package](https://elatov.github.io/2022/01/building-a-nix-package/)
- [Proper mkDerivation](https://github.com/samdroid-apps/nix-articles/blob/master/04-proper-mkderivation.md)
- [Nix Derivations](https://scrive.github.io/nix-workshop/04-derivations/01-derivation-basics.html)

## Nix Packages
A Nix derivation is a package:
```nix
let pkgs = import <nixpkgs> {};
in pkgs.stdenv.mkDerivation {
  name = "myPackage";
  src = ./.;
  installPhase = ''
    mkdir -p $out
    echo "my package" > $out/result
  ''
}
```
Build this package with the command `nix build <file>`.
Building a package from a github repo:
```nix
let pkgs = import <nixpkgs> {};
in pkgs.stdenv.mkDerivation {
  name = "catimg";
  nativeBuildInputs = [pkgs.cmake];
  src = pkgs.fetchFromGitHub {
    rev = "<commit sha>";
    repo = "catimg";
    owner = "posva";
    sha256 = "<download sha256 hash>";
  }
}
```

## [NixOS](nix/nixos.md)


## [Home Manager](nix/home-manager.md)


## [Modules](nix/modules.md)


## Nix Development
Commands that are useful during Nix development:
- `nix eval --file <file>`: evaluate the file (ex for syntax checking), even flake.nix files
- `nix flake check`: check the current flake.nix file, as flake is a subset of Nix language
- `nix flake info`
- `nix flake show`: show flake outputs.


## [Nix Flakes](nix/flakes.md)


## VM/ISO Build
### References
- [](https://gist.github.com/573/c1d73a4fd04b8f8ca63885393856f9ea)
- [Example NisOS config in VM](https://github.com/nh2/nixos-vm-building)
- [vm/flakes example](https://gist.github.com/FlakM/0535b8aa7efec56906c5ab5e32580adf)


## Miscellaneous
### Nix Install Without Root Access
A few options are possible:
- using a [nix static binary](https://zameermanji.com/blog/2023/3/26/using-nix-without-root/).
- using [Nix portable](https://github.com/DavHau/nix-portable): it is a static
  nix binary with bubblewrap and proot included.
- using [nix-user-chroot](https://github.com/nix-community/nix-user-chroot).

### NixOS on WSL
See [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) for instructions on
installing NixOS on WSL.
Warning: On first boot after installation you must issue the command `sudo nix-channel --update`
before doing a system update (`nixos-rebuild switch`).

### Notes
`nix-collect-garbage` free up some disk space.
`sudo nix-store --repair --verify --check-contents` in case of corruption.

`nix build "nixpkgs#bat"` nixpkgs is a flake reference in the
[NixOS/nixpkgs](https://github.com/NixOS/nixpkgs) repository on GitHub,
while `#bat` indicates that we're building the bat output from the Nixpkgs flake.

`nix edit -f "<nixpkgs>" hello` will show (in editor) the definition of package `hello`.

Code search: `https://github.com/search?q=buildNpmPackage+repo%3ANixOS%2Fnixpkgs&type=code&p=2`

Switching to a specific Nixos generation (`nixos-rebuild switch --rollback` only
switch to the previous generation):
- `sudo nix-env --switch-generation /<gen number> -p /nix/var/nix/profiles/system`
  `sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch`
  (use `nixos-rebuilt list-generations` to list available generations)

## References
- [NixOS Guide](https://github.com/mikeroyal/NixOS-Guide)
- [Nix Language Basics](https://nix.dev/tutorials/nix-language)
- [Nix Learn](https://nixos.org/learn.html)
- [NixOS configurations](https://sr.ht/~misterio/nix-config/)
- [Oglo12 NixOS Configuration](https://gitlab.com/Oglo12/nixos-config)
- [Nix Tutorial](https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/getting-started.html)
- [Practical Nix Flakes](https://serokell.io/blog/practical-nix-flakes)
- [NixOs on WSL](https://xeiaso.net/blog/nix-flakes-4-wsl-2022-05-01/)
- [How to Learn Nix](https://ianthehenry.com/posts/how-to-learn-nix/)
- [Nix pour les développeurs](https://linuxfr.org/news/nix-pour-les-developpeurs)
- [Gestion de paquets et DevOps avec Nix](https://linuxfr.org/news/gestion-de-paquets-et-devops-avec-nix-tour-d-horizon-sur-un-cas-concret)
- [Gestion de paquets évoluée avec Nix](https://linuxfr.org/news/gestion-de-paquets-evoluee-avec-nix-cachix-overlays-et-home-manager)
- [devenv](https://devenv.sh/)
- [Nix Starter Config](https://github.com/Misterio77/nix-starter-configs)
- [XMonad NixOS Config](https://github.com/gvolpe/nix-config)
- [A Journey into Nix and NixOS](https://williamvds.me/blog/journey-into-nix/)
- [Nix 4 Noobs](https://nix4noobs.com/)
- [NixOS Github Sources Search](https://search.nix.gsc.io/)

## Configuration Examples
- [Complete Conf](https://github.com/foo-dogsquared/nixos-config)
  [with comments](https://foo-dogsquared.github.io/nixos-config/01-introduction/)
- [Hyprdots](https://github.com/prasanthrangan/hyprdots)
- [ZaneyOS](https://gitlab.com/Zaney/zaneyos)

qemu https://superuser.com/questions/1087859/how-to-quit-the-qemu-monitor-when-not-using-a-gui
