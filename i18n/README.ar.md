[English](../README.md) · [العربية](README.ar.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [한국어](README.ko.md) · [Tiếng Việt](README.vi.md) · [中文 (简体)](README.zh-Hans.md) · [中文（繁體）](README.zh-Hant.md) · [Deutsch](README.de.md) · [Русский](README.ru.md)

[![LazyingArt banner — apps and four buddies](https://github.com/lachlanchen/LazyingArtWebsite/raw/main/media/brand/lazyingart-intro.gif)](https://lazying.art)

# KVM QEMU Workstation

*مسارات قابلة لإعادة الإنتاج وخاصة افتراضياً لآلات Windows وmacOS الافتراضية على محطات Linux.*

[![Linux](https://img.shields.io/badge/Host-Linux-FCC624?logo=linux&logoColor=black)](https://www.linux.org/)
[![KVM](https://img.shields.io/badge/Acceleration-KVM-7C3AED)](https://www.linux-kvm.org/)
[![QEMU](https://img.shields.io/badge/Runtime-QEMU-FF6600?logo=qemu&logoColor=white)](https://www.qemu.org/)
[![Website](https://img.shields.io/badge/Website-lazying.art-0EA5E9)](https://lazying.art)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/lachlanchen)

يحوّل هذا المستودع تجربة طويلة على محطة عمل إلى مجموعة أدوات صغيرة قابلة للتدقيق. يتضمن مساراً كاملاً ومنقحاً لتشغيل Windows 11/Tiny11 عبر KVM، وموجهاً مشتركاً لنظامي Windows وmacOS، وحداً واضحاً للتكامل مع مسار Hackintosh KVM المدقق منفصلاً. تبقى أقراص الآلات ووسائط التثبيت المملوكة وبيانات الاعتماد ومفاتيح المضيف وحالة TPM وهوية OpenCore والسجلات الخاصة خارج Git.

| Donate | PayPal | Stripe |
| --- | --- | --- |
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=kofi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## لماذا أُنشئ المشروع

يوفر KVM تسريع العتاد داخل نواة Linux، بينما يوفر QEMU الآلة الافتراضية ونماذج الأجهزة. القيمة ليست في أمر QEMU طويل فقط، بل في دورة الحياة كاملة: التحقق من المصدر، التخزين المتناثر، وحدات التحكم المرتبطة بالحلقة المحلية فقط، الإغلاق المنظم، التحقق الدقيق من ملكية العملية، والفصل بين المصدر والحالة الخاصة القابلة للتغيير.

تم التحقق من مرجع Windows على Ubuntu 24.04 مع QEMU 8.2.2 وOVMF وswtpm وقرص متناثر 128 GiB وذاكرة 8 GiB وأربع وحدات vCPU. يُفوض مسار macOS إلى مستودع `hackintosh` لتجنب تكرار منطق هوية OpenCore وخدمات Apple الخاصة.

## المحتويات

`bin/kvm-workstation` هو المدخل المشترك. يدير `windows/tiny11/windows-tiny11-kvm` تقنيات KVM/QEMU وTPM وQMP وnoVNC وRDP وSSH. يحتوي `windows/tiny11/build/` على إعداد مثبت إلى commit محدد ورقعة صغيرة، ويحتوي `windows/tiny11/guest/` على تهيئة وتحقق قابلين للتكرار، بينما تشرح `docs/` البنية والتثبيت وحدود macOS ودروس الأعطال.

[تثبيت UU الأصلي ومسارات تحويل المنافذ عبر آلة افتراضية منفصلة وحدود التحقق](../docs/uu-native-relay.md).

يُستخدم Tiny11 builder العادي القابل للصيانة وليس Tiny11 Core. ما زال Windows يحتاج ترخيص Microsoft صالحاً. أما مسار macOS فهو تجربة توافق غير مدعومة رسمياً وتخضع لشروط ترخيص Apple.

## بدء سريع

ثبّت QEMU/KVM وOVMF وswtpm وnoVNC/websockify وtmux و`qemu-utils` من توزيعة Linux، ثم انسخ هذا المستودع ومستودع macOS المتخصص اختيارياً.

```text
git clone https://github.com/lachlanchen/kvm-qemu-workstation.git
git clone https://github.com/lachlanchen/hackintosh.git
ln -s "$PWD/kvm-qemu-workstation/bin/kvm-workstation" "$HOME/.local/bin/kvm-workstation"
kvm-workstation windows prepare
kvm-workstation windows status
kvm-workstation macos status
```

قبل أول `prepare` اجعل `WINDOWS_TINY11_RUNTIME_ROOT` يشير إلى نظام ملفات خاص واسع. استخدم `WINDOWS_TINY11_KVM_CONFIG` للتجاوزات الدائمة. إذا لم يكن Hackintosh في المسار الافتراضي فاضبط `KVM_WORKSTATION_MACOS_LAUNCHER`. اقرأ دليل Windows قبل إضافة الوسائط أو وسم التثبيت بالمكتمل.

## التحقق والحدود

نفّذ الفحوص التالية بعد التغيير:

```text
bash -n bin/kvm-workstation windows/tiny11/windows-tiny11-kvm
git diff --check
python3 /path/to/publish-repo/scripts/check_profile_readmes.py .
```

ترتبط جميع تحويلات العرض وخدمات الضيف افتراضياً بـ`127.0.0.1` فقط. استخدم نفق SSH موثقاً للوصول البعيد. لا تغير المشغلات البرنامج الثابت أو محمل الإقلاع أو الأقسام أو سياسة CPU/GPU أو الجسور أو جدار الحماية. يطلب الإغلاق العادي ACPI عبر QMP؛ ويتحقق الإيقاف القسري أولاً من PID واسم الآلة والمسار الدقيق للقرص.

لا ترفع صور VM أو ISO أو متغيرات OVMF القابلة للكتابة أو بيانات TPM أو هويات OpenCore أو المفاتيح أو كلمات المرور أو ملفات المتصفح أو السجلات الخام. اقرأ [`SECURITY.md`](../SECURITY.md) ووثيقة البنية قبل التوسعة.

## الدعم

نرحب بالمشكلات والتحسينات التي تحافظ على الخصوصية الافتراضية. توجد تفاصيل استعادة Hackintosh في [`lachlanchen/hackintosh`](https://github.com/lachlanchen/hackintosh)، والدروس التشغيلية العامة في [`the-art-of-lazying`](https://github.com/lachlanchen/the-art-of-lazying). هذه أدوات مرجعية قابلة للتكرار وليست أنظمة تشغيل أو دعماً من المورد.

## الاستشهاد

إذا استخدمت KVM QEMU Workstation في البحث، فاستشهد بهذا المستودع. يقرأ GitHub ملف [CITATION.cff](../CITATION.cff) ويعرض لوحة **Cite this repository** في صفحة المستودع.

```bibtex
@software{chen_kvm_qemu_workstation_2026,
  author = {Chen, Lachlan},
  title = {KVM QEMU Workstation: Reproducible Windows and macOS VM orchestration},
  year = {2026},
  url = {https://github.com/lachlanchen/kvm-qemu-workstation}
}
```
