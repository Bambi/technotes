# IPv6
## Addresses
* node-local: `::1/128`. Loopback.
* link-local: `fe80::/10`
* global-unicast: `2000::/3`. Routable addresses with format:
  - global routing prefix (48 bits)
  - subnet id (16 bits)
  - interface id (64 bit)
* unique-local: `fc00::/7`. Not routable on public Internet.
