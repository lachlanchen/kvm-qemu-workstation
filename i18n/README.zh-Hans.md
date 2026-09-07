[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# KVM QEMU Workstation

*面向 Linux 工作站、可复现且默认保护隐私的 Windows 与 macOS 虚拟机工作流。*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

本仓库把长期工作站实验整理为一套小型、可审计的工具。它包含完整且已脱敏的 Windows 11/Tiny11 KVM 路径、统一的 Windows/macOS 调度命令，以及与单独审核的 Hackintosh KVM 工作流之间的清晰边界。虚拟磁盘、专有安装介质、凭据、主机密钥、TPM 状态、OpenCore 身份和私有日志都不会进入 Git。

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 为什么建立它

KVM 提供 Linux 内核级硬件加速，QEMU 提供虚拟机及设备模型。真正有价值的不只是很长的 QEMU 命令，而是围绕它建立的生命周期：来源校验、稀疏磁盘、仅回环地址控制台、优雅关机、精确的进程归属，以及源码与私有可变状态之间的边界。

参考 Windows 安装已在 Ubuntu 24.04、QEMU 8.2.2、OVMF 和 swtpm 上验证，配置为 128 GiB 稀疏磁盘、8 GiB 内存和 4 个 vCPU。macOS 路径委托给现有 `hackintosh` 仓库，避免复制私有 OpenCore 与 Apple 服务身份逻辑。
这套结构也让每次测试的责任明确：公共仓库保存方法，私有运行目录保存机器状态，验证记录只保留可安全分享的结论。

## 包含内容

`bin/kvm-workstation` 提供统一入口；`windows/tiny11/windows-tiny11-kvm` 管理 KVM/QEMU、TPM、QMP、noVNC、RDP 与 SSH；`windows/tiny11/build/` 保存固定版本的构建准备和补丁；`windows/tiny11/guest/` 保存幂等的来宾初始化与验证；`docs/` 记录架构、安装、macOS 边界和故障经验。

[原生 UU 安装、独立虚拟机端口映射路径及验证边界](../docs/uu-native-relay.md).

流程使用可维护的常规 Tiny11 builder，而不是 Tiny11 Core。Windows 仍需要合法的 Microsoft 许可证。macOS 路径属于不受官方支持的互操作实验，并受 Apple 许可条款约束。

## 快速开始

从 Linux 发行版安装 QEMU/KVM、OVMF、swtpm、noVNC/websockify、tmux 和 `qemu-utils`，然后克隆本仓库以及可选的 macOS 专用仓库。

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

首次 `prepare` 前，把 `WINDOWS_TINY11_RUNTIME_ROOT` 指向容量充足的私有文件系统。持久配置放在 `WINDOWS_TINY11_KVM_CONFIG`。若 Hackintosh 仓库不在默认位置，请设置 `KVM_WORKSTATION_MACOS_LAUNCHER`。提供安装介质或标记安装完成前，请先阅读 Windows 指南。

## 验证与边界

修改后运行以下检查：

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

所有默认显示和来宾服务转发都绑定到 `127.0.0.1`；远程访问应使用已认证的 SSH 隧道。启动器不会修改主机固件、引导器、分区、CPU 核心策略、GPU 策略、网桥或防火墙。普通关机通过 QMP 请求 ACPI；强制停止前会核对 PID、虚拟机名称和精确磁盘路径。

不要提交虚拟机镜像、ISO、OVMF 可写变量、TPM 数据、OpenCore 身份、密钥、密码、浏览器配置或原始日志。扩展运行时前请阅读 [`SECURITY.md`](../SECURITY.md) 与架构文档。

## 支持

欢迎在保持默认隐私设计的前提下提交问题与改进。Hackintosh 的详细恢复资料位于 [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh)，通用运维经验也收录于 [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying)。这些工具是可复现参考，不包含操作系统，也不替代厂商支持。

## 引用

若在研究中使用 KVM QEMU Workstation，请引用本仓库。GitHub 会读取 [CITATION.cff](../CITATION.cff)，并在仓库页面显示 **Cite this repository** 面板。

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
