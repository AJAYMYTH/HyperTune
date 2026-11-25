# Phone Optimization Safety Rules (Always On)

## Scope
Assist with read-only diagnostics, planning, and verified change documentation for ONE non-root phone:
- Device: Redmi Note 14 5G (6GB RAM)
- Target OS: HyperOS 3.0.302.0.WOQINXM.C08 / Android 16 (verify on first connect)
- Host: Windows
- Method: Non-root ADB only

Safety strictly overrides speed. When uncertain, STOP and ask.

## Mandatory Read-Only Guard
- For EVERY read-only ADB command, invoke ONLY:
  `powershell -ExecutionPolicy Bypass -File .\scripts\safe-adb-read.ps1 <adb-args>`
- NEVER invoke raw `adb` directly.
- NEVER access paths outside the open workspace. Never ask the user to move phone backups inside the workspace.
- Show the exact command and wait for explicit user approval before running anything. Run one command (or one small read-only group) at a time.

## Hard Execution Boundary (Human Executes All Writes)
- NEVER execute any phone-modifying command directly (`pm uninstall`, `pm disable-user`, `pm disable`, `pm enable`, `pm clear`, `pm hide`, `settings put`, `setprop`, `device_config`, `appops set`, `pm grant`, `pm revoke`, `am force-stop`, `adb push`, `adb install`, `adb reboot`, `cmd package`).
- For every proposed modification, present a Change Card containing:
  1. Recorded original state/value
  2. Purpose, expected measurable benefit, risk, and dependencies
  3. Exact single command for the user to run in their own local terminal
  4. Exact verified rollback command
- Wait for the user to confirm execution, then verify the result read-only via `safe-adb-read.ps1`.
- If the user declines or says no, do NOTHING and move on. Never retry a denied action in another form.

## Absolute HyperOS Bootloop & System Blacklist (NEVER Propose Disabling or Removing)
- Bootloop-critical Xiaomi packages:
  - `com.miui.securitycenter`
  - `com.xiaomi.finddevice`
  - `com.miui.guardprovider`
  - `com.xiaomi.account`
  - `com.miui.home`
  - `com.miui.powerkeeper`
  - `com.xiaomi.xmsf`
  - `com.miui.rom`
- Core Android & OEM systems:
  - System UI (`com.android.systemui`)
  - Camera HAL & camera system services
  - Telephony, IMS, dialer, SMS, SIM toolkit
  - Google Play services, Play Store, GSF, Android System WebView
  - Permission controller, package installer
  - Biometrics, fingerprint/face services, keystore, security frameworks
  - Thermal, power, and memory management daemons
  - Wi-Fi, Bluetooth, NFC stacks
  - System Updater / OTA (`com.android.updater`)
  - Any UPI, banking, payment, or authenticator app
- Prohibited actions (zero exceptions):
  - Root, bootloader unlock, `fastboot`, flashing, recovery/sideload, factory reset, wipe, `adb root`, `su`
  - Mass-debloat scripts or commands copied from online lists/forums
  - Combining multiple changes into one command or script
  - Hidden `settings put` touch or Wi-Fi tweaks
  - Cleaner, booster, task-killer, or unrequested VPN/DNS apps

## Privacy & Integrity
- Never inspect notifications, SMS, call logs, contacts, clipboard, or app-private data.
- Never write serial numbers, IMEI, IMSI, ICCID, phone numbers, SSIDs, BSSIDs, MACs, IPs, accounts, or emails into any file or chat response.
- If a package's purpose, dependencies, or rollback is uncertain, classify it `UNKNOWN` and STOP. Never judge safety from package name or RAM usage alone.
- Never claim a backup is complete without user-verified counts, sizes, zero-byte checks, and sample-open checks. Never claim `adb pull` backs up app-private data.

## Failure Policy
- If any command errors, STOP and report the error. Do not improvise alternative commands.
- If any regression test degrades after a change, STOP all further changes and instruct immediate rollback.
