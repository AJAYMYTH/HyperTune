# Project Memory — Redmi Note 14 5G Safe Optimization

## Target Device
- Model: Redmi Note 14 5G (24094RAD4I / codename: beryl) — 6 GB RAM — ✅ verified
- OS / Build: HyperOS OS3.0.303.0.WOQINXM / Android 16 — ✅ verified (note: 303.0, not 302.0)
- Method: Non-root ADB (read-only via `scripts/safe-adb-read.ps1`; human executes any approved write manually)
- ADB: v37.0.0 via scrcpy bundle

## Stage Status
- [x] Stage 1: ADB Pre-Flight & Package Inventory (`reports/stage1-check.md`) — completed 2026-11-24
- [x] External Backup Verified (stored at `D:\PhoneBackups\RedmiNote14\`) + `reports/backup-checklist.md` — confirmed 2026-11-24
- [x] Stage 2: Read-Only Baselines (`device`, `touch-and-network`, `notification-and-gaming`, `ai-and-cts`) — completed 2026-11-24
- [x] Stage 3: Zero-Risk Settings & HyperOS Fixes (`reports/system-optimization-plan.md`) — completed & verified 2026-11-25 (`reports/post-stage3-verification.md`)
- [-] Stage 4: Evidence-Backed Package Audit (`reports/package-review.csv`) — **SKIPPED (Decision Gate Passed: core goals achieved via Settings; package removal cannot resolve MediaTek camera ISP pipeline lag)**
- [-] Stage 5: Single-Item Reversible Changes (`reports/change-log.md`) — **SKIPPED (Unnecessary; 0 packages disabled)**
- [x] Stage 6: Post-Session Security Lockdown & Final Summary (`reports/final-summary.md`) — **READY & SEALED** (User executing physical USB disconnect, revocation of USB debugging authorizations, turning OFF Developer options & USB debugging, and verifying UPI/banking apps. Zero further ADB commands permitted).

## Post-Stage-3 Real-World Outcomes & Verification
- Recents Clear Animation: **Smooth** (resolved via settings & ART compilation)
- Circle to Search: **Faster / snappier** (Google App cache cleared + No restrictions)
- Late Notifications: **Arriving on time** (Standby unthrottling + PowerKeeper adjustments)
- Free Fire India: **Smooth**
- `com.xiaomi.aicr`: Successfully contained; dropped off top drainers in batterystats
- Battery Status: 54%, 36.1°C (thermally healthy and stable)
- Camera ART Status: `[status=speed-profile] [reason=bg-dexopt]` (AOT bytecode compiled)
- Camera Cold-Start & Preview Analysis: Viewfinder startup (~2.5s) and mode-switching blur freeze (~2.0s) isolated via screen recording. Diagnosed as MediaTek Dimensity ISP pipeline teardown/rebuild between capture sessions, combined with Auto HDR and Motion Photo buffer overhead. Settings-level camera tuning prescribed.

## Key Baseline Metrics (Stage 2 Completed & Audited)
- Free `/data` storage: 81 GB / 109 GB (74% free) ✅
- Physical RAM: 5.48 GB usable, only ~65 MB unreserved free RAM (heavy ZRAM dependence)
- ZRAM / Swap: ~6.0 GB allocated (Memory Extension = ON), 632 MB physical RAM used to hold 2.0 GB compressed data (3.16:1 ratio)
- Battery Drainers (2h 22m logging, 84.7% screen-on): System UI/Server (333 mAh), Kernel/ZRAM workers (140 mAh), WhatsApp (53.8 mAh), Instagram (47.8 mAh), MediaTek Baseband (42.3 mAh), Play Services (39.1 mAh), Media Provider (37.9 mAh)
- Thermals: SoC junction ~52.4°C (due to 2h continuous screen-on, media indexing, and USB charge-controller activation), Battery 33.4°C - 34.1°C, Skin 35.8°C (chassis is thermally safe)
- Display & Refresh Rate: 120 Hz peak, 1.0x animation scales, 300 ms long press
- Network Latency: ICMP ping to 1.1.1.1 (avg 161.6 ms, jitter 95.5 ms), 8.8.8.8 (avg 114.8 ms, jitter 79.8 ms); Private DNS: null (off)
- Notification Diagnostics:
  - Instagram, Snapchat, Facebook: Standby Bucket 40 (RARE) + excluded from Doze whitelist (explaining why alerts are delayed until device wake)
  - YouTube: Standby Bucket 10 (ACTIVE), but delayed by HyperOS PowerKeeper battery saver / background freeze and memory eviction
  - GMS and SMS: Bucket 5 (EXEMPTED) + whitelisted (explaining why OTPs arrive instantly)
- Circle to Search: 100% native Google App (`googlequicksearchbox`), zero dependency on Xiaomi AI packages; bottlenecked by RAM contention and network jitter

## Classification Corrections (User-Directed)
- `com.microsoft.appmanager`, `com.microsoft.deviceintegrationservice`, `com.microsoftsdk.crossdeviceservicebroker` → **KEEP** (Microsoft Phone Link / Link to Windows)
- `com.xiaomi.joyose` → **KEEP/CONDITIONAL** pending evidence (handles Game Turbo, thermal/GPU scheduling — not pure adware)
- `com.xiaomi.aiservice` → **KEEP** (Core framework powering Gallery OCR, face clustering, auto-crop, photo magic eraser, Sound Recorder ASR, and Camera document scanner; verified zero relation to Circle to Search)
- `com.xiaomi.aicr` → **CONDITIONAL** (Settings-only containment first: disable unused toggles, Autostart OFF, observe 24 hours)
- `com.xiaomi.aiasst.vision` → **CONDITIONAL** (Powers on-screen translate and camera OCR via MediaTek NPU)
- Do NOT pre-label packages as bloat candidates without Stage 2 usage/battery evidence.

## Decisions & Rollbacks Log
- **Stage 3 Completion (2026-11-25):** Core user objectives achieved via non-destructive Settings adjustments. Recents clear smooth, Circle to Search faster, late notifications resolved, Free Fire smooth, and battery/AICR contained.
- **Stage 4 & 5 Decision Gate:** Bypassed with technical justification. The isolated remaining issue (Camera cold start & mode-switching preview lag) was diagnosed via screen recording as a MediaTek ISP capture session reconfiguration overhead and Auto HDR / Motion Photo buffering, which cannot be fixed by package debloating. Moving to Camera Settings optimization and Stage 6 Security Lockdown.
- **Repository Setup (2026-11-25):** Created detailed README.md and .gitignore, initialized local git repository on branch `main`, and configured remote `origin` to `https://github.com/AJAYMYTH/optimize-your-redmi14-5g.git`. Ready for initial commit and push.
- **Project Branding & Community Files (2026-11-25):** Named the project **HyperTune**. Created LICENSE (MIT), SECURITY.md (vulnerability reporting policy), CONTRIBUTING.md (PR process, safety rules, device report template), CODE_OF_CONDUCT.md (Contributor Covenant v2.1 + Device Safety Clause), and ISSUES.md (bug/device/feature templates + FAQ). Updated README.md title to "⚡ HyperTune", added License badge, expanded Contributing & License section with links to all community files, and updated repository structure tree.
