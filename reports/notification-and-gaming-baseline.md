# Notification & Gaming Baseline Report (Stage 2C)

**Device:** Redmi Note 14 5G (beryl / 24094RAD4I)  
**OS Build:** HyperOS OS3.0.303.0.WOQINXM | Android 16  
**Timestamp:** 2026-11-24T00:26 IST  
**Method:** Non-root ADB read-only via `.\scripts\safe-adb-read.ps1`

---

## 1. Late Notification Diagnostic Root Cause Analysis
*Prompt Objective 3: "Diagnose and fix late notifications (YouTube/social apps delayed by minutes while OTP/SMS arrive on time)."*

### The Evidence:

#### A. Data Saver & Network Policy
* Command: `cmd netpolicy get restrict-background`
* Status: **Disabled** (Not causing network restriction).

#### B. Standby Bucket State (`am get-standby-bucket`)
Android standby buckets throttle background execution, job dispatching, and network alarms according to platform policy:
* `5` = `EXEMPTED` (System-whitelisted or persistent core services; zero background throttling)
* `10` = `ACTIVE` (Currently in use, recently used, or foreground-linked; normal job scheduling)
* `20` = `WORKING_SET` (Frequently used apps; minor deferral of background jobs)
* `30` = `FREQUENT` (Regularly used apps; background jobs deferred up to several hours)
* `40` = `RARE` (Infrequently used apps; strict job throttling, alarms batched up to 24-48 hours)
* `45` = `RESTRICTED` (Extreme Android 12+ containment; zero background jobs/alarms unless opened)

| Target App | Standby Bucket | Android Policy Meaning | HyperOS Actual Delay Mechanism |
|------------|----------------|------------------------|--------------------------------|
| `com.google.android.gms` | **5 (EXEMPTED)** | Unrestricted | Google Cloud Messaging / FCM transport socket held open constantly |
| `com.google.android.apps.messaging` (SMS/OTP) | **5 (EXEMPTED)** | Unrestricted | System carrier SMS wakeups bypass all Doze rules; instant OTP arrival |
| `com.whatsapp` | **10 (ACTIVE)** | Active | High FCM priority; minimal delay |
| `com.google.android.youtube` | **10 (ACTIVE)** | Active | **Not throttled by Android Standby Bucket.** Delay is caused by **HyperOS PowerKeeper aggressive background freezing**, missing Autostart toggle, or process eviction from 6GB RAM under memory pressure. |
| **`com.instagram.android`** | **40 (RARE)** | Heavily Deferred | Android batches network alarms + HyperOS PowerKeeper suspends background worker threads. Alerts delayed by minutes or until device unlock. |
| **`com.snapchat.android`** | **40 (RARE)** | Heavily Deferred | Severe alarm deferral + PowerKeeper suspension; snaps/messages delayed. |
| **`com.facebook.katana`** | **40 (RARE)** | Heavily Deferred | Background sync delayed significantly. |

#### C. Doze Exemption / Whitelist (`dumpsys deviceidle whitelist`)
* **Whitelisted System Services:** GMS Core (`com.google.android.gms`), Telephony/SMS (`com.android.mms`, `com.google.android.apps.messaging`), Phone Link (`com.microsoft.appmanager`).
* **Whitelisted Xiaomi Services:** `com.miui.powerkeeper`, `com.xiaomi.xmsf`, `com.miui.msa.global`, `com.miui.analytics`, `com.xiaomi.aicr`.
* **User Apps Whitelisted:** **NONE**.
  * Neither Instagram, Snapchat, Facebook, nor YouTube are exempt from battery optimization.

### Diagnostic Conclusion:
1. **For Instagram, Snapchat, and Facebook:** Android 16 App Standby has relegated them to **Bucket 40 (RARE)** because they were not interacted with continuously in foreground. Combined with exclusion from the Doze whitelist, background networking is heavily suspended during screen-off sleep.
2. **For YouTube:** The app is in **Bucket 10 (ACTIVE)**. Its notification latency is **not** an Android Standby Bucket issue. Rather, it is driven by **HyperOS-specific battery optimization (PowerKeeper default setting "MIUI Battery Saver / HyperOS Battery Saver")**, lack of background Autostart authorization, and rapid eviction from 6GB RAM when heavy apps run.

---

## 2. Gaming Baseline (Target Setup)

### Identified Candidate Game:
* Package: `com.garena.game.ffi` (Free Fire India) — present in user package inventory.

### HyperOS Gaming Architecture Context:
* `com.xiaomi.joyose`: Handles Game Turbo profiles, GPU frequency scaling, and dynamic thermal throttling.
* `com.miui.powerkeeper`: Governs frame rate caps and thermal limits per package.
* Current SoC Idle Temperature: ~52°C, Battery: ~34°C.

### Standard 10-Minute Gaming Measurement Protocol:
*(To be conducted before making system changes):*
1. **Pre-Session Measurement:**
   * Record starting battery % and temperature via `dumpsys battery`.
2. **Gameplay Session:**
   * Play 1 ranked/standard match (minimum 10 minutes) with current settings.
3. **Immediate Post-Session Measurement:**
   * Record ending battery % and temperature.
   * Run read-only frame timing analysis:
     `adb -d shell dumpsys gfxinfo com.garena.game.ffi`
   * Key metrics to capture: Total Frames Rendered, Janky Frames Count (%), 90th / 95th / 99th Percentile frame times.
