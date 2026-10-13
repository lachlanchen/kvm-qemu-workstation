[English](README.md) · [العربية](i18n/README.ar.md) · [Español](i18n/README.es.md) · [Français](i18n/README.fr.md) · [日本語](i18n/README.ja.md) · [한국어](i18n/README.ko.md) · [Tiếng Việt](i18n/README.vi.md) · [中文 (简体)](i18n/README.zh-Hans.md) · [中文（繁體）](i18n/README.zh-Hant.md) · [Deutsch](i18n/README.de.md) · [Русский](i18n/README.ru.md)

[![LazyingArt banner — apps and four buddies](https://github.com/lachlanchen/LazyingArtWebsite/raw/main/media/brand/lazyingart-intro.gif)](https://lazying.art)

# KVM QEMU Workstation

*Reproducible, private-by-default Windows and macOS virtual-machine workflows for Linux workstations.*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

This repository turns a long workstation experiment into a small, auditable
toolkit. It includes a complete sanitized Windows 11/Tiny11 KVM path, a common
dispatcher for Windows and macOS guests, and an integration boundary for the
separately audited Hackintosh KVM workflow. VM disks, proprietary installers,
credentials, host keys, TPM state, OpenCore identity, and private logs stay
outside Git.

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## Why this exists

KVM supplies Linux kernel acceleration; QEMU supplies the virtual machine and
devices. Together they can run isolated Windows and macOS development guests
without repartitioning the host. The useful part is not merely a long QEMU
command: it is the lifecycle around it—provenance checks, sparse storage,
loopback-only consoles, graceful shutdown, exact process ownership, and a
clear line between source code and private mutable state.

The reference Windows installation was verified on Ubuntu 24.04 with QEMU
8.2.2, OVMF, swtpm, a 128 GiB sparse disk, 8 GiB RAM, and 4 vCPUs. The macOS
path delegates to the existing `hackintosh` repository so private OpenCore and
Apple-service logic is not duplicated here.

## What is included

| Path | Purpose |
| --- | --- |
| `bin/kvm-workstation` | One command surface that dispatches Windows or macOS operations |
| `windows/tiny11/windows-tiny11-kvm` | Guarded KVM/QEMU lifecycle, local noVNC, TPM, QMP, RDP, and SSH forwarding |
| `windows/tiny11/build/` | Pinned Tiny11 builder preparation, non-interactive patch, build and reporting helpers |
| `windows/tiny11/guest/` | Idempotent Windows bootstrap and verification scripts |
| [`docs/uu-native-relay.md`](docs/uu-native-relay.md) | Native UU installation, separate VM port-mapping routes, and verification boundaries |
| `docs/windows-tiny11.md` | Proven installation recipe and dual-path UEFI boot lesson |
| `docs/macos-kvm.md` | macOS integration, licence boundary, and specialist-repo link |
| `docs/architecture.md` | Runtime isolation, resources, ports, ownership, and shutdown design |
| `docs/lessons-learned.md` | Reusable diagnostic and recovery decisions |

The regular, serviceable Tiny11 builder is used rather than Tiny11 Core.
Windows still requires a valid Microsoft licence. The macOS reference is an
unsupported interoperability experiment and remains subject to Apple's
licence terms.

## Quick start

Install QEMU/KVM, OVMF, swtpm, noVNC/websockify, tmux, and `qemu-utils` from
your Linux distribution. Clone this repository and the optional macOS
specialist repository, then install the dispatcher into your user path.

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

Set `WINDOWS_TINY11_RUNTIME_ROOT` to a large private filesystem before the
first Windows `prepare`. Use `WINDOWS_TINY11_KVM_CONFIG` for durable private
overrides. Set `KVM_WORKSTATION_MACOS_LAUNCHER` when the Hackintosh repository
is not at `~/Projects/hackintosh`. Read the Windows guide before supplying
installer media or marking a guest installed.

## Validation and boundaries

Run these checks after changes:

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

All default guest service and display forwards bind to `127.0.0.1`. Use an
authenticated SSH tunnel for remote access. The launchers do not modify host
firmware, bootloaders, partitions, CPU-core policy, GPU policy, bridges, or
firewall rules. Normal shutdown uses ACPI through QMP; force-stop validates the
recorded PID, VM name, and exact disk path first.

Do not commit VM images, ISOs, OVMF variable stores, TPM data, OpenCore
identities, keys, passwords, browser profiles, or raw logs. See
[`SECURITY.md`](SECURITY.md) and the architecture document before extending
the runtime.

## Support

Issues and improvements are welcome when they preserve the private-by-default
design. Detailed Hackintosh recovery material belongs in
[`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh); general
operational lessons also appear in
[`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying).
The verified tools are reproducible references, not bundled operating systems
or vendor support.

## Citation

If you use KVM QEMU Workstation in research, cite the repository. GitHub reads [CITATION.cff](CITATION.cff) and shows a **Cite this repository** panel on the repo page.

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
