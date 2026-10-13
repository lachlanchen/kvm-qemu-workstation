[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner — apps and four buddies](https://github.com/lachlanchen/LazyingArtWebsite/raw/main/media/brand/lazyingart-intro.gif)](https://lazying.art)

# KVM QEMU Workstation

*Linux ワークステーション向けの、再現可能でプライバシーを既定とする Windows/macOS 仮想マシン運用。*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

このリポジトリは、長期間のワークステーション実験を小さく監査可能なツール群に整理したものです。匿名化済みの Windows 11/Tiny11 KVM 手順、Windows と macOS を扱う共通ディスパッチャー、そして別途監査された Hackintosh KVM との統合境界を収録します。VM ディスク、専有インストーラー、認証情報、ホスト鍵、TPM 状態、OpenCore ID、非公開ログは Git に含めません。

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## このリポジトリの目的

KVM は Linux カーネルのハードウェア支援を、QEMU は仮想マシンとデバイスモデルを提供します。重要なのは長い起動コマンドだけではなく、出所検証、スパースストレージ、ループバック限定コンソール、正常終了、厳密なプロセス所有確認、ソースと非公開の可変状態を分離する運用全体です。

Windows の参照構成は Ubuntu 24.04、QEMU 8.2.2、OVMF、swtpm、128 GiB のスパースディスク、8 GiB RAM、4 vCPU で検証済みです。macOS は既存の `hackintosh` リポジトリへ委譲し、OpenCore と Apple サービス用の非公開 ID ロジックを重複させません。

## 収録内容

`bin/kvm-workstation` は共通入口です。`windows/tiny11/windows-tiny11-kvm` は KVM/QEMU、TPM、QMP、noVNC、RDP、SSH を管理します。`windows/tiny11/build/` には固定コミットからの構築準備と小さなパッチ、`windows/tiny11/guest/` には冪等な初期化と検証、`docs/` には設計、導入、macOS 境界、障害から得た知見があります。

[Windows ネイティブ UU の導入、独立した VM のポート転送経路、検証範囲](../docs/uu-native-relay.md).

Tiny11 Core ではなく、更新可能な通常版 Tiny11 builder を使います。Windows には正規の Microsoft ライセンスが必要です。macOS 側は公式サポート外の相互運用実験であり、Apple のライセンス条件に従います。

## クイックスタート

Linux のパッケージから QEMU/KVM、OVMF、swtpm、noVNC/websockify、tmux、`qemu-utils` を導入し、このリポジトリと任意の macOS 専用リポジトリをクローンします。

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

最初の `prepare` 前に `WINDOWS_TINY11_RUNTIME_ROOT` を容量のある非公開ファイルシステムへ設定してください。永続的な上書きは `WINDOWS_TINY11_KVM_CONFIG` に置きます。Hackintosh が既定位置にない場合は `KVM_WORKSTATION_MACOS_LAUNCHER` を設定し、メディアの配置やインストール済みマークの前に Windows ガイドを確認してください。

## 検証と境界

変更後は次を実行します。

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

表示とゲストサービスの転送は既定で `127.0.0.1` のみにバインドされます。遠隔利用には認証済み SSH トンネルを使ってください。ランチャーはホストのファームウェア、ブートローダー、パーティション、CPU/GPU 方針、ブリッジ、ファイアウォールを変更しません。通常停止は QMP 経由の ACPI、強制停止は PID・VM 名・正確なディスクパスを確認してから行います。

VM イメージ、ISO、書き込み可能な OVMF 変数、TPM データ、OpenCore ID、鍵、パスワード、ブラウザープロファイル、未加工ログをコミットしないでください。拡張前に [`SECURITY.md`](../SECURITY.md) と設計文書を読んでください。

## サポート

プライバシーを既定とする設計を維持する改善を歓迎します。Hackintosh の詳細な復旧資料は [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh)、一般的な運用知識は [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying) にあります。本ツールは再現可能な参照であり、OS 配布物やベンダーサポートではありません。

## 引用

研究で KVM QEMU Workstation を利用する場合は、本リポジトリを引用してください。GitHub は [CITATION.cff](../CITATION.cff) を読み、リポジトリページに **Cite this repository** パネルを表示します。

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
