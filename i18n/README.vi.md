[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner — apps and four buddies](https://lazying.art/media/brand/lazyingart-intro.gif)](https://lazying.art)

# KVM QEMU Workstation

*Quy trình máy ảo Windows và macOS có thể tái lập, mặc định riêng tư cho máy trạm Linux.*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

Kho này biến một thử nghiệm máy trạm kéo dài thành bộ công cụ nhỏ và có thể kiểm tra. Nội dung gồm quy trình Windows 11/Tiny11 KVM đã làm sạch hoàn chỉnh, bộ điều phối chung cho Windows và macOS, cùng ranh giới tích hợp với quy trình Hackintosh KVM được kiểm toán riêng. Đĩa VM, bộ cài độc quyền, thông tin đăng nhập, khóa máy chủ, trạng thái TPM, danh tính OpenCore và nhật ký riêng không được đưa vào Git.

<!-- support:start -->
[![GitHub Sponsors](https://img.shields.io/badge/GitHub-Sponsors-EA4AAA?style=for-the-badge&logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)
[![LazyingArt Support](https://img.shields.io/badge/LazyingArt-Support-0EA5E9?style=for-the-badge)](https://chat.lazying.art/donate)
[![PayPal Support](https://img.shields.io/badge/PayPal-Support-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen)
[![Stripe Support](https://img.shields.io/badge/Stripe-Support-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400)
<!-- support:end -->

## Vì sao dự án tồn tại

KVM cung cấp tăng tốc phần cứng trong nhân Linux; QEMU cung cấp máy ảo và mô hình thiết bị. Giá trị không chỉ là một lệnh QEMU dài mà là toàn bộ vòng đời: kiểm tra nguồn gốc, lưu trữ thưa, bảng điều khiển chỉ trên loopback, tắt máy đúng cách, nhận diện chính xác tiến trình sở hữu và tách mã nguồn khỏi trạng thái riêng có thể thay đổi.

Cấu hình Windows tham chiếu đã được xác minh trên Ubuntu 24.04 với QEMU 8.2.2, OVMF, swtpm, đĩa thưa 128 GiB, RAM 8 GiB và 4 vCPU. Phần macOS được giao cho kho `hackintosh`, tránh sao chép logic danh tính OpenCore và dịch vụ Apple riêng tư.

## Nội dung

`bin/kvm-workstation` là điểm vào chung. `windows/tiny11/windows-tiny11-kvm` quản lý KVM/QEMU, TPM, QMP, noVNC, RDP và SSH. `windows/tiny11/build/` chứa bước chuẩn bị theo commit cố định và bản vá nhỏ; `windows/tiny11/guest/` chứa khởi tạo và xác minh lặp lại an toàn; `docs/` ghi kiến trúc, cài đặt, ranh giới macOS và bài học xử lý lỗi.

[Cài UU bản Windows gốc, chuyển tiếp cổng qua máy ảo riêng và phạm vi xác minh](../docs/uu-native-relay.md).

Quy trình dùng Tiny11 builder thông thường có thể bảo trì, không dùng Tiny11 Core. Windows vẫn cần giấy phép Microsoft hợp lệ. Phần macOS là thử nghiệm tương tác không được hỗ trợ chính thức và chịu điều khoản giấy phép Apple.

## Bắt đầu nhanh

Cài QEMU/KVM, OVMF, swtpm, noVNC/websockify, tmux và `qemu-utils` từ bản phân phối Linux; sau đó sao chép kho này và kho chuyên macOS nếu cần.

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

Trước lần `prepare` đầu, đặt `WINDOWS_TINY11_RUNTIME_ROOT` tới hệ thống tệp riêng đủ lớn. Dùng `WINDOWS_TINY11_KVM_CONFIG` cho ghi đè bền vững. Nếu Hackintosh không ở đường dẫn mặc định, đặt `KVM_WORKSTATION_MACOS_LAUNCHER`. Hãy đọc hướng dẫn Windows trước khi cung cấp bộ cài hoặc đánh dấu đã cài xong.

## Xác minh và ranh giới

Chạy các kiểm tra này sau khi thay đổi:

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

Mọi chuyển tiếp hiển thị và dịch vụ khách mặc định chỉ gắn với `127.0.0.1`. Dùng đường hầm SSH đã xác thực khi truy cập từ xa. Trình khởi chạy không sửa firmware, bộ nạp khởi động, phân vùng, chính sách CPU/GPU, bridge hay tường lửa máy chủ. Tắt thường gửi yêu cầu ACPI qua QMP; dừng cưỡng bức kiểm tra PID, tên VM và đường dẫn đĩa chính xác trước.

Không commit ảnh VM, ISO, biến OVMF ghi được, dữ liệu TPM, danh tính OpenCore, khóa, mật khẩu, hồ sơ trình duyệt hoặc nhật ký thô. Đọc [`SECURITY.md`](../SECURITY.md) và tài liệu kiến trúc trước khi mở rộng.

## Hỗ trợ

Hoan nghênh lỗi và cải tiến vẫn giữ thiết kế riêng tư mặc định. Tài liệu phục hồi Hackintosh chi tiết nằm tại [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh), kinh nghiệm vận hành chung tại [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying). Đây là công cụ tham chiếu có thể tái lập, không phải hệ điều hành hay hỗ trợ của nhà cung cấp.

## Trích dẫn

Nếu dùng KVM QEMU Workstation trong nghiên cứu, hãy trích dẫn kho này. GitHub đọc [CITATION.cff](../CITATION.cff) và hiển thị bảng **Cite this repository** trên trang kho.

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
