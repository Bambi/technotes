# Secrets Management

## Tools
### [Git Crypt](https://github.com/AGWA/git-crypt)
  - manage secrets in a git repo with GPG or symetric keys

### [Pass](https://www.passwordstore.org/)
CLI program to manage a list of password (or private keys/notes):
- the pass database (`~/.password-store`) can be a git repository, a commit
  is generated on each manipulation of the store. It can be organized into
  several files and directories.
- the pass database is encrypted with one or mutltiple gpg keys.
- `passage` is a pass fork working with age keys.

### [Sops](https://github.com/getsops/sops)
CLI to encrypt files or specific fields on structured files:
- encryption is not done by sops but is delegated to other tools like
  pgp (gpg) or age (or others: Azure/Hashicorp ...).
- whith age, does not support passphrase and ssh keys?
- on structured file, encryption is done for values only, key are left untouched.

Sops can use different file encryption technologies:
- PGP
- age (an age key pair be produced from a SSH ed25519 private key)
- GCP KMS
- Azure key vault
- Hashicorp vault

#### Usage
You need a configuration file (`.sops.yaml` in the current directory) to tell
sops how to use your key for encryption/decryption.

### [Age](https://github.com/FiloSottile/age)
- file encryption tool
- encrypt/decrypt with own (short) keys, ssh keys, passphrase or yubikey.
- recommended over PGP.

With age *identity* is one or more private keys and *recipient* is public key.

Age keys are asymetric keys generated with `age-keygen`. The private part is
generated in a file and the public key is given in stdout. Encryption is done with
the public key and decryption with the private key.

It is possible to generate an age key pair from a ssh key (only ed25519) with `ssh-to-age`.
The tool must be run for the public and private key.

It is possible to generate an age public key from the age private key with `age-key-gen -y`.
You can then get a public/private age key from just a private SSH key:
```sh
ssh-to-age -- --private-key -i <ssh priv key> > <age priv key>
age-keygen -y <age priv key>
```

### GPG
Opensource implementation of PGP (Pretty Good Privacy). PGP is mainly used for
file encryption.
GPG support asymetric keys encryption (with pgp keys) and passphrase encryption.
The private key can be protected with a passphrase or a PIN code with a secured
USB key (Yubikey).
A GPG key can be used as a SSH key.

Passphrase crypto:
- file encryption: `gpg -c <file>`
- file decryption: `gpg -d <file.gpg>`

#### Key Management
GPG key are asymmetric (they have a public and private part).
GPG keys have specific roles:
- E: encrypt/decrypt data
- S: sign data
- A: authenticate (to use SSH with a GPG key)
- C: certify (sign an other key to establish a trust-relation)
GPG keys are organized in a hierarchy with a master key with at least [SC] capabilities
and several subkeys each one with the capabilities of E, S, A.

#### CLI Usage
- list public keys: `gpg --list-keys`
- list private keys: `gpg --list-secret-keys`
- create a master key: `gpg --full-gen-key`
- create a sub-key: `gpg --edit-key <key id>`
- export public key in a text file: `gpg --export --armor <key id>`
- backup secret key: `gpg –export-secret-keys –armor <key id> > masterkey.pem`
- import secret key: `gpg –import masterkey.pem`

