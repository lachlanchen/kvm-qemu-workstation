[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://lazying.art)

# KVM QEMU Workstation

*Reproduzierbare, standardmäßig private Windows- und macOS-VM-Abläufe für Linux-Workstations.*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

Dieses Repository macht aus einem langen Workstation-Experiment ein kleines, prüfbares Toolkit. Es enthält einen vollständigen bereinigten Windows-11/Tiny11-KVM-Pfad, einen gemeinsamen Dispatcher für Windows und macOS sowie eine klare Integrationsgrenze zum separat geprüften Hackintosh-KVM-Ablauf. VM-Datenträger, proprietäre Installer, Zugangsdaten, Host-Schlüssel, TPM-Zustand, OpenCore-Identität und private Protokolle bleiben außerhalb von Git.

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## Warum dieses Projekt existiert

KVM liefert Linux-Kernel-Beschleunigung, QEMU die virtuelle Maschine und ihre Geräte. Entscheidend ist nicht nur ein langer QEMU-Befehl, sondern der gesamte Lebenszyklus: Herkunftsprüfung, Sparse-Speicher, nur lokal erreichbare Konsolen, geordnetes Herunterfahren, exakte Prozesseigentümerschaft und die Trennung von Quellcode und privatem veränderlichem Zustand.

Die Windows-Referenz wurde unter Ubuntu 24.04 mit QEMU 8.2.2, OVMF, swtpm, einer 128-GiB-Sparse-Disk, 8 GiB RAM und 4 vCPUs geprüft. Der macOS-Pfad delegiert an `hackintosh`, damit private OpenCore- und Apple-Dienst-Identitätslogik nicht dupliziert wird.

## Inhalt

`bin/kvm-workstation` ist der gemeinsame Einstieg. `windows/tiny11/windows-tiny11-kvm` verwaltet KVM/QEMU, TPM, QMP, noVNC, RDP und SSH. `windows/tiny11/build/` enthält die gepinnte Vorbereitung und einen kleinen Patch, `windows/tiny11/guest/` idempotente Einrichtung und Prüfung, `docs/` Architektur, Installation, macOS-Grenzen und Fehlersuche.

[Native UU-Installation, Portweiterleitung über eine separate VM und Prüfgrenzen](../docs/uu-native-relay.md).

Verwendet wird der normale wartbare Tiny11-Builder, nicht Tiny11 Core. Windows benötigt weiterhin eine gültige Microsoft-Lizenz. Der macOS-Pfad ist ein nicht unterstütztes Interoperabilitätsexperiment und unterliegt Apples Lizenzbedingungen.

## Schnellstart

Installiere QEMU/KVM, OVMF, swtpm, noVNC/websockify, tmux und `qemu-utils` aus der Linux-Distribution. Klone danach dieses und optional das macOS-Spezialrepository.

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

Setze `WINDOWS_TINY11_RUNTIME_ROOT` vor dem ersten `prepare` auf ein großes privates Dateisystem. Dauerhafte Werte gehören in `WINDOWS_TINY11_KVM_CONFIG`. Liegt Hackintosh nicht am Standardpfad, setze `KVM_WORKSTATION_MACOS_LAUNCHER`. Lies vor Installationsmedien oder Installiert-Markierung die Windows-Anleitung.

## Prüfung und Grenzen

Nach Änderungen gelten diese Prüfungen:

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

Alle Anzeige- und Gastdienst-Weiterleitungen binden standardmäßig nur an `127.0.0.1`. Für Fernzugriff dient ein authentifizierter SSH-Tunnel. Die Starter ändern keine Firmware, Bootloader, Partitionen, CPU/GPU-Richtlinien, Bridges oder Firewalls des Hosts. Reguläres Herunterfahren fordert ACPI über QMP an; erzwungenes Stoppen prüft vorher PID, VM-Namen und exakten Diskpfad.

Keine VM-Abbilder, ISOs, beschreibbaren OVMF-Variablen, TPM-Daten, OpenCore-Identitäten, Schlüssel, Passwörter, Browserprofile oder Rohprotokolle committen. Vor Erweiterungen [`SECURITY.md`](../SECURITY.md) und Architektur lesen.

## Unterstützung

Probleme und Verbesserungen sind willkommen, wenn das standardmäßig private Design erhalten bleibt. Ausführliche Hackintosh-Wiederherstellung steht in [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh), allgemeine Betriebserfahrungen in [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying). Die Werkzeuge sind reproduzierbare Referenzen, keine Betriebssysteme und kein Herstellersupport.

## Zitieren

Wenn KVM QEMU Workstation in Forschung verwendet wird, bitte dieses Repository zitieren. GitHub liest [CITATION.cff](../CITATION.cff) und zeigt **Cite this repository** auf der Projektseite.

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
