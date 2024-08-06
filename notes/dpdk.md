# Data Plane Development Kit
## Overview
Provides a complete framework for fast packet processing:
- developement is done mainly in user-space
- all resources are allocated beforehand
- based on Poll Mode Drivers/PMD (to avoid interrupts overhead)

See [Programmer's Guide](https://doc.dpdk.org/guides/prog_guide/intro.html) for
reference.

## Architecture
Source organization:
- `dpdk/lib` contains libraries and kernel modules
- `dpdk/drivers` contains PMD drivers
- `dpdk/app`, `dpdk/examples` contains application (files with a `main()` function)

### Environment Abstraction Layer (EAL)
Set of libraries that provide a generic interface to the environment.
(time, pci access, memory alloc, process/thread management, atomic/lock operations...)

DPDK also use the standard libc and pthread libraries.

### Log Library
There is a logging library: on Linux logs are send to the console and syslog
while on Windows and FreeBSD logs are sent only to the console.

The log library provide 8 levels of severity and allow to manage logs for specific
components.

### Trace Library
Library to define static tracepoints:
- very efficients (can be used in control and fast path API)
- enabled or disabled at runtime globally or for a set of traces
- output format is Common Trace Format (LTTng).

### Command Line Library
For interactive sessions (shell) with Tab completion.

### Memory Management
Most of DPDK data is store in huge pages (2 MB or 1 G size for each page).
A memory segment (rte_memseg) is a number of contiguous huge pages.
A memory segment can be divided into memory zones which are the basic memory unit
used by other objects created in a DPDK application.

### Ring Library
Librte_ring provides a lockless multi-producer, multi-consumer FIFO API in a
fixed size table.
Rte_ring are used with ports for packet rx/tx and may be used as a general
communication mechanism between or inside a lcore.

### Memory Pool Library
Rte_mempool library are fixed size object pools that use rte_ring for storing
free objects. Mempool are identified by a unique name.
Rte_mempool also provides optional services such as per-core object cache and
alignment helper for higher performance.

### Buffer Management Library
Rte_mbuf is the equivalent of Linux kernel's sk_buff. It used to store packet data
but also metadata (ex: buffer length). Buffers are stored in a memory pool.
DPDK uses a single buffer to store both the metadata (first) and the packet data
(after). But it is possible to store the packet data on multiple buffers (for big packets).

### Other Libraries
- RCU lib: for lockless data structures
- Stack lib: API for using a bounded stack of pointers
- PMD lib: API to configure and communicate with user space drivers
- LPM/LPM lib: IPv4/IPv6 Longuest Prefix Match
- Hash lib: used for classifying and distributing packets
- Timer lib
- Many more...

### Lcores
Logical cores are an abstraction of user-level threads. They are created at application
startup (from command-line options or cnofiguration file) and can be associated
(affinity) with specific CPU.
There is always a main lcore which is running the `main()` function. Each lcore
is identified with a unique id.

### Ports
Where you get and send packets (~interfaces).
`./tools/dpdk-devbind.py -s` will list network devices using DPDK drivers.

## Installation
Dependencies:
- python >= 3.6
- meson
- pyelftools

```sh
meson setup builddir -Dmax_numa_nodes=1 -Dexamples=all
cd builddir
ninja
```

## Running Applications
### Device Preparation
DPDK requires ethernet ports to be managed by its special drivers (PMD drivers).
Theses drivers run in user-space and cannot share the device with the kernel.
This means that a port managed by a DPDK driver cannot be used by the kernel.
To be used by a DPDK application an ethernet port must be:
1. unbind from its kernel driver. See `/sys/bus/pci/drivers/*/unbind` or use
   the `dpkg-devbind.py` tool.
2. managed by either the vfio_pci (preferably), igb_uio or uio_pci_generic.
   Theses drivers are very basic drivers, most of the work is done by the PMD driver.
   Use the `dpkg-devbind.py` tool.

### System Preparation
To run a DPDK application huge pages must be configured beforehand (2M or 1G pages):
```sh
echo 256 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
```
Depending on how your system is configured you might have to run DPDK applications
with root privileges (for huge pages access).
DPDK app main command-line parameters are:
- `-l <corelist>`: set of cores to run on. This option is mandatory.
- `-n <num>`: number of memory channels per socket.
- `--vdev <driver><id>[,key=val, ...]`: ex `--vdev 'pcap0,rx_pcap=fic1.pcap,tx_pcap=fic2.pcap'`
- `--no-huge`: use anonymous memory instead of hugepages.
- `--log-level <type:val>`: ex: `--log-level lib.eal:debug`
- [more options](https://doc.dpdk.org/guides/linux_gsg/linux_eal_parameters.html)

## DPKG With pcap
- [TestPMD PCAP Tests](https://doc.dpdk.org/dts/test_plans/pmdpcap_test_plan.html)

## Tools
### Scapy
Read/write a pcap file:
```python
wrpcap("scapy.pcap", r)

pcap_p = rdpcap("scapy.pcap")
pcap_p[0]
```
Some other commands:
- `pkt.show()`: dump packet fields layer by layer
- `pkt.command()`: gives the string that will build the same object
- `pkt.summary()`: show packet
- `ls(IP, verbose=True)`: list packet fields
- `lsc()`: list available commands
- `help(cmd)`: describe command and arguments

## References
- [DPDK Cookbook](https://www.intel.com/content/dam/develop/external/us/en/documents/dpdk-cookbook-759202.pdf)
- [Writing a functional DPDK application from scratch](https://github.com/ferruhy/dpdk-simple-app)
- [Introduction to DPDK: Architecture and Principles](https://selectel.ru/blog/en/2016/11/24/introduction-dpdk-architecture-principles/)
