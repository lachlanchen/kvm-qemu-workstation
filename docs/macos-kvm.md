# macOS KVM integration

The macOS implementation remains in
[`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh), where its
OpenCore, recovery, Apple-service identity, storage, and Xcode boundaries are
already reviewed and documented. This repository provides a common dispatcher
without duplicating that sensitive logic.

Clone both repositories as siblings, or point the dispatcher at the launcher:

```text
KVM_WORKSTATION_MACOS_LAUNCHER=/path/to/hackintosh/scripts/hackintosh-kvm.sh
kvm-workstation macos status
kvm-workstation macos start
kvm-workstation macos url
```

The verified reference profile uses Sequoia, a sparse 512 GiB qcow2, 16 GiB
RAM, OpenCore, loopback-only noVNC, user-mode NAT, and no GPU, USB-controller,
or physical-disk passthrough. NVIDIA RTX 4090 and Intel UHD 770 are not viable
modern macOS passthrough targets for that host, so the virtual display is a
stability choice rather than a graphics-performance design.

Do not commit or share Apple installers, an Apple SMC key, OpenCore private
identity values, EFI variables, Apple credentials, signing certificates, or
guest disks. Apple licenses macOS virtualization for Apple-branded hardware;
the referenced non-Apple KVM profile is an unsupported interoperability
experiment, not an Apple-supported deployment.

See the Hackintosh repository's `docs/24-z790-kvm-sequoia.md` for the exact
verified installation chronology, Apple Account troubleshooting boundary,
Xcode setup, and recovery procedures.
