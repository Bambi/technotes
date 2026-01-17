# Fedora Silverblue
Container based desktop distribution with atomic upgrades.

## rpm-ostree
- `rpm-ostree status`: get boot information
- `rpm-ostree refresh-md`: generate rpm metadata
- `rpm-ostree upgrade`: perform system upgrade
- `rpm-ostree upgrade --check`: check for upgrade
- `rpm-ostree rollback`: rollback to previous system
- `rpm-ostree install [url | pkg]`: add overlay packages
- `rpm-ostree override`: replace package with an other version
- `rpm-ostree reset`: remove all overlays
- `rpm-ostree rebase`: switch to an other tree
- `ostree remote refs fedora`: list available trees (from fedora)
- `rpm -q pkg`: show installed package version
- `rpm -qa`: show installed packages
- `rpm -qi pkg`: show detail package information
- `rpm-ostree cleanup --rollback`: remove previous deployments
- `rpm-ostree cleanup --pending`: remove pending deployments

Pinning deployments (will not be removed by a cleanup):
1. Check the index number of deployments: `rpm-ostree status -v`
2. Pin a deployment: `sudo ostree admin pin 0`
3. Unpin a deployment: `sudo ostree admin pin --unpin 0`

To rollback to a specific version:
1. Pull the ostree commit log from the remote repository:
   `sudo ostree pull --commit-metadata-only --depth=10 fedora fedora/42/x86_64/silverblue`
2. Display the log:
   `ostree log fedora:fedora/42/x86_64/silverblue`
3. Deploy a specific commit:
   `rpm-ostree deploy 42.20230716.0`

