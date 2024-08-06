# Nebula Overlay

## Configuration
### Certificates
All nebula nodes must have a certificate. A CA certificate is also required
to sign all other certificates.
Certificates files are:
- `*.crt`: certificated data + public key
- `*.key`: private key

Each node must have:
- its certificated identity: a secret key (`.key`) and a certificate signed with
  the ca private key (`.crt`).
- the nebula certificate (`.crt`) which is the public key of the CA.

### Creating a CA Certificate
This cert (key pair) will be used to issue other certificates. Keep the private key (.key) safe!
Create it with `nebula-cert ca --name <CA name>`.

### Creating Node Certificates
Every nodes connecting to the overlay must have a specific cert created with
`nebula-cert sign -name <node name> -ip '42.69.16.5/24' [--groups <group,group,...>]`.
Each cert contains:
- the ip address of the node
- the name of the node (can be whatever you want or a FQDN)
- all the groups the node is a menber of

If the name is a FQDN the nebula lighthouse can serve that name over DNS
and you can delegate to it as an NS record.

### Extend Access Beyong Overlay Hosts
See [Extend network access beyond overlay hosts](https://nebula.defined.net/docs/guides/unsafe_routes/).

Overall procedure:
- On the host where the subnet exist: you must generate a certificate with the
  `subnet` option.
- On hosts need access to the subnet: you must modify the config.yml file and
  add the subnet under the `unsafe_routes` standza.

### DNS
The lighthouse can also be a DNS server.
You retreive your cert from the lighthouse with a DNS request (TXT record):
`dig @<lighthouse addr> <your ip addr> txt`

## Running
Nebula can run with its own user but the exe need capabilities
(to create tun device and to bind to port 53) that can be set with:

`sudo setcap cap_net_bind_service,cap_net_admin=ep ~/.local/bin/nebula`.

## Running as a Service
You can use this systemd service file (`/etc/systemd/system/nebula.service`):
```
[Unit]
Description=Nebula overlay networking tool
Wants=basic.target network-online.target nss-lookup.target time-sync.target
After=basic.target network.target network-online.target
Before=sshd.service

[Service]
SyslogIdentifier=nebula
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nebula -config /etc/nebula/config.yml
Restart=always

[Install]
WantedBy=multi-user.target
```
and start it with:
```
#Reload the daemon files
systemctl daemon-reload
#Start and enable the service
systemctl enable --now nebula
```

Nebula should run under its own user created with:
```
sudo addgroup nebula
sudo adduser --home /nonexistent --no-create-home --disabled-password --disabled-login --ingroup nebula nebula
```

### Configuration Update
Modifications of the configuration file are not loaded automatically.
You can either restart the nebula service or send the HUP signal:
`killall -HUP nebula`.

## Phone Configuration
1. Generate a public key on your phone with the nebula app.
2. Get that key to your computer (with sharing).
3. Generate this public key on your computer with your CA key:
   `nebula-cert sign -in-pub phone.pub -name <name> -ip <ip>`.
   you will get a `phone.crt` file.
4. Send file `phone.crt` to your phone.
5. Copy the file content in the `Certificate PEM Contents` box.
6. Copy to your phone the CA public key (CA.crt).
7. Copy the file content in the `CA PEM Contents` box.
8. Set the lighthouse ip addresses.

## References
[Building a Secure Internal Network with Nebula](https://www.apalrd.net/posts/2023/network_nebula/)
