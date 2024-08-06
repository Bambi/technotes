# Conan
Package manager for C/C++ libraries. Packages are preferably binary but can also be source code.

## Configuration
`~/.conan/remotes.json`
  List servers where to find packages. The conan-center is automatically added.
  This file can be manually edited or servers can be added with:
	`conan remote add <remote name> <remote url>`

`~/.conan/profiles/ default`
  Set of different settings, options, environment variables and build requirements
  used when working with packages. The settings define the operating system,
  architecture, compiler, build type, and C++ standard.
  Options define, among other things, if dependencies are linked in shared or static mode or other compile options.

`~/.conan/settings.yml`
  A set of keys and values, like os, compiler and build_type that can be used
  in profile files depending on platform.

## Using
To list packages available on a remote:
	`conan search <pkg name> --remote=<remote name>`
To list available packages locally:
	`conan search <pkg name>`

Package names are in the form `<name>/<version>`. These are official conan center packages.
Others are in the form `<name>/<version>@<user>/<channel>`.

To get information about a specific package:
	`conan inspect <full pkg name> --remote=<remote name>`

## Installing Packages
In a project packages dependencies are listed in the `conanfile.txt` file.
To install required packages and dependencies:
	`conan install <dir path where to find conanfile.txt>`
To install and build a source package:
	`conan install <dir path> --build <pkg name>|missing`

Packages will be installed in the `~/.conan/data directory`.
A `conaninfo.txt` file will be created in which the settings, requirements and
optional information is saved together with a `conanbuildinfo.xxx` file
containing instructions to be used by your build system.

The format and extension depends on the package and the conanfile (generators section ; can be `cmake` or `text`).
Setting required for the install is taken from the `~/.conan/settings/default` file.
They can be overridden with command line options `-s / --settings`:
	`conan install .. --settings os="Linux" --settings compiler="gcc"`

## Alternatives
[Managing Developer Environments with Conda](https://interrupt.memfault.com/blog/conda-developer-environments).

