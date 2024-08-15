# Freebox (fibre)
## Jargon
- [ONU](https://www.busyspider.fr/Free-fibre-optique-quel-kit-fibre-branchement-selon-freebox-ou-abonnement-onu-ou-module-fibre.php#onu)
  Optical Network Unit: Boitier convertisseur (PON <-> Ethernet) entre fibre et freebox.

Voir: [Boîtier ONT et module SFP : différences, avantages et inconvénients](https://www.echosdunet.net/dossiers/fibre-ont-sfp)

## Informations techniques
Les données WAN fibre Internet transitent dans le vlan 836 tandis que les données
TV utilisent le vlan 835.
Le réseaux Free ne supporte que IPv6. IPv4 transite dans un tunnel 4rd (ipip6 d’[ip-tunnel](https://manpages.debian.org/stretch/iproute2/ip-tunnel.8.en.html)).
L'addresse publique de la freebox est récupérée avec une requète DHCPv6.
[Free ZMD (4rd) - IPv4 FullStack + 1/4 IPv4 + Plage /60 IPv6 - OpenWrt](https://lafibre.info/remplacer-freebox/tuto-free-zmd-ipv4-fullstack-14-ipv4-plage-60-ipv6/)
[Dégager la freebox serveur](https://lafibre.info/materiel-informatique/degager-la-freebox-serveur-routeur-wifi-firewall-que-me-conseillez-vous/msg842768/#msg842768)
[Remplacer sa freebox (non Delta) par un routeur Ubiquiti en ZMD (10G-EPON)](https://lafibre.info/remplacer-freebox/tuto-remplacer-sa-freebox-par-un-routeur-ubuiquity-en-zmd-10g-epon/?PHPSESSID=0ud635gs2q3a3vkn8gpuk0ku7l)

## Remplacement
Candidats:
- NanoPi r2s: 4 Coeurs A53, 1 Go, 1 USB2, 2 Gb eth
- NanoPi r4s: 6 coeurs A53/A72, 4 Go, 2 USB3, 2 Gb eth
- NanoPi r5c: 4 coeurs A55, 4 Go, @ USB3, 2 Gb eth, 32G emmc, mpcie
- Radxa E25: équivalent r5c

WiFi:
- mt7922: WiFi 6E

- [openwrt pour r5c](https://github.com/mj22226/openwrt/releases/tag/linux-6.1)
- [DIY Wi-Fi 6E AP](https://mans0n.github.io/2023/01/24/diy-6ghz-ap/)
- voir aussi immortalwrt

# Références
[Avoir Internet en fibre sans utiliser la Freebox](https://gonzague.me/avoir-internet-en-fibre-sans-utiliser-la-freebox-possible)
[Remplacer la Freebox par un router](https://lafibre.info/remplacer-freebox/remplacer-la-freebox-par-un-router-pour-les-nuls/)
[Freebox Pro - analyse entre l'ONU et la box](https://lafibre.info/free-pro/freebox-pro-analyse-entre-lonu-et-la-box/)
[Internet Vlan 836 sans freebox](https://lafibre.info/remplacer-freebox/internet-vlan-836-sans-freebox/)
[Fibre free sans freebox](https://tristramg.eu/fibre-openwrt/)
[Tutorial : remplacer la Freebox par une box GNU/Linux](https://lafibre.info/remplacer-freebox/tutorial-remplacer-la-freebox-par-une-box-gnulinux/)
[arcep](https://cartefibre.arcep.fr/)
[Remplacer Freebox](https://lafibre.info/remplacer-freebox/)
[Utiliser un serveur Linux à la place de la freebox pour débrider la connexion](https://lafibre.info/remplacer-freebox/utiliser-un-serveur-linux-a-la-place-de-la-freebox-pour-debrider-la-connexion/)

