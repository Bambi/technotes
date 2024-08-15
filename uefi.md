# UEFI Unified Extensible Firmware Interface
UEFI fait suite à l'EFI conçue par Intel. C'est une interface logicielle
entre un firmware et un OS. Une de ses fonctions est l'amorçage d'un OS.

UEFI remplace le BIOS (permet un accés réseaux, interface graphique, affranchissement
limite 2,2 To, développé en C, architectues x86 et ARM, format GPT avec 128 partitions, ...).

Le chargeur UEFI est stocké sous forme de fichier dans un système de fichier
FAT32, FAT16 ou FAT12. UEFI supporte les tables de partition GPT et MBR.

## UEFI Components
### Configuration Interface
As UEFI programs are 34/64 bits they can now display graphical user interace with
mouse support.

### UEFI System Partition
The EFI System Partition (ESP) is a special partition found on UEFI based booting machines.
On Linux system this partition is mounted under `/boot/efi`. It contains firmwares
used during the booting process. Some OS may install programs under the `EFI` directory
to support dual boot.
The EFI partition must stricly be FAT 16/32. Note that this partition is not necessarily
a separate partition, it can be a directory in an OS FAT 16/32 partition.

### GPT Partition Table Format
UEFI usually required the disk to be formatted as GPT althought it may be possible
to use a MBR disk for booting.

### Secure Boot
Usually can be enabled/disabled from the UEFI interface.
To check your system used secured boot: `mokutil --sb-enabled`.
To see the list of installed security keys: `mokutil --list-enrolled`
For Linux the standard boot loader is `grubx64.efi` but if secured boot is enabled
the the bootloader will be `shimx64.efi`. [Shim](https://github.com/rhboot/shim)
is a placeholder bootloader which is signed by the microsoft keys which then loads
the actual bootloader.
You can check your boot sequence with: `sudo efibootmgr -v`.

## Shell UEFI
UEFI fournit un shell proche d'un shell Unix. Les scripts ont pour extension `.nsh`.
Si il existe, le shell exécutera automatiquement le script `startup.nsh` au lancement.
Identifiants (Mapping Table):
- `FSx`: volumes détectés (partitions)
- `BLKx`: devices détectés
Commandes:
- `help`: liste les commandes possibles
- `map -r`: affiche la Mapping Table
- `FSx:`: entre dans un volume
  - `ls`: liste le contenu du volume
  - `cd <dir>`: change répertoire courant
- `bcfg boot dump -b`: affiche le boot order
- `bcfg boot mv xx yy`: déplace l'option xx vers l'emplacement yy
Le boot loader UEFI ext un exécutable `BOOTX64.EFI` situé dans la partition `efi`
dans le répertoire `efi\boot`.

Resources:
- [Intel UEFI Basic Instructions](https://www.intel.com/content/dam/support/us/en/documents/motherboards/server/sb/efi_instructions.pdf)
- [UEFI Shell Tutorial](https://www.sys-hint.com/3893-How-to-Use-UEFI-Interactive-Shell-and-Its-Common-Commands)
- [UEFI Shell Specifications](https://uefi.org/sites/default/files/resources/UEFI_Shell_2_2.pdf)

## [Efibootmgr](https://doc.ubuntu-fr.org/efibootmgr)
Utilitaire en ligne de commande pour gérer le chargeur UEFI:
- modification de l'ordre de démarrage des OS
- créer ou supprimer des entrées
- modifier les options d'exécution du prochain démarrage.
Voir [tutoriel](https://www.malekal.com/efibootmgr-ajouter-changer-supprimer-des-entrees-pc-uefi/)

## [rEFInd](http://www.rodsbooks.com/refind/)
Boot manager: show a list of options to the user at startup.
(Grub is a boot manager and a boot loader, it load an OS kernel and hands off
control to it).
rEFInd replaces the (usualy poor) standard UEFI boot manager but uses the UEFI
boot loader.

## Linux
Chaque OS vient avec son propre boot loader: `BOOTMGR` pour Windows, `elilo` ou
Grub/EFI pour Linux.
Un boot UEFI standard est: Boot -> UEFI Boot manager -> UEFI boot loader -> OS
Le boot manager UEFI dépend du constructeur (Dell, HP, autre) et il est difficile
pour l'OS de le configurer (mofifier les options de démarrage).
Pour cette raison on préfère passer par un boot manager connu:
Boot -> rEFInd boot manager -> UEFI boot loader -> OS
ou utiliser Grub en fin de chaine:
Boot -> UEFI boot manager -> UEFI Grub -> OS.

# Coreboot / Libreboot
Coreboot est une alternative à UEFI/BIOS avec pour objectif de fournir un boot rapide.

## Resources
- [BIOS, UEFI and the Boot process Explained along with MBR and GPT](https://www.binarytides.com/bios-uefi-and-boot-process-explained/)
- [Liste des touches pour accéder au BIOS/UEFI](https://lecrabeinfo.net/liste-des-touches-pour-acceder-au-bios-uefi-acer-asus-dell-lenovo-hp.html)