## Toolbx
Support only fedora, redhat, ubuntu and arch. See also [community images](https://github.com/toolbx-images/images).
- `toolbox create --container <nom> --release <version>`: create a new container
- `toolbox enter --container <nom>`: enter a container
- `toolbox run --container <name> <commande>`: run a command inside a container
- `toolbox list`: list containers
- `toolbox rm <name>`: delete a container
- `toolbox reset`: remove all containers

## Flatpack
- `flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo`
- `flatpak remotes`: list installed remotes
- `flatpak search pkg`: search applications
- `flatpak install flathub <APP-ID>`: install app from the flathub remote
- `flatpak list --app`: list installed applications
- `flatpak run <APP-ID>`: launch an application
- `flatpak update`: update installed applications to latest version
- `flatpak uninstall <APP-ID>`: uninstall app

## RPM
Red Hat Package Manager (`dpkg` equivalent). Basic syntax is `rpm [options] [package_name]`.
Options:
- `-i, –install` 	Installs a package
- `-e, –erase` 	  Removes a package
- `-h, –hash` 	  Prints a progress bar (hash marks) as the package installs
- `-l, –list` 	  Lists files in a package
- `-q, –query` 	  Queries a package
- `-s, –state` 	  Displays the state of the listed files
- `-U, –upgrade` 	Upgrades a package
- `-v, –verbose` 	Provides more detailed output
- `-V, –verify` 	Verifies the integrity of installed packages
- `-a, –all` 	    Queries all installed packages

Typical commands:
- `rpm -ivh <rpm>`: install a package
- `rpm -Uvh <rpm>`: update a package
- `rpm -evh <pkg name>`: uninstall a package
- `rpm -Vv <pkg name>`: check integrity of package
- `rpm -qs <pkg name>`: display the state of each file in the package
- `rpm -qip <rpm>`: gather information about a package
- `rpm -ivh --test <rpm>`: simulate package installation
- `rpm -qa`: list all installed packages

Rpm database can be queried at [rpmfind](https://rpmfind.net/).

## DNF
DNF (Dandified yum, `apt` equivalent) replaces YUM and is a wrapper around rpm to:
- download packages from the network
- manage package dependencies

General syntax is `dnf [options] <command> [<args>...]`.
`args` can be a package name, a group name, or subcommand specific to the command.
- `dnf search <name>`: search package
- `dnf install <name>`: install a package
- `dnf info <name>`: show information about a package
- `dnf list installed`: show installed packages
- `dnf remove <name>`: remove a package
- `dnf autoremove`: remove unneeded packages
- `dnf upgrade`: update installed packages
- `dnf group list`: show groups
- `dnf group info <group name>`: show packages in a group
- `dnf group install <group name>`: install a group package
- `dnf repolist all`: list available repos
- `dnf repolist enabled`: show enabled repos
- `dnf config-manager --set-[enabled|disabled] <depot>`: enable/disable a depot
- `dnf history`: show transaction history
- `dnf deplist <name>`: show package dependency
- `dnf provides <file path>`: show packet providing a file
- `dnf repoquery --whatrequires <name>`: show packets that need a package
- `dnf repoquery --userinstalled`: show packaets installed by the user (ignore dependencies)
- `dnf install -C <rpm>`: install a downloaded package

Standard Fedora main repo might be limitted. To have more software, you can use
RPM Fusion repos or COPR (Cool Other Package Repo; PPA equivalent) repos.
- `dnf install dnf-plugins-core`: required to use copr repos
- `dnf copr search <name>`: search copr repo
- `dnf copr enable [user]/[project]`: enable a copr repo
- `dnf copr list [--enabled]`: list added copr repos

Packages are installed from a copr repo with the normal dnf command (`dnf install`).

## [Universal Blue](https://github.com/ublue-os/main)
Community project that builds custom images based on atomic Fedora desktops. Add over Silverblue:
- hardware acceleration, codecs
- distrobox
- linuxbrew
- udev rules for better hardware support
- just receipes for system management

Several instances:
- Bluefin: gnome based desktop
- Bazzite: gamer desktop
- Aurora: kde based desktop

It is possible to migrate from silverblue to a universal blue desktop.
Available ublue images are [here](https://github.com/orgs/ublue-os/packages),
[non nvidia](https://github.com/orgs/ublue-os/packages?repo_name=main).
Upgrade is done with 2 steps:
1. Rebase to the unsigned variant of the base image: `rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bluefin:latest`.
   Reboot: `systemctl reboot`.
2. Rebase to the signed variant of the image: `rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/bluefin:latest`.
   Reboot: `systemctl reboot`.

A minimal ublue image can be installed with `rpm-ostree rebase ostree-image-signed:docker://ghcr.io/ublue-os/silverblue-main:42`.

## Nix
Possible solutions to use the Nix package manager with [fedora atomic](https://github.com/DeterminateSystems/nix-installer/issues/1445):
- use [nix portable](https://github.com/DavHau/nix-portable)
- enable transient root: [bootc option](https://bootc-dev.github.io/bootc/filesystem.html#enabling-transient-root)
- use a container image with a `/nix` directory, [see](https://blue-build.org/).
- use [thrix](https://thrix.github.io/nix-toolbox/) toolbx image: `toolbox create --image ghcr.io/thrix/nix-toolbox:42`

## Building a Custom Image
- use ublue official [template](https://github.com/ublue-os/image-template) or the
  [ue-build](https://blue-build.org/) [template](https://github.com/blue-build/template)
- example [here](https://github.com/martinpitt/workstation-bootc)
- other images [here](https://universal-blue.discourse.group/t/list-of-community-created-custom-images/340)

## ostree
Low level command to manage versioned filesystem tree. Work with filesystem trees.
Ostree works on any filesystem or block device but will transparently take advantage of some BTRFS features if deployed on it.
All command accept the `--repo` arg which specified the ostree repo to use (`--repo=/sysroot/ostree/repo`)
with Fedora Silvercore.
- `ostree init`: init a new repo
- `ostree commit --branch=x dir`: commit changes to a branch
- `ostree ls <branch>`: list file paths in a branch
- `ostree cat <branch> <path>`: get file path content from a branch

## Bootc
New technology that will replace rpm-ostree?
- `rpm-ostree upgrade` → `bootc upgrade`
- `rpm-ostree rebase` → `bootc switch`
- `rpm-ostree rollback` → `bootc rollback`

## References
- [ostree](https://ostreedev.github.io/ostree/introduction/)
- [ostree intro](https://linuxembedded.fr/2023/07/introduction-a-ostree)
- [ostree presentation](https://www.youtube.com/watch?v=_CwGUt0CpvU)
