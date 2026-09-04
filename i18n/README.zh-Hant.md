[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# KVM QEMU Workstation

*面向 Linux 工作站、可重現且預設保護私隱的 Windows 與 macOS 虛擬機工作流程。*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

本倉庫把長期工作站實驗整理為一套小型、可審核的工具。它包含完整且已去除私密資料的 Windows 11/Tiny11 KVM 路徑、統一的 Windows/macOS 調度命令，以及與獨立審核的 Hackintosh KVM 工作流程之間的清楚邊界。虛擬磁碟、專有安裝媒體、憑證、主機金鑰、TPM 狀態、OpenCore 身份和私人日誌均不會進入 Git。

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 為何建立它

KVM 提供 Linux 核心硬件加速，QEMU 提供虛擬機與裝置模型。真正有價值的不只是冗長的 QEMU 命令，而是完整生命週期：來源驗證、稀疏儲存、只綁定本機回環的控制台、正常關機、精確程序歸屬，以及原始碼與私人可變狀態的分界。

參考 Windows 安裝已在 Ubuntu 24.04、QEMU 8.2.2、OVMF 和 swtpm 上驗證，使用 128 GiB 稀疏磁碟、8 GiB 記憶體和 4 個 vCPU。macOS 路徑交由現有 `hackintosh` 倉庫處理，避免重複私人 OpenCore 與 Apple 服務身份邏輯。
這套結構也讓每次測試的責任清楚：公共倉庫保存方法，私人執行目錄保存機器狀態，驗證紀錄只留下可安全分享的結論。

## 包含內容

`bin/kvm-workstation` 提供統一入口；`windows/tiny11/windows-tiny11-kvm` 管理 KVM/QEMU、TPM、QMP、noVNC、RDP 和 SSH；`windows/tiny11/build/` 保存固定版本的建置準備與補丁；`windows/tiny11/guest/` 保存冪等的來賓初始化和驗證；`docs/` 記錄架構、安裝、macOS 邊界和故障經驗。

流程使用可維護的常規 Tiny11 builder，而非 Tiny11 Core。Windows 仍需要有效的 Microsoft 授權。macOS 路徑是不受官方支援的互操作實驗，並受 Apple 授權條款約束。

## 快速開始

從 Linux 發行版安裝 QEMU/KVM、OVMF、swtpm、noVNC/websockify、tmux 和 `qemu-utils`，再複製本倉庫與可選的 macOS 專用倉庫。

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

首次 `prepare` 前，請將 `WINDOWS_TINY11_RUNTIME_ROOT` 指向容量充足的私人檔案系統。持久覆寫放在 `WINDOWS_TINY11_KVM_CONFIG`。若 Hackintosh 倉庫不在預設位置，設定 `KVM_WORKSTATION_MACOS_LAUNCHER`。提供安裝媒體或標記安裝完成前，先閱讀 Windows 指南。

## 驗證與邊界

修改後執行以下檢查：

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

所有預設顯示和來賓服務轉發都綁定 `127.0.0.1`；遠端存取應使用已驗證的 SSH 隧道。啟動器不會修改主機韌體、開機載入器、分割區、CPU 核心政策、GPU 政策、網橋或防火牆。正常關機透過 QMP 請求 ACPI；強制停止前會核對 PID、虛擬機名稱和精確磁碟路徑。

不要提交虛擬機映像、ISO、OVMF 可寫變數、TPM 資料、OpenCore 身份、金鑰、密碼、瀏覽器設定或原始日誌。擴充執行環境前請閱讀 [`SECURITY.md`](../SECURITY.md) 與架構文件。

## 支援

歡迎在維持預設私隱設計的前提下提出問題與改進。Hackintosh 詳細復原資料位於 [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh)，通用運維經驗亦收錄於 [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying)。這些工具是可重現參考，不包含作業系統，亦不取代廠商支援。

## 引用

若在研究中使用 KVM QEMU Workstation，請引用本倉庫。GitHub 會讀取 [CITATION.cff](../CITATION.cff)，並在倉庫頁面顯示 **Cite this repository** 面板。

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
