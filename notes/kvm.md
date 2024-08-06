# KVM

## Virsh Commands
- `virsh list [--all]`: list running (and inactives) VM
- `virsh shutdown [--force] <VM>`: restart a VM
- `virsh start <VM>`: start a VM
- `virsh destroy [--graceful] <VM>`: force a VM to stop
- `virsh snapshot-create-as --domain <VM> --name <name>`: create a snapshot from a stopped VM
- `virsh snapshot-revert --domain <VM> --snapshotname <name>`: revert a VM from a snapshot
- `virsh console --force <VM>`: console into the VM
- `virsh send-key <VM> KEY_LEFTALT KEY_SYSRQ KEY_B`: send sysrq key sequence (reboot system)
