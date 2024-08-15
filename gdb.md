# Remote Debugging (gdbserver)
You must have gdbserver installed on the target machine and
gdb with the executable with debugging info on the work machine.

Start gdbserver on the target machine:
`gdbserver :2000 prog [prog args]`
You can also attach GDBserver to a process that’s already running:
`gdbserver HOST:PORT --attach PID`
Run gdb on the host machine:
`gdb -q prog`
Connect to the target:
`target remote ip:2000`

# Tracepoints


## dprintf
`dprintf location, template, expression [, expression...]`
Prints a statement evrytime it reach the location.
Ex: `dprintf http_handler.c:205, "URL: %s\n", http_ctx->url`

## break commands
```
break location [if condition]
commands
  [silent]
  ... command list ...
  continue
end
```
The silent statment tells gdb to ommit the usual status print-outs when a breakpoint is hit (“Breakpoint 1 …”). The continue statment causes gdb to continue execution after the commands are processed.

The above dprintf example can be reproduced using break commands as follows:

```
break http_handler.c:203
commands
  silent
  printf "URL: %s\n", http_ctx->url
  continue
end
```

This listing will print the stack trace, each time the read syscall was hit:

```
catch syscall read
commmands
   backtrace
   continue
end
```

# Invoking GDB

* `-x ,file`
  Execute commands from file file.
* `-ex command`
  Execute a single GDB command. May be used multiple times:
  `gdb -ex 'target sim' -ex 'load' -ex 'run' a.out`
* `-p number`
  Connect to process ID number, as with the attach command.
* `-batch`
  Run in batch mode. Exit with status 0 after processing all the command files specified with ‘-x’ (and all commands from initialization files, if not inhibited with ‘-n’).