[Gestion clés](https://www.nbs-system.com/publications/expertise/creation-de-sa-cle-gpg-et-utilisation-avec-passwordstore-enigmail-gpg-agent/)
[Key Explanation](https://rgoulter.com/blog/posts/programming/2022-06-10-a-visual-explanation-of-gpg-subkeys.html)
[Commandes GnuPG](http://www.dg77.net/tekno/securite/gnupgcde.htm)

#### SSH With GPG
It is possible to use your gpg key as a ssh key. You must have a gpg key with
the authentication capability (A).
The interface between ssh and gpg is made through the gpg-agent daemon which must
have the `enable-ssh-support` configuration option.
Also ssh must be told how to access to gpg-agent. This is done with the `SSH_AUTH_SOCK`
env variable with must be set to the gpg-agent listening socket.
[SSH access using a GPG key](https://opensource.com/article/19/4/gpg-subkeys-ssh)

### Keystore
A keystore store all yours keys in one location protected by a passphrase.
- keytool. Java app provided by the JDK.
- pass is a key store.
- ylva store passwords. Protected with a password.

## Hardware
### [Yubikey](https://www.yubico.com/?lang=fr)
- not opensource but yubikey-agent
- https://rzetterberg.github.io/yubikey-gpg-nixos.html
[cheatsheet](https://debugging.works/blog/yubikey-cheatsheet/)

### [Solokey](https://solokeys.com/)
- opensource with linux cli tools
- FIDO2 L1
- NFC
- sell from Europe
- no GPG or password storage yet

### [Nitrokey](https://www.nitrokey.com/)
- opensource audited by Cure53 ; firmware shared with Solo
- NFC

### [Onlykey](https://onlykey.io/fr)
- opensource
- FIDO2 L1
- onlykey-agent (GPG/SSH)
- no NFC (but DUO has USB A/C)

### [TKey](https://www.tillitis.se/products/tkey/)
  - opensource but no FIDO U2F/TOTP

### [Librem Key](https://puri.sm/products/librem-key/)
- based on NitroKey
- no FIDO2/U2F, focus on trusted boot

### Others
- Thetis
  - made in China
- Neowave Winkeo

## Techincal Terms
- TOTP: Time-based One Time Password
- FIDO U2F: Universal 2nd Factor Auth
- OTP: One-Time Password
- FIDO2: 2nd iteration of U2F
- LUKS: Linux Unified Key Setup
- PIV: Personal Identity Verification
- OATH: Initiative for Open Authentication
- PRNG: Pseudo-Random Number Generators. Approximate randomness by applying
  software algorithms to a seed value.
- TRNG: True (or hardware) Random Number Generator. Generates the random values
  important to cryptography through physical processes.

## Asymetric Crypto Algorithms
- RSA (Rivest–Shamir–Adleman).
  Widely used. Key length between 1024 and 4096.
- DSA (Digital Signature Algorithm)
- ECDSA (Elliptic Curve Digital Signature Algorithm).
- EdDSA (Edwards-curve Digital Signature Algorithm).
  Ed25519 is its most known implementation.

## Symetric Crypto Alogithms
- AES (Advanced Encryption Standard), keys length can be 128, 192 or 256.
- DES (Data Encrytion Standard), key length is 56. Replaced by AES.
- 3DES

## SSH
Used for remote computer connection.

### Host keys
Each computer should have host keys pairs (one for each algorithm) generated
during host installation and stored in `/etc/ssh/ssh_host_<algo>`.
The `ssh-keygen` program can be used for generating additional host keys
or for replacing existing keys.
Host keys allows to authenticate the host: users should have remote host's public keys
in his knowed host file (`~/.ssh/knowed_hosts`).
By default the host's public key can be automatically retreived on the first boot
but this is not recommanded.

### Password-less User Authentication
Users should have theirs pair of keys. The user's private key is kept in his
home directory (`~/.ssh`) and the public key must be copied to the user's home directory
on the remote host (`~/.ssh/authorized_keys`).

### Key Management
- `ssh-keygen` genetates a pair of public/private key. The private key can be
  encrypted with a passphrase.
- `ssh-keygen -y` can generate the public key from a private key.
- `ssh-copy-id username@remote_host` copy the users public key on a remote
  users account for password-less authentication. Can also be done with
  `cat ~/.ssh/id_rsa.pub | ssh username@remote_host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"`.

### SSH Keys Recap
SSH keys on each machine should be:
- a host private key in `/etc/ssh`.
- the users public key in `~/.ssh/authorized_keys`.
- each other hosts public key in `~/.ssh/knowed_hosts`. 

### SSH-agent
It is a long-running daemon which cache your decrypted private keys.
You add your private keys with the `ssh-add` command and your keys password.
Then ssh command will communicate with ssh-agent to get your private key.
See also [keychain](https://www.funtoo.org/Funtoo:Keychain).

### SSH Keys Security Level
We can distinguish security level depending on how we manage SSH keys:
- low security: keys stored in files (`~/.ssh/id_...`) without a pass-phrase.
- better security: keys stored in files protected with a pass-phrase and
  loaded in a SSH agent.
- even better security: keys stored on a non-extractible device (TPM or smart key).
- very secured: keys stored on a non-extractible device with a physical confirmation
  (a key to press on the device) on each usage.

### SSH keys with secured keys
SSH can be used with any secure key compatible with the FIDO2 standard. The nitropy
command-line tool can be used for several keys.
To generate a SSH key secured with a USB key use the command `ssh-keygen -t ed25519-sk`
or `ssh-keygen -t ecdsa-sk`.
You will get a pair of key usable like any other ed25519 key that can be used
ony if the USB key is present.
The generated private key is not usable without the USB key and thus can be copied
without further security.
See [Step Up Your SSH Game](https://weisser-zwerg.dev/posts/openssh-fido2-hardwarekey/)
for more details.
You can generate a _discoverable_ or a _non-discoverable_ key:
- a discoverable key (generated with the `-O resident` is stored on the secure key).
  This means that the key pair is usable if you lost your private key. You can retreive the private
  key on any computer with the `ssh-keygen -K` command.
  ? You can have only one discoverable key?
- a non-discoverable key is stored only in the `~/.ssh` directory. It is more secured
  but the private key must be deployed on differents hosts by some other means (Nix).
  You can generate as much non-resident keys as you want.

### File Encryption With SSH
It is possible to crypt data with a SSH key with [sshenc.sh](https://github.com/5im-0n/sshenc.sh).
See also [this blog post](https://www.bjornjohansen.com/encrypt-file-using-ssh-key).
The idea is to generate a symmetric key, encrypt your data with this key, encrypt
the symmetric key with the SSH key and send to the recipient the encrypted data
and session key.

### SSH Certificate Authentication
SSH authentication can be either _key-based_ (as we saw before with a public/private key pair)
or _CA based_: a key pair is created for the CA (same key format as a normal SSH key pair).
Each user or host public key along with some optional data (ex: expiration date)
is signed with the CA private key which gives a certificate.
When a user log-in he must provide its public key (like before) and the signature file of the
previous operation. The server then check the signature with the CA public key and accept
the connection if it match. The server does not need to keep the public keys of each user, it only
need to know the CA public key.
Thurthermore the signature file (the certificate) can contain an expiration date.
See [here](https://www.lorier.net/docs/ssh-ca.html) for more details.
To sign a SSH host or user key: 
```sh
ssh-keygen -s /etc/ssh/ca \
     -I "$(hostname --fqdn) host key" \
     -n "$(hostname),$(hostname --fqdn),$(hostname -I|tr ' ' ',')" \ # or hostname -i (for a server with a static IP)
     -V -5m:+3650d \ # or 'always´
     -h \ # for a host certificate
     /etc/ssh/ssh_host_key.pub

ssh-keygen -s /etc/ssh/ca \
    -I "$(whoami)@$(hostname --fqdn) user key" \
    -n "$(whoami)" \
    -V -5m:+3650d \
    ~/.ssh/id.pub

  -I: key identifier, arbitrary string
  -n: one or more principals. Do not use this option if no principals.

ssh-add ~/.ssh/*-cert.pub
```
On servers you must specify the server public key to check users certificates:
```
/etc/ssh/sshd_config:
  TrustedUserCAKeys <CA public key>
  HostKey <host private key>
  HostCertificate <host certificate>
```
For each clients you must provide the CA public key to verify host certificates:
```
~/.ssh/know_hosts:
  @cert-authority <host principals> <CA public key>
```
User key is accepted if its certificate is valid (can be decrypted with the CA public key)
and the certificate principals match the accepted principals.

## Sops-nix
Allows to manage secrets (private keys and passwords) in Nix configuration.

### NixOS
To deploy secrets to our machine, we could think of these options:
- Write our secrets directly into `configuration.nix`
- Write our secrets into a file in the machine, (such as `/secret/my-secret`),
  and reference that file in `configuration.nix`

sops-nix uses a hybrid approach: our secrets will be stored encrypted in our configuration.
When the machine boots up, it try to decrypt them using the age key,
and put them into a specific path (`config.sops.secrets.<my-secret>.path`).
```nix
{ config, pkgs, ... }: {
  sops.age.keyFile = "/secrets/age/keys.txt";
}
```
#nix

### Home-Manager
It is possible to use Sops-nix with home-manager. Secrets are stored in the git
repository encrypted and are decrypted by a systemd user service just after the
configuration has been applied.

## Agenix
Basic idea:
- a secret is crypted twice with a host public key and a user (developper) public key
  with the `agenix` cli tool.
- crypted secrets are stored in git repo and in the Nix store
- on the target machine the secret will be decrypted with the hosts private key
- during development the devlopper can decrypt (and modify) the secret with
  its private key

PB: How to bootstrap the hosts private key on the target machine?
This must (and cannot) be done by Nix but must be provided by other means:
- for vm: injecting the private key in the vm image generated by Nix
- if you use the Nix installer: use the key generated by the installer
- use a key provided by a TPM module or a security key
In all case Nix should not build a host configuration with a host private key.

## TPM 2.0 (Trusted Platform Module)
On every computer since 2016. Managed on Linux with the `tpm2-pkcs11` library
which provides an interface between TPM and PKCS11 capable programs such as OpenSSH.

A TPM is able to perform symetric and asymetric crypto operations. Access to a TPM
device may be secured with a PIN:
- user PIN, for normal users.
- SOPIN (Security Officer PIN), a user responsible for administering normal users
  and for performing operations such as initial settings and changing passwords
  (user PINs).

A TPM 2.0 has:
- non-persistant memory called PCR (Platform Configuration Registers). These
  registers hold cryptographic digests computed from the boot code and the boot
  configuration data. To authenticate the content of the PCR, the TPM is able
  to sign the PCR with a special key stored in the TPM called the AIK (Attestation
  Identity Key in TPM 1.2) or AK (Attestation Key in TPM 2.0).
- some private key material used to decrypt or sign data with asymetric cyphers
  as well as symmetric material for symmetric algorithms. This allows the TPM to
  work with many keys while having a limitted amount of memory: when a key pair
  is generated by the TPM, the private key is encrypted using symmetric
  encryption and the result can be stored outside of the TPM.
  To use such a key, the software first needs to load the encrypted private
  key into the TPM, which decrypts it using a secret key which never leaves
  the TPM.
- a TPM can encrypt some data in a way that the result can only be decrypted
  when some conditions happen (for example “someone entered some kind of password”
  or “some PCR hold some specific values”). This function is called _sealing data_
  when the data is encrypted and _unsealing data_ when it is decrypted.
- a TPM contains some storage named _NV Indexes_ (Non-Volatile). This storage
  can contain certificates for the public keys associated with the private keys
  held by the TPM, as well as other information. The access to a NV Index can be
  restricted using several checks in a similar way as the one used in sealing operations.

It is possible to use a TPM device to protect SSH private keys. Advantages are:
- hosts keys cannot be used on an other host.
- user key are protected by the TPM device instead of a password.

> [!warning] 
> Be aware that SSH keys managed by a TPM device may be lost in case of Bios update!

To access to these functionnality one need a TPM driver (provided by the Linux kernel)
and some TPM tools (provided by the tpm2-pkcs11 on Linux).
```sh
sudo apt install libtpm2-pkcs11-1 libtpm2-pkcs11-tools
tpm2_ptool init
# creating a pkcs token (a token is a crypto provider like TPM, USB KEY ...)
tpm2_ptool addtoken --pid=1 --label=ssh --userpin=MyPassword --sopin=MyRecoveryPassword
# creating a SSH key
tpm2_ptool addkey --label=ssh --userpin=MyPassword --algorithm=ecc256
# retreiving the SSH pub key
ssh-keygen -D /usr/lib/x86_64-linux-gnu/libtpm2_pkcs11.so.1
# using the SSH key
ssh -I /usr/lib/x86_64-linux-gnu/libtpm2_pkcs11.so.1 server
# see also option PKCS11Provider in ssh config file to avoid giving
# libtpm2_pkcs11.so.1 each time
```
The pub key can be copied and used normally on different hosts.
See [Using a TPM for SSH authentication](https://incenp.org/notes/2020/tpm-based-ssh-key.html).

It is also possible to import an existing [SSH key into a TPM](https://jade.fyi/blog/tpm-ssh/):
```sh
tpm2_ptool import --label ssh --key-label my-ssh-key --userpin MyPassword --privkey id_rsa --algorithm rsa
```

## Notes
- [use gpg-agent instead of ssh-agent](https://blog.lohr.dev/key-management)

## Bootstraping Security Keys on a new PC
Try to get a secured environment (a set of keys) as fast as possible on new hardware:
- Using a security key: with a resident (discoverable) key you can use `ssh-keygen -K`
  to import your first ssh key. Should be able to git clone repositories.
- Get a SSH ed25559 key from Bitwarden. Allow to git clone repositories.
  Use `ssh-to-age` to get an age key: allow to apply a Nix configuration using age.
- à voir: plugin `age-plugin-fido2-hmac` pour avoir une clé age à partir d'une clé USB FIDO2.
- note: Sops HM secrets are encrypted with a private age key stored in `~/.config/sops/age/key.txt`.

## References
- [PGP](https://vonkrafft.fr/securite/)
