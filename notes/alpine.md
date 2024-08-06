# Alpine Linux

## Administration
### Apk
[Alpine Package Keeper](https://wiki.alpinelinux.org/wiki/Alpine_Package_Keeper)
Package manager used by Alpine.
- List installed packages: `apk info`
- Install a package: `apk add <pkg>`
- Show information on a package: `apk info -a <pkg>`
- To determine which package a file belongs to: `apk info --who-owns <path>`

### Local Backup Utility (lbu)
Tool used to save and restore the overlayfs used with a read-only root filesystem.
Configuration is stored in `/etc/lbu/lbu.conf`.
`LBU_MEDIA` must point to a directory inside `/media` which will contain saved configuration.
- List modified files from previously stored configuration: `lbu status`
- Show current differences from the previously stored configuration: `lbu diff`
- Store current configuration: `lbu ci`

Manually installed packages can be saved and restored by lbu.
A cache to store packages must be initialized with the command `setup-apkcache`.

### OpenRc
[How to enable and start services on Alpine Linux](https://www.cyberciti.biz/faq/how-to-enable-and-start-services-on-alpine-linux/)
[OpenRC](https://wiki.alpinelinux.org/wiki/OpenRC)
[Writing Init Scripts](https://wiki.alpinelinux.org/wiki/Writing_Init_Scripts)
Used by Alpine instead of systemd.
- List available services: `rc-service --list`
- List available runlevels: `rc-status --list`
- Launch a service automatically: `rc-update add <srv> <level>`
- Remove a service with: `rc-update del <srv> <level>`
  Normal services use the default runlevel.
- Start/Stop/Restart a service: `rc-service <srv> start|stop|restart` or
  `/etc/init.d/<srv> start|stop|restart`
- List all active services: `rc-update show`

## Other
### Docker
To make a docker Alpine image, use the Alpine miniroot:
```
FROM scratch

ENV ALPINE_ARCH x86_64
ENV ALPINE_VERSION 3.9.1

ADD alpine-minirootfs-${ALPINE_VERSION}-${ALPINE_ARCH}.tar.gz /
CMD ["/bin/sh"]
```

### Recipes
Udev
Udev is not installed by default and must be installed with `apk add eudev`.
Service `udev` and `udev-trigger` must be added to the `sysinit` runlevel.

## Cubie Board Install
Clean SD card with: `dd if=/dev/zero of=${card} bs=1M count=1`

Download and extract Alpine Armv7 tarball some where.

Flash Cubie board bootloader:
`dd if=alpine-uboot-3.18.2-armv7/u-boot/Cubieboard/u-boot-sunxi-with-spl.bin of=${card} bs=1024 seek=8`

Create /root partition starting at 1M or 2M with fdisk. Flag partition as boot partition.
Format partition: `mkfs.ext4 ${card}${p}1` as a FAT32 partition type
(called W95 FAT32 (LBA) and its ID is 0xc with fdisk).

Create an other partition for the data partition (~5G) (will be formatted by setup script).
Mount partition: `mount ${card}${p}1 /mnt` and copy folders `extlinux, apks, boot, alpine.apkovl.tar.gz`.
Create an answer file for setup-alpine and put it under directory `setup` in the root partition.

## Alpine Install
Boot the SD card. Use serial console. Login with user root (no password).
Launch setup: `setup-alpine -f /media/mmcblk0p1/setup/install`

Example setup/install answer file:
```bash
# Example answer file for setup-alpine script
# If you don't want to use a certain option, then comment it out

# Use US layout with US variant
KEYMAPOPTS="none"

# Set hostname to alpine-test
HOSTNAMEOPTS="cubie"

# Contents of /etc/network/interfaces
INTERFACESOPTS="auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    hostname cubie
"

# Set timezone to UTC
TIMEZONEOPTS="Europe/Paris"

# set http/ftp proxy
PROXYOPTS=none

# Add a random mirror
APKREPOSOPTS="mirrors.ircam.fr"

# Create admin user
USEROPTS="-a -u -g audio,video,netdev gribouille"

# Install Openssh
SSHDOPTS="dropbear"

# Use openntpd
NTPOPTS="busybox"

# Use a data disk
DISKOPTS="-m data /dev/mmcblk0p2"

# Setup in /media/sdb1
LBUOPTS="/media/mmcblk0p1"
APKCACHEOPTS="/media/mmcblk0p1/cache"
```

## Administration
[Installing a package](https://wiki.alpinelinux.org/wiki/Setting_up_a_SSH_server)

## Various
[Simple way to set up Split DNS](https://shorewall.org/SplitDNS.html)

## References
- [Alpine on ARM](https://wiki.alpinelinux.org/wiki/Alpine_on_ARM)
- [SUNXI: Manual build howto](https://linux-sunxi.org/Manual_build_howto)
