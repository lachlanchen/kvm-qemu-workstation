[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://lazying.art)

# KVM QEMU Workstation

*Linux 워크스테이션을 위한 재현 가능하고 개인정보 보호가 기본인 Windows/macOS 가상 머신 워크플로.*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

이 저장소는 오랜 워크스테이션 실험을 작고 감사 가능한 도구 모음으로 정리합니다. 정리된 Windows 11/Tiny11 KVM 경로, Windows와 macOS용 공통 디스패처, 별도로 검토된 Hackintosh KVM 흐름과의 통합 경계를 제공합니다. VM 디스크, 독점 설치 미디어, 자격 증명, 호스트 키, TPM 상태, OpenCore 신원 및 비공개 로그는 Git에 넣지 않습니다.

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## 만든 이유

KVM은 Linux 커널 하드웨어 가속을, QEMU는 가상 머신과 장치 모델을 제공합니다. 중요한 것은 긴 QEMU 명령 하나가 아니라 출처 검증, 희소 저장소, 루프백 전용 콘솔, 정상 종료, 정확한 프로세스 소유권, 소스와 비공개 가변 상태의 분리를 포함한 전체 수명주기입니다.

Windows 참조 설치는 Ubuntu 24.04, QEMU 8.2.2, OVMF, swtpm, 128 GiB 희소 디스크, 8 GiB RAM, 4 vCPU에서 검증했습니다. macOS 경로는 기존 `hackintosh` 저장소에 위임하여 비공개 OpenCore 및 Apple 서비스 신원 로직을 복제하지 않습니다.

## 포함 내용

`bin/kvm-workstation`은 공통 진입점입니다. `windows/tiny11/windows-tiny11-kvm`은 KVM/QEMU, TPM, QMP, noVNC, RDP, SSH를 관리합니다. `windows/tiny11/build/`에는 고정 커밋 기반 준비와 작은 패치가, `windows/tiny11/guest/`에는 멱등 초기화 및 검증이, `docs/`에는 구조·설치·macOS 경계·문제 해결 경험이 있습니다.

[Windows 네이티브 UU 설치, 별도 VM 포트 전달 경로 및 검증 범위](../docs/uu-native-relay.md).

Tiny11 Core가 아닌 서비스 가능한 일반 Tiny11 builder를 사용합니다. Windows에는 유효한 Microsoft 라이선스가 필요합니다. macOS 경로는 공식 지원이 없는 상호 운용 실험이며 Apple 라이선스 조건을 따릅니다.

## 빠른 시작

Linux 배포판에서 QEMU/KVM, OVMF, swtpm, noVNC/websockify, tmux, `qemu-utils`를 설치하고 이 저장소와 선택적인 macOS 전문 저장소를 복제합니다.

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

첫 `prepare` 전에 `WINDOWS_TINY11_RUNTIME_ROOT`를 여유 있는 비공개 파일시스템으로 지정하십시오. 영구 재정의에는 `WINDOWS_TINY11_KVM_CONFIG`를 사용합니다. Hackintosh 저장소가 기본 위치에 없으면 `KVM_WORKSTATION_MACOS_LAUNCHER`를 지정하고, 설치 미디어 제공이나 설치 완료 표시 전에 Windows 안내서를 읽으십시오.

## 검증과 경계

변경 뒤 다음을 실행합니다.

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

기본 화면과 게스트 서비스 전달은 모두 `127.0.0.1`에만 바인딩됩니다. 원격 접근에는 인증된 SSH 터널을 사용하십시오. 런처는 호스트 펌웨어, 부트로더, 파티션, CPU/GPU 정책, 브리지 또는 방화벽을 변경하지 않습니다. 정상 종료는 QMP를 통한 ACPI 요청이며, 강제 종료 전에는 PID, VM 이름, 정확한 디스크 경로를 검증합니다.

VM 이미지, ISO, 쓰기 가능한 OVMF 변수, TPM 데이터, OpenCore 신원, 키, 비밀번호, 브라우저 프로필 또는 원시 로그를 커밋하지 마십시오. 런타임 확장 전 [`SECURITY.md`](../SECURITY.md)와 구조 문서를 읽으십시오.

## 지원

개인정보 보호 기본 설계를 유지하는 문제 보고와 개선을 환영합니다. Hackintosh 상세 복구 자료는 [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh)에, 일반 운영 지식은 [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying)에 있습니다. 이 도구는 재현 가능한 참고 자료이며 운영체제 배포본이나 공급업체 지원이 아닙니다.

## 인용

연구에서 KVM QEMU Workstation을 사용한다면 이 저장소를 인용해 주세요. GitHub는 [CITATION.cff](../CITATION.cff)를 읽어 저장소 페이지에 **Cite this repository** 패널을 표시합니다.

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
