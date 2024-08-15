# Zero Tier
Secured meshed Wan overlay.

# Usage
To join a network: `zerotier-cli join <16-digit network ID>`
Use `zerotier-cli info` or `zerotier-cli status` to check connectivity.

```
zerotier-cli info -j
zerotier-cli listpeers
zerotier-cli peers   // easier to read than listpeers
```

# Troubleshoot
`zerotier-cli status -j` gives lots of info. If `tcpFallbackActive` is true then
there is relaying over TCP (slow).

## References
[Zerotier Download](https://download.zerotier.com/RELEASES/)
[Getting Started with ZeroTier](https://zerotier.atlassian.net/wiki/spaces/SD/pages/8454145/Getting+Started+with+ZeroTier)
