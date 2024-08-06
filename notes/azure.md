# Azure
## Format VHD (qemu vpc)
= format linux raw + 512 bytes.
To create a VHD file:
```sh
qemu-img convert -f raw -o subformat=fixed,force_size -O vpc disk.img disk.vhd
```
To get a raw disk from a VHD file (warning: qemu _does not_ auto-detect VHD files):
```sh
qemu-img convert -f vpc -O raw disk.vhd disk.img
```
See command [here](https://en.wikibooks.org/wiki/QEMU/Images#Image_types).

## Networking
A virtual router is created in every sub-network.
Its address is the first available address in the network (<network>.1). It is not pingable.

Inside a network each sub-network is automatically reachable (routing routes are automatically created).

In a virtual network you must use RFC1918 addresses except theses:
  * `224.0.0.0/4` (Multicast)
  * `255.255.255.255/32` (Broadcast)
  * `127.0.0.0/8` (Loopback)
  * `169.254.0.0/16` (Link-local)
  * `168.63.129.16/32` (Internal DNS)

Within a subnet some addresses are reserved:
  * `x.x.x.0`: Network address
  * `x.x.x.1`: Reserved by Azure for the default gateway
  * `x.x.x.2, x.x.x.3`: Reserved by Azure to map the Azure DNS IPs to the VNet space
  * `x.x.x.255`: Network broadcast address

DHCP via unicast, multicast, broadcast IP-in-IP and GRE packets are dropped within virtual networks.

## Routing
See [here](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview).
Next hop types:
  * Virtual appliance: a virtual machine
  * Virtual network gateway (VPN)
  * None: dropped traffic
  * Internet
  * Virtual network

A route is selected using the longuest prefix match algorithm.
User defined routes have a higher priority than system routes.

## Problems
168.63.129.16 should be accessible (but is not pingable). Test it with:
`wget http://168.63.129.16/?comp=versions`.

