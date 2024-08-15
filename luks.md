# Linux Unified Key Setup (LUKS)
- allow encryption of a Linux patition 
- replaces `dm-crypt`
- provides a layer between a partition and the filesystem

To make partion /dev/sda1 crypted:
```
# will clear the partition and ask you a passphrase:
cryptsetup luksFormat /dev/sda1

# <partname> is the name of the new 'virtual' partition
# to bind the luks partition to a decrypted partition:
cryptsetup luksOpen /dev/sda1 <partname>

# you can now use this partition as a normal partition:
mkfs /dev/mapper/<partname>
mount /dev/mapper/<partname> /mnt
umount /dev/mapper/<partname> /mnt

# close the luks partition:
cryptsetup luksClose /dev/mapper/<partname>
```
> [!note]
> It is possible to add other keys to a LUKS partition with the command:
> `cryptsetup luksAddKey /dev/sdX`

## /etc/crypttab
This file contains information about crypted filesystems. There must exist
one line for each filesystem. Each line must have 4 fields separated by space:
- the target, the name of the mapped partition which will appear under `/dev/mapper`.
- the source-device, the encrypted partition (or file name). The UUID can be used.
- the key-file, the file with the key to decrypt the file system.
  With the value `none` the passphrase will be read on the keyboard.
- the crypsetup options, format is `key=value`. Use `tcrypt` for luks.

Example:
```
partname UUID=$(cryptsetup luksUUID /dev/sda1) none tcrypt
```

## Grub
If the root filesystem is encrypted, the grub configuration must be updated
with the UUID of the luks root filesysem added to the linux command line:
Example `/etc/sysconfig/grub` file:
```
GRUB_CMDLINE_LINUX="... rd.luks.uuid=4c9b0973-407f-44e4-a91b-446014832ce6"
```
Must be done also if the swap partition is crypted.

## [Clevis](https://github.com/latchset/clevis)
Clevis is a pluggable framework for automated decryption. It is able to encrypt
data with several methods (using plugins):
- TPM2
- network service (tang)
- Shamir's secret sharing
- Yubikey

The point of Clevis is that whatever plugin you use to encrypt you data, you can
decrypt it with the command `clevis decrypt <encrypted data>` (the parameters
required for the decryption is encoded in the encrypted data).

Encrypting data is done with `clevis encrypt PIN CONFIG <TEXT >CIPHERTEXT.jwe` with:
- PIN: plugin to use: `tang`, `tpm2`, `sss`.
- CONFIG: parameters to add to the plugin.

### Binding LUKS Volumes
Clevis can be used to bind a LUKS volume using a pin so that it can be automatically unlocked.
The concept is to create a new simmetric key which is added to the LUKS partition
as a new passphrase. This key is then encrypted with clevis (with your chosen PIN)
and the resulting `.jwe` is stored in the LUKS header with
[LUKSMeta](http://github.com/latchset/luksmeta).
For example to bind a LUKS volume with a TPM:
```
clevis luks bind -d /dev/sdX tpm2 '{}'
# use '{"pcr_ids":"1,7"}' to seal the LUKS key against the UEFI settings
```

## Where to Store The LUKS Keys?
If the rootfs is not encrypted:
- Easy setup, no need to update grub. The luks keys can be stored in the rootfs (`/etc/crypttab` file).
  This does not offert great security as the keys are readable if you can access
  to the rootfs.

If the rootfs is encrypted: Linux need the key in order to mount the rootfs. The
key can be stored in:
- the initramfs. Same limitation as before.
- tang server. Need an online tang server and a secure network.
- Yubikey.
- a FIDO2 key. see [here](https://git.atlanticaweb.fr/alexandre/nixos-config/src/branch/main/hosts/template).
- TPM. Security is provided only if the disk is separated from the machine.
  (no security for a stolen laptop).
  ```
  systemd-cryptenroll /dev/sda1 --tpm2-device=auto --tpm2-pcrs=7
  clevis luks bind -d /dev/sda1 tpm2 '{"pcr_ids":"7"}’
  ```
- not stored anywhere. The passphrase has to be entered on the keyboard on each boot.
