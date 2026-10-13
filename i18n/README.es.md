[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner — apps and four buddies](https://github.com/lachlanchen/LazyingArtWebsite/raw/main/media/brand/lazyingart-intro.gif)](https://lazying.art)

# KVM QEMU Workstation

*Flujos reproducibles y privados por defecto para máquinas virtuales Windows y macOS en estaciones Linux.*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

Este repositorio convierte un largo experimento de estación de trabajo en un conjunto pequeño y auditable. Incluye una ruta saneada y completa para Windows 11/Tiny11 sobre KVM, un despachador común para Windows y macOS y un límite de integración con el flujo Hackintosh KVM auditado por separado. Los discos, instaladores propietarios, credenciales, claves, estado TPM, identidad OpenCore y registros privados permanecen fuera de Git.

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## Por qué existe

KVM aporta aceleración desde el núcleo Linux y QEMU aporta la máquina y sus dispositivos. Lo valioso no es solo un comando extenso: es el ciclo completo con verificación de procedencia, almacenamiento disperso, consolas limitadas al bucle local, apagado ordenado, propiedad exacta de procesos y separación entre código fuente y estado privado mutable.

La instalación Windows de referencia se verificó en Ubuntu 24.04 con QEMU 8.2.2, OVMF, swtpm, un disco disperso de 128 GiB, 8 GiB de RAM y 4 vCPU. La ruta macOS delega en `hackintosh` para no duplicar la identidad privada de OpenCore ni la lógica de servicios Apple.

## Qué incluye

`bin/kvm-workstation` es la entrada común. `windows/tiny11/windows-tiny11-kvm` gestiona KVM/QEMU, TPM, QMP, noVNC, RDP y SSH. `windows/tiny11/build/` contiene preparación fijada a un commit y un parche pequeño; `windows/tiny11/guest/` ofrece inicialización y verificación idempotentes; `docs/` explica arquitectura, instalación, límites de macOS y lecciones de diagnóstico.

[Instalación nativa de UU, rutas de puertos mediante una VM separada y límites de verificación](../docs/uu-native-relay.md).

Se usa el constructor Tiny11 normal y mantenible, no Tiny11 Core. Windows aún necesita una licencia válida de Microsoft. La ruta macOS es un experimento de interoperabilidad sin soporte oficial y está sujeta a la licencia de Apple.

## Inicio rápido

Instala desde tu distribución QEMU/KVM, OVMF, swtpm, noVNC/websockify, tmux y `qemu-utils`; después clona este repositorio y, opcionalmente, el repositorio especializado en macOS.

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

Antes del primer `prepare`, apunta `WINDOWS_TINY11_RUNTIME_ROOT` a un sistema de archivos privado con espacio. Guarda ajustes duraderos en `WINDOWS_TINY11_KVM_CONFIG`. Si Hackintosh no está en la ruta prevista, define `KVM_WORKSTATION_MACOS_LAUNCHER`. Lee la guía Windows antes de aportar medios o marcar la instalación como completa.

## Validación y límites

Ejecuta estas comprobaciones tras cada cambio:

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

Todos los reenvíos de pantalla y servicios se enlazan por defecto a `127.0.0.1`; usa un túnel SSH autenticado para acceso remoto. Los lanzadores no cambian firmware, gestor de arranque, particiones, políticas CPU/GPU, puentes ni cortafuegos del host. El apagado normal solicita ACPI por QMP; el forzado verifica primero PID, nombre de VM y ruta exacta del disco.

No confirmes imágenes VM, ISO, variables OVMF escribibles, datos TPM, identidades OpenCore, claves, contraseñas, perfiles de navegador ni registros sin filtrar. Lee [`SECURITY.md`](../SECURITY.md) y la arquitectura antes de ampliar el entorno.

## Soporte

Se agradecen incidencias y mejoras que conserven el diseño privado por defecto. La recuperación Hackintosh detallada vive en [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh), y las lecciones operativas generales en [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying). Estas herramientas son referencias reproducibles, no sistemas operativos ni soporte del proveedor.

## Cita

Si utilizas KVM QEMU Workstation en investigación, cita el repositorio. GitHub lee [CITATION.cff](../CITATION.cff) y muestra un panel **Cite this repository** en la página.

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
