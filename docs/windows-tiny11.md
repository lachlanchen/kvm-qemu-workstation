# Windows Tiny11 on KVM/QEMU

## What was verified

On 2026-09-04, the reference workstation completed a clean installation and
two shutdown/restart checks with this profile:

| Component | Verified example |
| --- | --- |
| Host | Ubuntu 24.04, QEMU 8.2.2, KVM, OVMF, swtpm 0.7.3 |
| Guest | Windows 11 Pro 25H2, build 26200, reduced locally with regular Tiny11 builder |
| Resources | 4 vCPUs, 8 GiB RAM, sparse 128 GiB qcow2 |
| Console | QEMU VNC behind loopback-only noVNC |
| Integration | QEMU guest agent, OpenSSH, RDP, VirtIO guest tools |
| Application check | WeCom 5.0.10.6015 installed from its verified WinGet manifest |

This is a verified example, not a promise that future Windows, QEMU, or
Tiny11 builder versions will behave identically.

## Host preparation

Install the distribution packages for QEMU/KVM, OVMF, swtpm, noVNC,
websockify, tmux, and `qemu-utils`. Confirm that the current account can read
and write `/dev/kvm`.

Choose a private runtime on a filesystem with enough free space:

```text
WINDOWS_TINY11_RUNTIME_ROOT=/path/to/VirtualMachines/Windows-Tiny11
```

Place installation media under its `installer/` directory using these names,
or override each path in the private config:

- `tiny11.iso`
- `virtio-win.iso`
- `tiny11-tools.iso`

The tools ISO should contain `guest/bootstrap.ps1`, `guest/verify.ps1`, and an
operator-supplied `authorized_keys` only when SSH key bootstrap is wanted.
Never commit that generated ISO or a machine-specific key list.

## Build a serviceable image

Use an official Microsoft Windows ISO and NTDEV's regular `tiny11maker.ps1`.
Do not use Tiny11 Core for this workflow: Core removes servicing, Windows
Update, and the component store. The included Windows scripts pin an audited
upstream commit, verify Microsoft `setup.exe`, select the exact Windows 11 Pro
image, apply a small non-interactive patch, and record the output hash.

From an elevated PowerShell on a Windows build host:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./windows/tiny11/build/prepare-build-host.ps1
$work = Join-Path $env:LOCALAPPDATA 'KvmQemuWorkstation\Tiny11Build'
& "$work\build-tiny11.ps1" -SourceIso 'C:\Path\Windows11.iso' -WorkDirectory $work
```

The 2026-09-04 reference build used Tiny11 builder commit
`00e7d8a151a39ccffccab4a267bb81fb3756a01d`. Always inspect upstream changes
before moving that pin. The repository includes only an adaptation patch, not
the upstream builder or Microsoft media.

## Install and operate

Set a large runtime path in a private config such as
`~/.config/windows-tiny11-kvm/config.env`, then run:

```text
windows/tiny11/windows-tiny11-kvm prepare
windows/tiny11/windows-tiny11-kvm verify
windows/tiny11/windows-tiny11-kvm start
windows/tiny11/windows-tiny11-kvm url
```

For one tested OVMF/QEMU combination, direct SATA optical boot timed out even
with an untouched Microsoft ISO. USB storage made the EFI filesystem visible,
but WinPE could not continue from that path alone. Attaching the same ISO
read-only twice solved both halves: USB for UEFI boot and SATA optical for
WinPE source access. The launcher retains this guarded initial-install path.
From the UEFI shell, the manual fallback was
`FS0:\EFI\BOOT\BOOTX64.EFI`.

After installation and guest checks succeed:

```text
windows/tiny11/windows-tiny11-kvm mark-installed
windows/tiny11/windows-tiny11-kvm stop
windows/tiny11/windows-tiny11-kvm start
```

The installed marker detaches every installer and helper ISO on subsequent
starts. `verify` also stops requiring those media after the marker exists.

## Access and lifecycle

Defaults are loopback-only:

| Host endpoint | Guest service |
| --- | --- |
| `127.0.0.1:6143` | noVNC web console |
| `127.0.0.1:3399` | RDP 3389 |
| `127.0.0.1:2290` | OpenSSH 22 |
| `127.0.0.1:5943` | raw VNC |

Use `status` before `start`, and use `stop` before `force-stop`. The VM is not
boot-enabled by default, which prevents an idle guest from silently competing
with macOS KVM, model workloads, or other shared projects.

Windows still requires a valid Microsoft licence. Tiny11 does not provide or
bypass activation.
