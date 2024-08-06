# Vector Packet Processor
## Installation
Ubuntu installation, use [fdio](https://packagecloud.io/fdio) packages:
```sh
curl -s https://packagecloud.io/install/repositories/fdio/2402/script.deb.sh | sudo bash
sudo apt install vpp vpp-plugin-core vpp-plugin-dpdk
sudo apt install vpp-dev # for development
```
After install the vpp service (vpp) should be running. You can start/stop the
service with `service vpp start|stop`.
A vpp user is created. To avoid running tools with root rights you should add
your user to the vpp group: `sudo usermod -a -G vpp as`

## Features
- vector packet processing: process a bunch of packets (up to 256) at a time
  to increase performance by reducing data cache misses and by prefetching the
  next packet in the vector.
- packet processing graph: used to decompose the processing pipeline. the graph
  is applied to packet vectors, node by node. Plugins can create graph nodes,
  rearrange the graph.
- implement L2 - L4 network stack.
- interract with the host stack though veth interfaces.
- support containers and VMs.
- comes with continuous integration and testing system.

## Architecture
Unless DPDK which is a library, VPP is a framework running a daemon (vpp)
configured with a startup file (`/etc/vpp/startup.conf` by default).

Developper will write plugins which will be loaded and run by the vpp daemon.
Most of vpp features are implemented as in-tree plugins.
A plugin can add nodes graph, rearange the node graph and add API.
Plugins are loaded with `dlopen()`.

It is possible to run multiple vpp instances but each instance must have a specific
name or prefix. Also only one instance can use the DPDK plugin.

A shell (`vppctl`) is used to interract with the daemon. You can launch it with the
socket created by the daemon: `vppctl -s /run/vpp/cli-vpp1.sock`.

### Layering
VPP is composed of several libraries each made from the previous one.
- VPP infra: meory management, vectors, rings, hashing.
- Vlib: buffer, graph, node management, tracing, threading, CLI and main().
- Vnet: networking management: devices, L2-4, session management, overlays, control plane.
- Plugins: can implement any functionnality.

## vppctl
Main commands:
- `create host-interface name <name>`: create a vpp interface with the host (veth).
- `set interface state <name> up|down`:
- `set interface ip address <intf> <addr>`: set interface ip address.
- `show interface`: show interface list.
- `show hardware-interfaces`: show detailed interface list.
- `show interface addr`: show L3 interface addresses.

Routing and switching:
- `show ip neighbors`: show ARP table.
- `show ip fib`: show routing table.
- `ip route add <ip/mask> via <gw ip>`: add an ip route.

Tracing and debugging commands:
- `show trace`:
- `clear trace`: clear trace buffer and added traces.
- `trace add <graph node> <nb>`: add a trace, nb: trace buffer size (nb packets).
- `show runtime`: list registered plugins
- `show version`: show VPP version.

See also [Useful Debug CLI](https://fd.io/docs/vpp/v2101/reference/cmdreference/index.html)
and [CLI Reference](https://s3-docs.fd.io/vpp/24.02/cli-reference/index.html).

`host-interface` are VPP interfaces that will attach to Linux AF_PACKET interface (veth).

`memif` interfaces are software interface used between VPP instances or applications.
They are created by pair (a pair must share the same id) and one of them is `master`
while the other one is `slave`:
`create interface memif id x [master|slave]`.

## Development
A vector of packets is called a *frame* (~ vector). Each element is called a
*vector* (~ packet). A vector is an index to a `vlib_buffer_t`.

VPP uses as much as possible specific programming style that increase performance
such as multi-loop, branch prediction (`unlike()`), function flattening, lock-free
structures.

Graph nodes are optimized to fit inside the instruction cache and packets are
pre-fetched into the data cache.

### Compilation
```sh
make install-dep
make build[-release]
```

### VPPInfra Library
Collection of high-parformance dynamic arrays, bitmaps, high-precision real-time
clock, event logging, data structure serialization.
- `types.h`: defines `u8, u16, u32, u64, i8, ..., f32, f64, uword`

#### Vectors (vec.h)
A vector is a dynamicaly resized array of data with user defined header.
Many vpppinfra data structures (e.g. hash, heap, pool) are vectors with various different headers.
The memory layout looks like this:
- user header (optional)
- Aligment padding (if needed)
- Nb elements
- Element 1  <- user pointer
- Element 2
...
- Element N-1

Null pointers are valid vectors of lenght 0 (but pointers to un-initialised vector
is not supported!).

#### Format
Equivalent to `printf()`. The first argument is a vector (`u8*`) to which it appends
the result of the current operation. This makes chaining calls easy:
```c
u8 * result;
result = format (0, "junk = %d, ", junk);
result = format (result, "more junk = %d\n", more_junk);
```
The `%U` format is handy for a user-defined format:
```c
u8 * format_junk (u8 * s, va_list *va)
{
  junk = va_arg (va, u32);
  s = format (s, "%s", junk);
  return s;
}
result = format (0, "junk = %U", format_junk, "This is some junk");
```
#### Unformat
Equivalent to `scanf()` but more general. Support the `%U` for user-defined format.

#### Errors and Warnings
Many VPP functions return the type `clib_error_t*`. Theses are abritrary strings
with a bit of metadata (error/warning). Returning a null `clib_error_t*` indicates
a no-error.

#### Shared-memory Message API
Asynchronous message-passing API over unidirectional queues is used for communication
between VPP and applications (API are also available via sockets). This makes it
possible to capture the messages and replay them for debugging purpose.

#### Debug CLI
Debug CLI commands are easy to add:
```c
static clib_error_t *
show_ip_tuple_match (vlib_main_t * vm,
                     unformat_input_t * input,
                     vlib_cli_command_t * cmd)
{
    vlib_cli_output (vm, "%U\n", format_ip_tuple_match_tables, &routing_main);
    return 0;
}
static VLIB_CLI_COMMAND (show_ip_tuple_command) = {
    .path = "show ip tuple match",
    .short_help = "Show ip 5-tuple match-and-broadcast tables",
    .function = show_ip_tuple_match,
};
```
Debug CLI is available with debug builds. It is also possible to expose the CLI
as a telnet interface.

#### Packet Tracer
Vlib can trace packets (available with the `trace` command).
Traces can be put on input nodes:
`af-packet-input`, `avf-input`, `bond-process`, `dpdk-crypto-input`,
`dpdk-input`, `handoff-trace`, `ixge-input`, `memif-input`, `mrvl-pp2-input`,
`netmap-input`, `p2p-ethernet-input`, `pg-input`, `punt-socket-rx`,
`rdma-input`, `session-queue`, `tuntap-rx`, `vhost-user-input`, `virtio-input`,
`vmxnet3-input`.

### API
The VPP binary interface is a message passing API that support method types:
- *Request/Reply*: client sends a message and server reply with a signe message.
- *Dump/Detail*: client send a bulk request message and server reply with one or
  a set of detail messages. Used for acquiring bulk information like the complete
  FIB table.
- *Event*: client register for getting asynchronous notifications from the server.

Messages from the client must include a client index and a context field to let
the client match request with reply (comminucation is asynchronous).

Types are C types (u8, u16, u32, u64, i8, i16, i32, i64). Strings are represented
as `u8[]` or with the string typedef. Ex:
```c
define show_version {
   u32 client_index;
   u32 context;
};

define show_version_reply {
   u32 context;
   i32 retval;
   string program[limit=32];
   string version[limit=32];
   string build_date[limit=32];
   string build_directory[limit=256];
};
```

### Vnet Library

### Graph Node
Created with the `VLIB_REGISTER_NODE()` macro. A graph node is a structure with:
- a name, can be seen with `show runtime`
- a number of error codes `n_errors`
- `error_strings`, vector of strings indexed by error code. see `show errors`.
- `n_next_node`, number of next nodes that follow
- `next_nodes[]`, names of next nodes which this node feeds into.
- `vlib_node_function_t*`: vector processing function for this node

Each node expose a binary API and a CLI.
The API is implemented as a high performance shared-memory ring buffer and allows
asynchronous callback. The API is also usable from different languages (Python,
Go, Java).
The CLI is accessible via a Unix socket and is composed of a list of commands.

Packets are processed in group of 4, remaining packets are processed one by one:
. while packets in vector
  . while 4 or more packets
    . prefetch #3 and #4
    . process #1 and #2
    . update counters, advance buffers
    . enqueue packet to next node
  . while any packets
    . same as above but single packet

### Memif Library (libmemif)
Memif provides a high performance packet exchange between user application and
VPP or between multiple user application. Memif provides a virtual network interface
on top of shared memory.
Libmemif is located under `extras/libmemif` and must be build separately.

### Plugin Development
- [FD.io: How to develop and maintain an out-of-tree VPP plugin](https://wiki.lfnetworking.org/display/LN/2022-11+-+FD.io%3A+How+to+develop+and+maintain+an+out-of-tree+VPP+plugin)

You can generate a plugin skeleton with the `make_plugin.sh` script.
A plugin will define a `main_t` structure that should contains the plugins specific
data structures (avoid creating static or global variables).
A plugin use the macro `VLIB_PLUGIN_REGISTER` to register itself into the vpp
binary API message dispatcher. VPP uses `dlsym()` to find the `vlib_plugin_registration_t`
data generated by the register macro (must be present in the `.so` file to be
considered as a plugin).

#### API file
This file contains the API message definitions. It defines data structures exchanged
between the plugin and VPP. Theses structures are then generated as C code for VPP
but can also be generated in other programming languages if the plugin is not written
in C.

For each message defined in the API file the plugin have to implement a handler which
will receive a message pointer `*mp` (the struct defined in the API file) and return
an other message pointer `*rmp` of the reply type.

The `autoreply` keyword before a message definition will make the generation of
an implicit message (named `<message>_reply`) containing only a return value.

API messages are net-endian and VPP is host-endian so you will need to use:
- `u32 value = ntohl(mp->value);`
- `rmp->value = htonl(value);`

## Definitions
- FIB (Forwarding Information Base): forwarding table optimized for speed used
  to associate addresses (IP, MAC) to output ports/VLAN.

## References
- [VPP Wiki](https://wiki.fd.io/view/VPP)
- [VPP Docs](https://s3-docs.fd.io/vpp/24.02/)
- [IPng Networks](https://ipng.ch/s/articles/)
- [VPP Guide](https://pantheon.tech/vpp-guide/)
