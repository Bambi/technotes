# Tracing
## Intro
- _tracing_ record events in a program: each event is recorded with data like timestamp,
  user data, system data (ex: function name, line number, cpu, process...). Should
  be done with minimal overhead.
- _profiling_ record only the number of time events have been occured. They have less
  information than traces but also have less overhead (cpu & memory overhead).

## Linux Kernel
[Introduction to Linux Tracing and its Concepts](https://events.linuxfoundation.org/wp-content/uploads/2022/10/elena-zannoni-tracing-tutorial-LF-2021.pdf)
Main source of events for tracing/profiling in the Linux kernel:
- Kprobes for dynamically tracing kernel functions
- Uprobes for dymanic instrumentation of user-space functions
- Tracepoints for static kernel instrumentation
- USDT for user-space instrumentation
See [here](https://jvns.ca/blog/2017/07/05/linux-tracing-systems/) for an overview
of the Linux kernel tracing system.

### KProbes
KProbes can be seen as breakpoints: they are a way to stop normal program (kernel)
execution and do some tasks. They are dynamically inserted in any place of the
kernel code (for kprobes) and allow tracing or profiling. For example to see files
being opened you can:
`sudo ./kprobe 'p:myopen do_sys_open filename=+0(%si):string'`.
kprobes are for Linux kernel while [uprobes](https://lwn.net/Articles/499190/)
are for user space programs.
ex: `sudo ./bin/uprobe 'r:bash:readline +0($retval):string'`.
> ELINOS: enable KPROBE feature and kernel function tracer (CONFIG_FUNCTION_TRACER)
> in kernel.

There is also Kretprobes & Uretprobes which place probes at end of functions.

#### Usage
CONFIG_KPROBES must be set on kernel configuration.
- list available functions: `less available_filter_functions`
- add a probe point: `echo p:probename fct > kprobe_events`
- enable a probe: `echo 1 > events/kprobes/probename/enable`
- get result: `cat trace`
How to dump arguments for kprobes depends on the architecture. For x86_64:
- 1st arg: `%di`
- 2nd arg: `%si`
- 3rd arg: `%dx`
- 4th arg: `%cx`

KProbes are available as an API in the kernel and can be used when the kprobes
script is not enough (for example doing custom tasks in probes, other than dumping
registers). An examples is available in the kernel source code in `samples/kprobes`.

References:
- [Kprobe-based Event Tracing](https://www.kernel.org/doc/html/latest/trace/kprobetrace.html)
- [Getting function arguments using kprobes](https://stackoverflow.com/questions/10563635/getting-function-arguments-using-kprobes)
- [perf-tools (shell scripts to ease use of ftrace)](https://github.com/brendangregg/perf-tools)

### Tracepoints (or Events)
A tracepoint placed in code provides a hook to call a function (probe) that you can provide at runtime.
A tracepoint can be “on” (a probe is connected to it) or “off” (no probe is attached).
When a tracepoint is “off” it has no effect.  When a tracepoint is “on”,
the function you provide is called each time the tracepoint is executed,
in the execution context of the caller. When the function provided ends its execution,
it returns to the caller.

The tracepoint mecanism provided by the kernel is used by both Ftrace, Perf, Systemtap and LTTng.
Two elements are required for tracepoints :
- A tracepoint definition, placed in a header file.
- The tracepoint statement, in C code.

Tracepoints can be created with either the `DECLARE_TRACE`/`DEFINE_TRACE` macros
[see](https://docs.kernel.org/5.19/trace/tracepoints.html)
or the `TRACE_EVENT` macro [see](https://lwn.net/Articles/379903/).
To save space, tracepoints that have the same signature can be grouped into
an `EVENT_CLASS` [see](https://lwn.net/Articles/381064/).
Tracepoints are usually declared in `include/trace/events` but they can also be
declared in kernel modules [see](http://lwn.net/Articles/383362/).

A tracepoint is declared with the following data:
- name - the name of the tracepoint to be created.
- prototype - the prototype for the tracepoint callbacks
- args - the arguments that match the prototype.
- struct - the structure that a tracer could use (but is not required to)
  to store the data passed into the tracepoint.
- assign - the C-like way to assign the data to the structure.
- print - the way to output the structure in human readable ASCII format.

### [Ftrace](https://www.linuxembedded.fr/2018/12/les-traceurs-sous-linux-12)
[Event Tracing](https://www.kernel.org/doc/html/v4.19/trace/events.html)
Standard tracing system on Linux. Depend on the TraceFS (pseudo filesystem).
Usage overview:
- Through the TraceFS (mounted on `/sys/kernel/debug/tracing`) you specify
  the probes you (not) want to listen
- Through the TraceFS you get the tracing result by reading `/sys/kernel/debug/tracing/trace`
- no need any user tool but a cli tool `trace-cmd` can be used to ease the process

#### Usage for Static Traces
- list available static traces with `cat available_events`
- enable one or more event with `echo xxx >> set_event`
- disable an event by prefixing its name with `!`: `echo !xxx >>set_event`
- disable all events: `echo > set_event`
- you can enable all events of a subsystem: `echo 'irq:*' > set_event`
- activate/deactivate tracing: `echo 0/1 > tracing_on`
- set trace buffer size: `echo 10000 > buffer_size_kb`

#### Usage for Function Tracing
Ftrace can trace function called in the kernel.
- list available tracers: `cat available_tracers`.
  You must have `function` or `function_graph`
- enable a tracer: `echo function > current_tracer`
- find function to trace: `less available_filer_functions`
- trace a specific function: `echo fct > set_ftrace_filter`
  You can use the `*` pattern

### [LTTng](https://www.linuxembedded.fr/2019/02/les-traceurs-sous-linux-22)
- An instrumentation point is a point, within a piece of software, which, when executed,
  creates an LTTng event.
- instrumentation point can be:
  - LTTng tracepoint (staticaly defined in the kernel code)
  - Linux kernel system call (enter, exit)
  - Linux kprobe
  - Linux kretprobe (entry or exit of a function)
  - Linux user space probes

### BPF
- Infrastructure that allows user defined programs to execute in kernel space.
- Programs written in C and translated into BPF instructions using compiler
  (gcc or clang/llvm), loaded in kernel and executed
- 10 64-bit registers
- Language with ~100 instructions
- Safety checks are performed by BPF program verifier in kernel
- Kernel has JITs for several architectures
- Needs a userspace program to do the housekeeping: compile the bpf program, load it, etc
BPF can be used for Kprobes, tracepoint and perf events.

### [BpfTrace](https://github.com/iovisor/bpftrace)
- Provides a collection of scripts that can do tracing using bcc under the hood.
- Wrapper around [BCC](https://github.com/iovisor/bcc), provides higher level syntax
- Similar syntax to DTrace

### Perf
- In kernel user-space tool
- Originaly for profiling (`perf record`) but now can be used for tracing (`perf probe`)
- `perf stat` to get general overview of user-space program system performance

### DTrace
- Port of DTrace from Sun
- Replaced on Linux by [bpftrace](https://github.com/iovisor/bpftrace)
- [see](https://www.brendangregg.com/blog/2018-10-08/dtrace-for-linux-2018.html)

## User Space
### [uftrace](https://github.com/namhyung/uftrace)
- For tracing and profiling.
- can trace function call, library call, system call.
- can trace function arguments and return values.

### [Perfectto](https://github.com/google/perfetto)
- from Google
- provides a user-space library for user-space trace events for C++
- provides view and analytics tools

### LTTng
It is possible to define trace events in user-space programs with the
`LTTNG_UST_TRACEPOINT_EVENT` macro which need:
- tracepoint name
- tacepoint provider
- arguments to record
Traces can be extracted and analysed with the same tools and utilities than with
the kernel. Does not depends on any kernel function for user-space applications.

### [Barectf](https://barectf.org/)
Tracing for user-space C programs. The trace code is generated from a yaml description.
Running application generates traces in CTF binary data stream format
that can be translated to a CTF Trace (Common Trace Format) which in turn can be
processed with Babeltrace.
Barectf does not rely on any kernel functions. It is useful if you only need static
tracing in user-space application. If you also want dynamic tracing or kernel tracing
you should have a look at LTTng.

### [SystemTap](https://sourceware.org/systemtap/wiki)
Based on a scripting language and a tool `stap` that compile the script into C code,
generates a kernel mode and load that module in the running kernel.
The scripting language tells what to do when events occurs (could be tracing events,
syscalls, timers, function calls, USDT traces, etc..).
[see](https://www.linux.it/~ema/posts/systemtap-intro/).
To be used SystemTrap require:
- root access (or belonging to the `stapdev` group)
- a C compiler

### [USDT Probes](https://lwn.net/Articles/753601/)
User Statically-Defined Tracing (USDT) probes come from the DTrace (Sun) project
but they are now available with SystemTap.
To instrument an application one need:
- include `sys/sdt.h` provided by systemtap
- use the `DTRACE_PROBEn` in the code or (see glib source code):
  - declare probes in a definition file which is compiled into a .h header file
  - include the generated header in your code
  - use the defined macros in your code
If you use either the `DTRACE_PROBE` macro or the probe definition file, a user
probe is declared with:
- a provider, an arbitrary symbol identifying your application or subsystem
- a name,
- a list of parameters
See details [here](https://sourceware.org/systemtap/wiki/AddingUserSpaceProbingToApps).

### [Recorder](https://github.com/c3d/recorder)
High efficient lock-free tracing system:
- Records information about your program continuously while it's running using
  simple printf-like statements
- Classify recorded data in different categories (ring buffers) to preserve both
  old important events and recent, rapidly-firing events
- Dump recorded data on demand, notably in response to signals or from debugger
- Can trace specific categories of records, i.e. print them as they happen
- Can export specific data to shared memory channels for external visualization
- A simple Qt5.9-based visualization tool shows content of data channels in real-time
- For tracing and profiling
- LGPL Licensed

## References
- [A Comparison of ftrace and LTTng for Tracing Baremetal and Virtualized Workloads](https://archive.fosdem.org/2021/schedule/event/comparison_ftrace_lttng/)
- [Comparison between perf, Ftrace, LTTng and GDB tracepoints](https://dmct.dorsal.polymtl.ca/sites/dmct.dorsal.polymtl.ca/files/Presentation.pdf)
- [Linux tracing and debugging](https://www.osadl.org/fileadmin/dam/presentations/HOT-04-2020/HOT-2020-04-Technical-Session-2a-Linux-kernel-debug-and-trace-interface.pdf)
- [Choosing a Linux Tracer](https://brendangregg.com/blog/2015-07-08/choosing-a-linux-tracer.html)
- [Exploring USDT Probes on Linux](https://leezhenghui.github.io/linux/2019/03/05/exploring-usdt-on-linux.html)
- [Practical Linux tracing](https://tungdam.medium.com/things-you-should-know-to-begin-playing-with-linux-tracing-tools-part-i-x-225aae1aaf13)
- [Comparing SystemTap and bpftrace](https://lwn.net/Articles/852112/)
- [Linux Perf Tools](http://events17.linuxfoundation.org/sites/events/files/slides/perf-collabsummit-2015.pdf)
