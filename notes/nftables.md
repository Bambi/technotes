# Nftables
iptables replacement.

- a table is a list of rules treated sequencially.
  Tables are used to separate rules for filtering/nat...
- a rule is an expression (a list of tests matching packet payload)
  and a statement (a list of action to perform when the expression matches).
- a chain is a list of rules (taken from a table) attached to a netfilter hook.

Table family can be `ip` (IPv4 packets), `ip6` (IPv6 packets), `inet` (IPv4/IPv6 packets).

Chains are not pre-configured and must be explicitly created. Hooks are
`prerouting`, `input`, `forward`, `output`, `postrouting`, `ingress`.

## Nft Usage
Nftables are managed with the `nft` tool.
```
  nft add table <famlily> <name>
  nft list tables
  nft delete table <famlily> <name>
  nft flush table <famlily> <name>  // empty a table
  nft list ruleset  // list whole set of tables, chains, etc
```

# References
[Nftables Wiki](https://wiki.nftables.org/wiki-nftables/index.php/Main_Page)
