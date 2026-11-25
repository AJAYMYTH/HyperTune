---
name: adb-safe-diagnostics
description: Run read-only ADB diagnostics on Redmi Note 14 5G (HyperOS) strictly through scripts/safe-adb-read.ps1, enforce local PII redaction, and generate structured baseline reports for battery, RAM, storage, thermal, camera, touch, network, notifications, gaming, and Xiaomi AI packages.
---

# ADB Safe Diagnostics

## Guardrails
- Use ONLY `powershell -ExecutionPolicy Bypass -File .\scripts\safe-adb-read.ps1 <args>` for every ADB invocation.
- Show the exact command and wait for user approval before running it.
- Verify exactly ONE authorized device is connected before running any shell command. STOP immediately if 0, >1, or `unauthorized`.
- Never run bare `getprop` without a key name, never capture full `bugreport`, and never dump raw PII targets (`notification`, `account`, `telecom`, `telephony.registry`, `sms`, `wifi`, `connectivity`, `location`, `clipboard`, `contacts`).
- Double-check every output for stray identifiers before writing to `inventory/` or `reports/`.

## Workflow

### Stage 1: Device Pre-Flight & Inventory
1. Verify ADB and single connected device:
   - `version`
   - `devices`
2. Verify hardware and OS build (one property per call or targeted read-only commands):
   - `-d shell getprop ro.product.model`
   - `-d shell getprop ro.product.device`
   - `-d shell getprop ro.build.version.release`
   - `-d shell getprop ro.build.version.incremental`
3. Capture initial health and package inventory:
   - `-d shell df -h /data`
   - `-d shell dumpsys battery`
   - `-d shell pm list packages -3` (save to `inventory/packages-user.txt`)
   - `-d shell pm list packages -s` (save to `inventory/packages-system.txt`)
   - `-d shell pm list packages -d` (save to `inventory/packages-disabled.txt`)
4. Write redacted summary to `reports/stage1-check.md` and hand off to `external-backup-guide`.

### Stage 2A: Core Device Baseline (`reports/device-baseline.md`)
Collect read-only summaries only:
- Battery temperature, level, status, and top wake/battery consumers (`dumpsys batterystats --charged` summarized—do not dump raw multi-thousand-line logs into reports).
- RAM & LMK pressure (`dumpsys meminfo` summary—focus on 6GB RAM headroom, cached processes, zram/swap usage).
- Memory Extension / swap state (`cat /proc/swaps` and relevant swap/extm property).
- Storage usage (`df -h /data`, flag if <20% free).
- Thermal state (`dumpsys thermalservice` summary).
- Guide user to perform 5x Camera cold-start timings (stopwatch from tap to live viewfinder ready) and record Recents clear behavior.

### Stage 2B: Touch & Network Baseline (`reports/touch-and-network-baseline.md`)
- Touch & Display:
  - Read `settings get system peak_refresh_rate`, `settings get system min_refresh_rate`, `settings get global low_power`, `settings get secure long_press_timeout`.
  - Ask user about screen protector thickness, edge-covering case, and Pointer Location drag test.
- Network (redacted summaries only—no SSIDs, BSSIDs, MACs, IPs, SIM/phone IDs):
  - Read `settings get global private_dns_mode` and `settings get global private_dns_specifier` (verify no private hostname leaks).
  - Run `-d shell ping -c 5 1.1.1.1` (and/or `8.8.8.8`) once on Wi-Fi and once on mobile data; record min/avg/max ms and packet loss only.
  - Record user-reported 3x speed test baseline (Wi-Fi vs mobile data).

### Stage 2C: Notifications & Gaming Baseline (`reports/notification-and-gaming-baseline.md`)
- Late Notifications (ask user for target app package names—e.g., YouTube, social apps):
  - Check Data Saver (`cmd netpolicy get restrict-background`).
  - Check Doze state (`dumpsys deviceidle get deep` / `light`).
  - Per named app, check App Standby bucket (`am get-standby-bucket <pkg>`) and whitelist/power restriction status (`dumpsys deviceidle whitelist` filtered strictly to the named app and `com.google.android.gms`).
  - Never read or display any notification content.
- Gaming (ask user for game name and package):
  - Record before/after 10-minute play temperatures (`dumpsys battery` temperature field).
  - After a 10-minute session, run `dumpsys gfxinfo <pkg>` and extract ONLY frame count, janky frames count/percentage, and 90th/95th/99th percentile frame times. Do not save raw frame dumps.

### Stage 2D: Xiaomi AI Packages & Circle to Search (`reports/ai-and-cts-baseline.md`)
- Inspect `com.xiaomi.aicr`, `com.xiaomi.aiasst.vision`, and `com.xiaomi.aiservice` using read-only package/service queries (`dumpsys package <pkg>` summarized for permissions, services, exported components, and current enabled/disabled state; plus battery/standby usage).
- Map real dependencies (Circle to Search, on-screen translation, text recognition, Camera, Gallery, keyboard, Notes). Never guess from package names.
- Record user's 5x timed Circle to Search baseline (seconds from long-press to result) on both Wi-Fi and mobile data.

## Redaction Verification Gate
Before writing ANY file under `reports/` or `inventory/`, verify zero occurrences of:
- Device serial numbers, IMEI, IMSI, ICCID, Android ID
- Email addresses, Google/Xiaomi account IDs, phone numbers
- Wi-Fi SSIDs, BSSIDs, MAC addresses, private/public IP addresses
