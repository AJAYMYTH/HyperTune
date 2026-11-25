# Post-Stage-3 Verification & Benchmark Report

**Device:** Redmi Note 14 5G (beryl / 24094RAD4I)  
**OS Build:** HyperOS OS3.0.303.0.WOQINXM | Android 16  
**Timestamp:** 2026-11-25T15:20 IST  
**Method:** Non-root ADB read-only verification via `.\scripts\safe-adb-read.ps1` + screen recording frame-by-frame inspection.

---

## 1. Real-World User Results Summary

| Target Objective | Stage 2 Baseline State | Stage 3 Real-World Result | Verdict |
|---|---|---|---|
| **Recents Clear Animation** | Stutter and launcher redraw delay | **Smooth** | ✅ **RESOLVED** |
| **Circle to Search Speed** | 1.5–2.0s delay, reload lag | **Noticeably Faster / Snappier** | ✅ **RESOLVED** |
| **Late Notifications** | YouTube, IG, Snapchat delayed in Bucket 40 | **Arriving On Time** | ✅ **RESOLVED** |
| **Free Fire India (Gaming)** | Untested / high jitter baseline | **Smooth** | ✅ **RESOLVED** |
| **`com.xiaomi.aicr` Containment** | ~106 MB RSS active, Doze whitelisted | **Contained, dropped from top drainers** | ✅ **RESOLVED** |
| **Stock Camera Cold-Start & Preview** | Laggy start, preview frame drops | **Still Lagging (2.5s cold start, 2s mode switch)** | ⚠️ **ISOLATED BOTTLENECK** |

---

## 2. Telemetry Verification (Live ADB Diagnostics)

### A. Device Uptime & Power State
* **Uptime:** 1 day, 14 hours, 11 minutes (Linux kernel continuous).
* **Battery:** 54%, 36.1°C (thermally cool and stable).
* **Dexopt Compilation Status:**
  * Package: `com.android.camera`
  * Status: `arm64: [status=speed-profile] [reason=bg-dexopt]`
  * Artifacts: `base.art` (1.5 MB), `base.dex` (5.0 MB).
  * **Finding:** `bg-dexopt-job` **successfully compiled** the camera bytecode ahead-of-time. The lag is **not** caused by JIT compilation of app code.

### B. Memory & Swap State (`dumpsys meminfo`)
* **Total Physical RAM:** 5.48 GB (Status: Normal).
* **Kernel ZRAM Allocation:** Still allocated at 6,291,452 KB (~6.0 GB).
* **Physical ZRAM Occupied:** **592 MB** (down from 837 MB in Stage 2).
* **Compressed Data in Swap:** 1.90 GB (down from 2.57 GB in Stage 2).
* **Observation:** Physical RAM pressure improved significantly, but the underlying swap partition remains configured at 6GB.

### C. Batterystats Top Drainers & AICR Audit (`dumpsys batterystats --charged`)
* Interval: 6h 26m on battery (3h 0m screen-on time).
* **Top Consumers:**
  1. `UID 1000` (System Server / Framework): 357 mAh (normal).
  2. `UID 10219` (`com.google.android.youtube`): 274 mAh (50m active video playback).
  3. `UID 10334` (`com.instagram.android`): 213 mAh (40m active foreground usage).
  4. `UID 0` (Kernel): 113 mAh (reduced from previous rate).
* **`com.xiaomi.aicr` (UID 10144):** Successfully dropped off the top power consumer list! Settings containment (Autostart OFF + Restrict background activity) is performing as expected.

### D. Earphone & Bluetooth Background Service Explanation
* In `dumpsys meminfo`, `com.milink.service:audio` (pid 30567, ~91 MB RSS) and `com.xiaomi.mi_connect_service` (pid 8369, ~88 MB RSS) are active.
* **Why it runs:** `com.milink.service:audio` is Xiaomi's Smart Interconnect audio service. It registers as a system Bluetooth audio router to detect paired Xiaomi/Redmi earbuds, manage low-latency codec switching, and handle earphone battery popups. This is normal system framework behavior when Bluetooth devices are paired.

---

## 3. Deep Diagnosis of Camera Cold-Start & Preview Lag
*(Analyzed from `Screenrecorder-2026-11-25-10-48-40-161.mp4`)*

