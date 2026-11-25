---
name: hyperos-package-audit
description: Perform evidence-based Xiaomi HyperOS package classification into reports/package-review.csv while enforcing the HyperOS bootloop blacklist, AI dependency mapping, and verified rollback paths.
---

# HyperOS Package Audit

## Hard Bootloop & Critical System Blacklist
Classify ALL of the following as `PROTECTED` immediately—never propose disabling, restricting, or uninstalling:
- Xiaomi bootloop-critical: `com.miui.securitycenter`, `com.xiaomi.finddevice`, `com.miui.guardprovider`, `com.xiaomi.account`, `com.miui.home`, `com.miui.powerkeeper`, `com.xiaomi.xmsf`, `com.miui.rom`
- Core Android/HyperOS: `com.android.systemui`, `com.android.updater`, `com.android.permissioncontroller`, `com.android.packageinstaller`, `com.google.android.packageinstaller`, camera HAL/system camera services, telephony/IMS/dialer/SMS/SIM services, `com.google.android.gms`, `com.android.vending`, `com.google.android.gsf`, Android System WebView, biometrics/fingerprint/face/keystore, thermal/memory daemons, Wi-Fi/Bluetooth/NFC stacks
- User-critical: all UPI, banking, payment, and 2FA authenticator apps

## Evidence-Only Classification Rules
- Never classify a package from its package name alone.
- Never propose disabling a package solely because it appears in `meminfo` or uses RAM.
- For every candidate package, gather read-only evidence via `safe-adb-read.ps1` (`dumpsys package <pkg>` summarized, current enabled state, battery/background wake evidence).
- If purpose, dependencies, or rollback is uncertain, classify as `UNKNOWN` and STOP.

## Special Protocol for Xiaomi AI Packages
For `com.xiaomi.aicr`, `com.xiaomi.aiasst.vision`, and `com.xiaomi.aiservice`:
1. Classify initially as `CONDITIONAL` (never auto-`OPTIONAL`).
2. Document verified services/bindings to Circle to Search, on-screen translation, text recognition, Camera, Gallery, keyboard, and Notes.
3. Require **Stage 3 Settings-only containment first**: disable unused AI toggles in Settings, turn Autostart OFF, set background activity to Restricted, and observe for **24 hours**.
4. Only consider single-package `pm disable-user --user 0 <pkg>` if 24-hour evidence confirms persistent abnormal drain AND Circle to Search Step A is already completed AND the user explicitly approves.

## Deliverable Format (`reports/package-review.csv`)
Use exact CSV headers:
`package_name,category,purpose,evidence,risk,dependencies,recommendation,rollback_method`

Allowed `category` values:
- `PROTECTED`: Bootloop-critical or core OS/security/telephony/banking component. Do not touch.
- `KEEP`: Actively used by user or required for requested features (e.g., Circle to Search, Camera, Notifications).
- `CONDITIONAL`: Trade-off exists (e.g., AI packages, Xiaomi cloud/sync/theme services). Ask user before any action.
- `OPTIONAL`: Verified non-essential preinstalled bloatware/partner app with clean reversible rollback.
- `UNKNOWN`: Insufficient evidence on purpose, dependencies, or rollback. Do not touch.

Rollback column rules:
- For `pm disable-user --user 0 <pkg>` -> `adb -d shell pm enable --user 0 <pkg>`
- For `pm uninstall -k --user 0 <pkg>` (last resort only if disable is blocked) -> `adb -d shell cmd package install-existing <pkg>`
- Never leave `rollback_method` blank for `CONDITIONAL` or `OPTIONAL` rows.
