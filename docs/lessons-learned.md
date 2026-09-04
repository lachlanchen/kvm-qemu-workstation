# Lessons learned

## Evidence before mutation

Validate media hashes, signatures, free space, `/dev/kvm`, port ownership, and
qcow2 consistency before boot. A boot failure is not proof of a corrupt ISO:
the reference Windows failure reproduced with both the original Microsoft ISO
and the derived image, while a dual-path USB/SATA attachment worked.

## Keep installation and daily boot separate

Installer media, VirtIO media, and bootstrap tools are useful only during
setup. A durable installed marker gives the daily launcher an explicit
disk-only mode and avoids accidental restarts into Setup.

## Keep consoles private and singular

Raw VNC is not an authentication boundary. Bind VNC and noVNC to loopback,
reuse one proxy per guest, and tunnel when operating remotely. A short landing
page can retain a stable URL while noVNC handles scaling and reconnection.

## Separate capacity from consumption

A sparse 128 GiB or 512 GiB qcow2 is a capacity ceiling, not immediate host
usage. Track both `virtual size` and `disk size`. RAM can be demand-backed, but
the guest still has a fixed configured ceiling for one boot.

## Build from trusted source, not mystery images

The Windows image was derived locally from signed Microsoft media using the
regular, serviceable Tiny11 builder. Exact source commits and hashes were
recorded. The build helper was isolated from the target VM; only the resulting
ISO crossed the boundary and its checksum was verified at both ends.

## Preserve OS-specific security boundaries

Windows needs TPM state, guest integration, and activation boundaries. macOS
needs OpenCore provenance, private machine identity, and licence boundaries.
A shared dispatcher is useful; merging their private state or identity logic
is not.

## Prefer reversible lifecycle controls

Normal stop is an ACPI/QMP request with a bounded wait. Force-stop validates
the exact project-owned process. Neither launcher modifies host firmware,
bootloaders, partitions, GPU policy, CPU-core policy, or network bridges.