### Video Frame-by-Frame Timeline:
1. **00:00.0 - 00:01.2:** Tap Camera icon on home screen → Black splash window opens.
2. **00:01.3 - 00:02.8:** Camera UI overlays (shutter, zoom toggle `0.6x / 1x / 2x`, mode rail) render, but the viewfinder remains **pure black for ~1.5 seconds**.
3. **00:02.9:** Live sensor preview frames finally arrive and render on screen.
4. **00:14.0 - 00:30.0 (Mode Switching Test):**
   * Switching Photo → Video: Viewfinder **freezes with a Gaussian blur for 2.0 seconds** before video stream opens.
   * Switching Video → Ultra HD: Viewfinder **blurs and freezes for 2.2 seconds**.
   * Switching Ultra HD → Night: Viewfinder **blurs and freezes for 2.0 seconds**.
   * Switching Night → Photo: Viewfinder **blurs and freezes for 2.1 seconds**.

### Root Cause Analysis:
1. **MediaTek Dimensity ISP Pipeline Reconfiguration:**
   * In HyperOS on MediaTek platforms, each camera mode (Photo 12MP binned vs Video 1080p vs Ultra HD 50MP full-sensor vs Night RAW multi-frame stack) uses a completely different hardware ISP processing stream.
   * When switching modes, `camerahalserver` completely tears down the existing `CameraCaptureSession`, flushes hardware buffers, and negotiates a new stream with the camera sensor. The Gaussian blur in the video is HyperOS's built-in fallback frame while waiting for the MediaTek ISP to deliver the first valid frame.
2. **Auto HDR & Live Photo Handshake:**
   * In the video, **Auto HDR** (`A` icon) is active in the top bar.
   * `com.android.camera.OneShotLivephotoCamera` is active, continuously spooling 1.5s circular video buffers in background.
   * `com.xiaomi.cameramind` (Camera AI engine) initializes on launch to evaluate scene composition, adding startup latency before the shutter is ready.
3. **Crucial Architectural Conclusion:**
   * **Stage 4 Package Debloating CANNOT fix this Camera lag.** The delay is entirely between `com.android.camera`, `com.xiaomi.cameramind`, and `camerahalserver` (all protected OEM camera HAL services). Disabling third-party or system bloat packages will have zero effect on MediaTek camera HAL session rebuild times.

---

## 4. Stage 3 Decision Gate Evaluation

### Can We Skip Stage 4 (Package Audit) and Stage 5 (Package Disabling)?
### **VERDICT: YES — SKIP STAGE 4 AND STAGE 5.**

* **Reasoning:**
  1. Recents clear lag is **resolved**.
  2. Circle to Search is **resolved**.
  3. Late notifications are **resolved**.
  4. Gaming (Free Fire) is **smooth**.
  5. Battery drain from `com.xiaomi.aicr` is **contained**.
  6. The only remaining concern is Stock Camera cold-start and mode-switching, which is an internal Camera HAL/ISP stream configuration issue, **not** caused by debloatable packages.
  7. Disabling system packages via ADB would introduce bootloop or update instability without solving the camera pipeline handshake.

---

## 5. Targeted Zero-Risk Camera Tuning (Settings-Only)

Instead of risky package removals, apply these camera-specific settings in this exact sequence:

1. **Clear Camera Storage Data First (Fresh State):**
   * Go to **Settings → Apps → Manage apps → Camera → Clear data → Clear all data**.
   * *Purpose:* Wipes out stale image caches, corrupt thumbnail registries, and legacy post-update configurations cleanly before applying new settings.
2. **Turn OFF Auto HDR:**
   * Open Camera → in top bar, tap the `HDR` icon → Set from **Auto** to **OFF** (turn on manually only in harsh backlighting). Auto HDR forces the ISP to calculate exposure bracket histograms on every single preview frame during startup.
3. **Turn OFF Motion / Live Photos:**
   * In Camera top bar or swipe-down tray → Ensure **Live Photos / Motion Photos** is **OFF**. This stops the camera from maintaining a continuous 1.5-second circular video buffer in RAM during viewfinder preview.
4. **Turn OFF AI Camera Scene Recognition (Default):**
   * In Camera top bar → Tap the `AI` icon to turn it **OFF**. Keeps `cameramind` idle on startup until manually requested.
5. **Camera In-App Settings Optimization:**
   * In Camera → Tap top-right dropdown (or 3-lines menu) → **Settings**:
     * **Watermark:** Turn **Device watermark** and **Time watermark** -> **OFF** (prevents background GPU canvas compositing on every shot).
     * **Auto night mode:** Turn **OFF** (use the dedicated Night mode tab instead; prevents continuous low-light algorithm evaluation on every photo preview).
     * **Correct distortion in ultra-wide shots:** OFF (reduces real-time geometric warp compute in 0.6x mode).
