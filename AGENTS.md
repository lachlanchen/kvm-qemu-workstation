# Repository Guidelines

## Scope

This repository contains sanitized KVM/QEMU orchestration, installation notes,
and guest bootstrap helpers for Windows and macOS experiments on Linux.

## Safety and privacy

- Keep VM disks, installation media, firmware variable stores, TPM state,
  machine identifiers, host keys, credentials, browser profiles, and raw logs
  outside Git.
- Bind VNC, noVNC, SSH, and RDP forwards to loopback unless a documented tunnel
  protects them.
- Use graceful guest shutdown first. A force-stop command must verify ownership
  from the exact disk path and process name before signalling QEMU.
- Never change host boot, firmware, partition, CPU-core, GPU, or network policy
  from these launchers.
- Do not start Windows and macOS guests together without checking host memory,
  swap, active heavy jobs, and the shared workstation policy.

## Validation

- Run `bash -n` on every shell script.
- Run `git diff --check` before committing.
- Run the profile README validator before publication.
- PowerShell scripts must parse under PowerShell when a Windows host is
  available; otherwise document that validation boundary honestly.

## Documentation

- Keep the English and ten translated READMEs synchronized.
- Mark host-specific observations as verified examples, not universal claims.
- Preserve provenance hashes for audited source snapshots, but never publish
  proprietary installer media.
