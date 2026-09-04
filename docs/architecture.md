# Architecture and trust boundaries

## One command surface, separate implementations

`bin/kvm-workstation` is deliberately small. It dispatches Windows commands to
the launcher in this repository and macOS commands to the separately audited
[`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh) launcher.
That separation avoids copying private OpenCore identity handling into a
general Windows repository while still presenting one daily command surface.

```text
kvm-workstation
├── windows -> windows/tiny11/windows-tiny11-kvm
└── macos   -> hackintosh/scripts/hackintosh-kvm.sh
```

The default paths are replaceable with environment variables:

- `KVM_WORKSTATION_WINDOWS_LAUNCHER`
- `KVM_WORKSTATION_MACOS_LAUNCHER`
- `WINDOWS_TINY11_RUNTIME_ROOT`
- `WINDOWS_TINY11_KVM_CONFIG`

## Runtime isolation

Source code belongs in Git. Mutable or licensed artifacts belong in a private
runtime root. For Windows, the default is
`~/.local/share/kvm-qemu-workstation/windows-tiny11`; a large mounted disk is a
better override for real use. The runtime root contains the sparse qcow2,
install media, OVMF variables, TPM state, sockets, logs, and generated noVNC
web root.

All host forwards bind to `127.0.0.1`. QEMU user-mode networking avoids host
bridge and firewall changes. A remote operator should create an SSH tunnel to
the host rather than exposing VNC, RDP, or guest SSH.

## Resource model

The Windows default is 4 vCPUs, 8 GiB RAM, and a sparse 128 GiB qcow2. The
macOS reference profile defaults to 8 vCPUs, 16 GiB RAM, and a sparse 512 GiB
qcow2. Sparse disks reserve virtual capacity but consume physical storage only
as blocks are written. Guest RAM is demand-backed on the host, but each guest
still sees a fixed ceiling for that launch.

These guests are intentionally manual-start. On a shared workstation, check
available memory, swap, existing QEMU processes, and heavy project jobs before
running both together.

## Ownership and shutdown

The Windows launcher recognizes QEMU only when its PID file, process name, and
exact disk path agree. `stop` requests ACPI shutdown through QMP and waits;
`force-stop` signals only that verified process. A noVNC tmux session is reused
rather than creating a second project console.
