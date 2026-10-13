[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://lazying.art)

# KVM QEMU Workstation

*Воспроизводимые и приватные по умолчанию процессы для виртуальных машин Windows и macOS на Linux-станциях.*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

Репозиторий превращает длительный эксперимент с рабочей станцией в компактный и проверяемый набор инструментов. Здесь есть полностью очищенный путь Windows 11/Tiny11 на KVM, общий диспетчер Windows и macOS и граница интеграции с отдельно проверенным процессом Hackintosh KVM. Диски ВМ, закрытые установщики, учётные данные, ключи узла, состояние TPM, идентичность OpenCore и приватные журналы не попадают в Git.

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## Зачем это нужно

KVM даёт аппаратное ускорение в ядре Linux, а QEMU — виртуальную машину и модели устройств. Ценность не только в длинной команде запуска, а во всём жизненном цикле: проверке происхождения, разреженном хранилище, консоли только на loopback, штатном завершении, точном владении процессом и разделении исходников с приватным изменяемым состоянием.

Эталон Windows проверен на Ubuntu 24.04 с QEMU 8.2.2, OVMF, swtpm, разреженным диском 128 ГиБ, 8 ГиБ ОЗУ и 4 vCPU. Путь macOS передаётся репозиторию `hackintosh`, чтобы не дублировать приватную логику OpenCore и идентичности сервисов Apple.

## Содержимое

`bin/kvm-workstation` — общая точка входа. `windows/tiny11/windows-tiny11-kvm` управляет KVM/QEMU, TPM, QMP, noVNC, RDP и SSH. В `windows/tiny11/build/` находятся подготовка с закреплённым коммитом и небольшой патч, в `windows/tiny11/guest/` — идемпотентная настройка и проверка, а в `docs/` — архитектура, установка, границы macOS и уроки диагностики.

[Установка нативного UU, перенаправление портов через отдельную ВМ и границы проверки](../docs/uu-native-relay.md).

Используется обычный обслуживаемый Tiny11 builder, а не Tiny11 Core. Windows по-прежнему требует действительной лицензии Microsoft. Путь macOS — неподдерживаемый эксперимент совместимости, подчинённый условиям лицензии Apple.

## Быстрый старт

Установите QEMU/KVM, OVMF, swtpm, noVNC/websockify, tmux и `qemu-utils` из своего дистрибутива Linux, затем клонируйте этот и при необходимости специализированный macOS-репозиторий.

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

До первого `prepare` укажите в `WINDOWS_TINY11_RUNTIME_ROOT` большой приватный раздел. Постоянные переопределения храните в `WINDOWS_TINY11_KVM_CONFIG`. Если Hackintosh расположен иначе, задайте `KVM_WORKSTATION_MACOS_LAUNCHER`. Прочитайте Windows-руководство до добавления носителей и отметки завершённой установки.

## Проверка и границы

После изменений выполните:

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

Все перенаправления экрана и гостевых сервисов по умолчанию привязаны к `127.0.0.1`. Для удалённого доступа используйте аутентифицированный SSH-туннель. Запускатели не меняют прошивку, загрузчик, разделы, политику CPU/GPU, мосты или межсетевой экран узла. Обычное выключение запрашивает ACPI через QMP; принудительное сначала проверяет PID, имя ВМ и точный путь диска.

Не публикуйте образы ВМ, ISO, изменяемые OVMF-переменные, TPM, OpenCore-идентичности, ключи, пароли, профили браузера и сырые журналы. Перед расширением прочитайте [`SECURITY.md`](../SECURITY.md) и описание архитектуры.

## Поддержка

Приветствуются предложения, сохраняющие приватность по умолчанию. Подробное восстановление Hackintosh находится в [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh), общие эксплуатационные заметки — в [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying). Это воспроизводимые справочные инструменты, а не дистрибутивы ОС или поддержка производителя.

## Цитирование

При использовании KVM QEMU Workstation в исследовании укажите этот репозиторий. GitHub читает [CITATION.cff](../CITATION.cff) и показывает панель **Cite this repository**.

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
