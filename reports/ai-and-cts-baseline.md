# Xiaomi AI & Circle to Search Baseline Report (Stage 2D)

**Device:** Redmi Note 14 5G (beryl / 24094RAD4I)  
**OS Build:** HyperOS OS3.0.303.0.WOQINXM | Android 16  
**Timestamp:** 2026-11-24T00:27 IST  
**Method:** Non-root ADB read-only via `.\scripts\safe-adb-read.ps1`

---

## 1. Circle to Search Architecture & Current Status
* **System Overlay:** `com.android.overlay.circletosearch` (Enabled, System overlay)
* **Underlying Engine:** `com.google.android.googlequicksearchbox` (Google App)
* **Helper Services:** `com.google.android.gms` (Google Play services), Android System WebView

### Findings:
1. Circle to Search is **100% Google-native**. It is invoked via long-press on the home handle/button and rendered directly by Google App over the screen buffer.
2. It does **NOT** depend on Xiaomi's AI packages (`aicr`, `aiasst.vision`, `aiservice`).
3. Circle to Search responsiveness on this device is bottlenecked by:
   * **RAM contention:** When Google App (`googlequicksearchbox`) is kicked to background or swapped to ZRAM, holding the gesture handle forces decompression/reload from swap, causing a 1–2 second lag before the search overlay freezes the screen.
   * **Network jitter:** ICMP ping baseline showed high variance (48ms to 272ms), delaying Google Visual Search server response.
   * **App Standby & Memory Extension:** Decompressing pages on MediaTek CPU cores while capturing display buffer adds rendering latency.

---

## 2. In-Depth Audit of Xiaomi AI Packages

### A. `com.xiaomi.aicr` (Xiaomi AI Cognition & Recognition)
* **Location:** `/data/app/.../com.xiaomi.aicr` (Updated system package)
* **Standby Bucket:** `5 (EXEMPTED)`
* **Doze Status:** Present in **User Doze Whitelist** (runs even in deep sleep)
* **Active Background Service:** `com.xiaomi.aicr:cognitionService` (consuming ~106 MB RSS)
* **Features Provided:**
  * Global AI Writing (`GlobalAiWritingActivity`)
  * AI Search Engine (`AiSearchSettingActivity`)
  * Smart Clipboard (`CopyDirectSettingsActivity`)
  * HyperMind Connectivity (`com.milink.service` integration)
  * Intention Router (`IntentionRouterActivity`)
* **Bound Apps / Dependencies:**
  * System: `com.miui.gallery`, `com.miui.home`, `com.miui.screenshot`, `com.miui.mediaeditor`, `com.android.contacts`, `com.android.deskclock`, `com.miui.weather2`.
* **Circle to Search Risk:** **Zero**.
* **System Feature Risk:** Disabling breaks AI smart clipboard, HyperMind device synergy, and Xiaomi global AI text suggestions.

---

### B. `com.xiaomi.aiasst.vision` (Xiaomi AI Vision Assistant)
* **Location:** `/product/app/AiAsstVision` (System UID 1000)
* **Standby Bucket:** `5 (EXEMPTED)`
* **Hardware Interop:** Loads `libneuronusdk_adapter.mtk.so` (Direct MediaTek APU/NPU hardware acceleration)
* **Permissions:** Foreground Camera service, audio recording, system display modification.
* **Features Provided:**
  * On-screen live AI Translate (`xiaomi.permission.aivision.MI_AI_TRANSLATE`)
  * Camera AI scene recognition & subtitle generation
  * Direct linkage to `com.miui.notes`
* **Circle to Search Risk:** **Zero**.
* **System Feature Risk:** Disabling breaks HyperOS built-in screen translation and Camera AI live text detection.

---

### C. `com.xiaomi.aiservice` (Xiaomi Core AI Service Framework)
* **Location:** `/product/priv-app/AIService`
* **Standby Bucket:** `10 (ACTIVE)`
* **Multi-Process Architecture Services Exposed:**
  1. `FACECLUSTER`: Gallery facial recognition and clustering
  2. `AUTOCROP`: Automatic composition/cropping in Gallery
  3. `CARDRECOGNIZE`: Document & ID card scanning in Camera/Gallery
  4. `CREATION`: AI generative fill & photo magic eraser
  5. `TRANSLATE`: Core neural translation engine
  6. `ASR`: Speech-to-text engine used by Sound Recorder
  7. `OCR`: Text detection in images (copy text from photos)
  8. `PET`: Pet recognition and tagging in Gallery
  9. `TAG`: Visual search tags in Gallery
  10. `NER`: Named entity recognition in Notes/Messages
* **Circle to Search Risk:** **Zero**.
* **System Feature Risk:** **HIGH for Gallery/Camera**. Disabling will cause feature breakage or crashes in Gallery (Album categorization, OCR, photo editor) and Camera (document scanner).

---

## 3. Recommended AI Containment Strategy (Stage 3 Preview)
Rather than abruptly disabling these packages via ADB:
1. **Settings-Only Containment First:**
   * Remove `com.xiaomi.aicr` from unrestricted background execution.
   * Turn off unused AI toggles in Settings (AI writing assistant, Smart suggestions, HyperMind).
   * Restrict background battery policy for `com.xiaomi.aicr`.
2. **Observe for 24 Hours:**
   * Evaluate if Gallery, Camera cold start, and battery improve without breaking core features.

---

## 4. Circle to Search Benchmark Protocol (To Fill In)
*Procedure: Connect to network, perform 5 consecutive Circle to Search invocations on a static webpage (e.g., Wikipedia article), recording time from gesture trigger to result overlay:*

### On Wi-Fi:
* Attempt 1: `___ s`
* Attempt 2: `___ s`
* Attempt 3: `___ s`
* Attempt 4: `___ s`
* Attempt 5: `___ s`
* **Average:** `___ s`

### On Mobile Data (5G/4G):
* Attempt 1: `___ s`
* Attempt 2: `___ s`
* Attempt 3: `___ s`
* Attempt 4: `___ s`
* Attempt 5: `___ s`
* **Average:** `___ s`
