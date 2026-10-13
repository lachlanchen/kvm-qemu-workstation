[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner — apps and four buddies](https://github.com/lachlanchen/LazyingArtWebsite/raw/main/media/brand/lazyingart-intro.gif)](https://lazying.art)

# KVM QEMU Workstation

*Des flux de machines virtuelles Windows et macOS reproductibles et privés par défaut pour les stations Linux.*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

Ce dépôt transforme une longue expérimentation de poste de travail en une boîte à outils compacte et vérifiable. Il comprend une voie Windows 11/Tiny11 sur KVM complète et assainie, un répartiteur commun pour Windows et macOS et une frontière d'intégration avec le flux Hackintosh KVM audité séparément. Disques VM, installateurs propriétaires, identifiants, clés d'hôte, état TPM, identité OpenCore et journaux privés restent hors de Git.

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## Pourquoi ce dépôt

KVM apporte l'accélération du noyau Linux et QEMU fournit la machine virtuelle et ses périphériques. L'essentiel n'est pas une longue commande QEMU, mais son cycle de vie : contrôle de provenance, stockage dynamique, consoles limitées à la boucle locale, arrêt propre, propriété exacte des processus et séparation du code avec l'état privé modifiable.

La référence Windows a été validée sous Ubuntu 24.04 avec QEMU 8.2.2, OVMF, swtpm, un disque dynamique de 128 Gio, 8 Gio de RAM et 4 vCPU. macOS est délégué au dépôt `hackintosh` afin de ne pas dupliquer l'identité OpenCore privée ni la logique des services Apple.

## Contenu

`bin/kvm-workstation` constitue l'entrée commune. `windows/tiny11/windows-tiny11-kvm` gère KVM/QEMU, TPM, QMP, noVNC, RDP et SSH. `windows/tiny11/build/` contient la préparation épinglée et un petit correctif ; `windows/tiny11/guest/` propose une initialisation et une vérification idempotentes ; `docs/` décrit l'architecture, l'installation, la frontière macOS et les enseignements du dépannage.

[Installation native de UU, transfert de ports via une VM distincte et limites de validation](../docs/uu-native-relay.md).

Le constructeur Tiny11 normal et maintenable est utilisé, pas Tiny11 Core. Windows exige toujours une licence Microsoft valide. La voie macOS est une expérience d'interopérabilité non prise en charge et reste soumise aux conditions de licence Apple.

## Démarrage rapide

Installez QEMU/KVM, OVMF, swtpm, noVNC/websockify, tmux et `qemu-utils` depuis votre distribution Linux, puis clonez ce dépôt et, si nécessaire, le dépôt spécialisé macOS.

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

Avant le premier `prepare`, dirigez `WINDOWS_TINY11_RUNTIME_ROOT` vers un système de fichiers privé suffisamment grand. Placez les réglages persistants dans `WINDOWS_TINY11_KVM_CONFIG`. Si Hackintosh n'est pas au chemin prévu, définissez `KVM_WORKSTATION_MACOS_LAUNCHER`. Consultez le guide Windows avant d'ajouter les supports ou de marquer l'installation comme terminée.

## Validation et frontières

Après une modification, lancez :

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

Tous les affichages et services invités sont liés par défaut à `127.0.0.1`. Utilisez un tunnel SSH authentifié à distance. Les lanceurs ne modifient ni micrologiciel, ni chargeur, ni partition, ni politique CPU/GPU, ni pont, ni pare-feu de l'hôte. L'arrêt normal demande ACPI par QMP ; l'arrêt forcé vérifie d'abord PID, nom de VM et chemin exact du disque.

Ne publiez jamais images VM, ISO, variables OVMF modifiables, données TPM, identités OpenCore, clés, mots de passe, profils de navigateur ou journaux bruts. Lisez [`SECURITY.md`](../SECURITY.md) et l'architecture avant toute extension.

## Assistance

Les problèmes et améliorations respectant la confidentialité par défaut sont bienvenus. La récupération Hackintosh détaillée se trouve dans [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh), les leçons générales dans [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying). Ces outils sont des références reproductibles, pas des systèmes d'exploitation ni une assistance fournisseur.

## Citation

Si vous utilisez KVM QEMU Workstation en recherche, citez ce dépôt. GitHub lit [CITATION.cff](../CITATION.cff) et affiche un panneau **Cite this repository** sur la page du dépôt.

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
