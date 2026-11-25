# Stage 3 — Zero-Risk Settings & System Optimization Plan

**Target Device:** Redmi Note 14 5G (beryl / 24094RAD4I)  
**OS Build:** HyperOS OS3.0.303.0.WOQINXM | Android 16  
**Execution Policy:** Human-executed Settings-only modifications and safe compilation commands. **Zero ADB package disable/uninstall commands in this stage.**  
**Status:** Ready for human review and single-step execution.

---

## Overview & Execution Rules
1. Every optimization item below is non-destructive, does not touch root, and carries an immediate verified rollback path.
2. Execute one item at a time. Re-measure the relevant user experience metric before proceeding to the next.
3. No package disable or uninstall commands (`pm disable-user`, `pm uninstall`) are included in Stage 3. Stage 4 (Package Audit) and Stage 5 (Reversible Changes) will only be approached after completing this stage and gathering 24-hour stability data.

---

## 1. Storage Health & User App Housekeeping
*Current State:* 81 GB free / 109 GB (74% free, well above 20% minimum safety threshold).

### Action 1.1: Post-Backup Routine Storage Hygiene
* **Setting Path:** Phone Settings → Storage (or Security app → Cleaner)
* **Original Value:** 27 GB used
* **Expected Benefit:** Removes stale thumbnail databases, temporary installation artifacts, and OTA staging caches without impacting personal data.
* **Risk:** Extremely low.
* **Rollback:** Automatic (caches regenerate as apps run).
* **Instruction:** Open **Security app → Deep clean / Cleaner** and clear temporary cache files only. Avoid deleting WhatsApp media or Download folder files (already backed up, but maintain on-device integrity).

### Action 1.2: Normal Manual Uninstall of Unused 3rd-Party User Apps
* **Setting Path:** Home screen or Settings → Apps → Manage apps
* **Original Value:** 50 user-installed packages present
* **Expected Benefit:** Frees RAM and prevents background wakeups for unused apps without using ADB.
* **Risk:** None (user-installed apps can be re-installed from Play Store at any time).
* **Rollback:** Re-install from Google Play Store.
* **Candidate Review (Only if you do not actively use them):**
  * `com.music.bitchord` (Bitchord)
  * `com.soulcompany.bubbleshooter.relaxing` (Bubble Shooter)
  * `com.agoda.mobile.consumer` (Agoda)
  * `com.indus.appstore` (Indus Appstore)
  * Any commercial shopping apps you do not frequent

---

## 2. HyperOS Zero-Risk System Wins

### Action 2.1: Revoke MSA (`com.miui.msa.global`) and System Daemon Authorization
* **Setting Path:** **Settings → Fingerprints, face data & screen lock → Authorization & revocation**
* **Original Value:** `msa` = Authorized (ON), `System Daemon` = Authorized (ON)
* **Expected Benefit:** Cuts off background advertising daemon polling, telemetry beacons, and system ad delivery. Saves ~115 MB background RAM and prevents network wakeups.
* **Risk:** None. Ad revocation is an officially supported Xiaomi privacy toggle.
* **Rollback:** Return to **Settings → Authorization & revocation** and toggle both back **ON**.
* **Instruction:**
  1. Toggle **msa** to **OFF**. Wait 10 seconds for the countdown, then tap **Revoke**.
  2. Toggle **System Daemon** to **OFF**. Wait 10 seconds for the countdown, then tap **Revoke**.
  *(If revocation fails on the first attempt due to network timing, retry once while connected to Wi-Fi).*

### Action 2.2: Disable Personalized Ad Recommendations Globally
* **Setting Path:**
  1. **Settings → Fingerprints, face data & screen lock → Privacy → Ad services → Personalized ad recommendations** → Turn **OFF**.
  2. **Security App → Settings (gear icon) → Recommendations** → Turn **OFF**.
  3. **Themes App → Profile → Settings → Recommendations** → Turn **OFF**.
  4. **File Manager App → Settings → About → Recommendations** → Turn **OFF**.
* **Original Value:** Enabled (ON)
* **Expected Benefit:** Stops analytics logging and ad banner generation across system apps.
* **Risk:** Zero.
* **Rollback:** Turn toggles back ON.

### Action 2.3: Test Memory Extension = OFF (Critical for 6GB RAM & Camera/Recents Lag)
* **Setting Path:** **Settings → Additional settings → Memory extension**
* **Original Value:** `Enabled (~6.0 GB virtual RAM / ZRAM allocation)`
* **Expected Benefit:**
  * Eliminates CPU thrashing from constant ZRAM compression and decompression (UID 0 kernel workers accounted for 140 mAh battery drain in our Stage 2 logs!).
  * Speeds up Camera cold-start and Recents app-switching by keeping processes in pure uncompressed physical RAM rather than paging over virtual swap.
* **Risk:** With 6GB physical RAM, heavy multitasking (keeping 10+ background apps open simultaneously) will lead to faster background process termination by LMK. However, foreground app performance and camera responsiveness will significantly improve.
* **Rollback:** Return to **Settings → Additional settings → Memory extension**, select 4GB or 6GB, and restart phone.
* **Instruction:**
  1. Go to **Settings → Additional settings → Memory extension**.
  2. Select **Off**.
  3. Tap **Restart** to reboot the phone.
  4. After reboot, repeat the **5x Camera cold-start test** and **Recents clear test** to verify the performance difference.

---

## 3. Safe ART Profile-Guided Compilation (`bg-dexopt-job`)
* **Context:** The device recently upgraded to HyperOS **OS3.0.303.0**. Android runtime compiles apps ahead-of-time (AOT) using profile data collected during usage. After updates, apps default to `verify` or `speed-profile` without full optimization, causing micro-stutters during app launches.
* **Setting Path:** Executed via local ADB terminal while device is idle and plugged in.
* **Original Value:** Incomplete background dexopt state (many packages in `verify` state).
* **Expected Benefit:** Compiles frequently used application code into optimized machine code ahead of time. Significantly reduces JIT compilation overhead, drops app cold-start times, and eliminates post-update stutter.
* **Risk:** Zero. Uses the official Android operating system maintenance command. Uses temporary CPU/battery during execution.
* **Rollback:** Automatic over time (the OS manages dexopt profiles dynamically with each update).
* **Command for Human to Run in Local Terminal:**
  ```powershell
  # Ensure phone is plugged into charger or PC and battery is >= 50%
  adb -d shell cmd package bg-dexopt-job
  ```
  *(Note: This process runs in the background and may take 5 to 15 minutes. It outputs `Success` when completed).*

---

## 4. UI Smoothness & Touch Responsiveness Optimization

### Action 4.1: Tune System Animation Scales to 0.5x
* **Setting Path:** **Settings → Additional settings → Developer options**
  * **Window animation scale:** Change from `1.0x` to `0.5x`
  * **Transition animation scale:** Change from `1.0x` to `0.5x`
  * **Animator duration scale:** Change from `1.0x` (default) to `0.5x`
* **Original Value:** `1.0x`, `1.0x`, `1.0x`
* **Expected Benefit:** Halves visual transition duration, making app opening, closing, and recents transitions feel instantaneous without dropping display frames.
* **Risk:** None.
* **Rollback:** Set all three scales back to `1.0x`.

### Action 4.2: Enforce 120Hz Refresh Rate (With Battery Impact Evaluation)
* **Setting Path:** **Settings → Display & brightness → Refresh rate**
* **Original Value:** Default (Dynamic / Standard)
* **Expected Benefit:** Locks maximum touch sampling and display fluidity to 120Hz across supported apps.
* **Risk:** Measurable increase in display panel and GPU power draw compared to dynamic 60Hz scaling.
* **Rollback:** Set Refresh Rate back to **Default / Dynamic**.
* **Instruction:** Select **Custom → 120 Hz**. Check the "Apps using high refresh rate" submenu and ensure your primary apps (Chrome, Instagram, Social) are toggled ON.
* **User Execution Strategy:** Test Custom 120 Hz during normal daily use and evaluate real-world battery drain against the default Dynamic profile before deciding to keep it permanently.

### Action 4.3: Tune Touch & Hold Delay
* **Setting Path:** **Settings → Additional settings → Accessibility → Physical → Touch & hold delay**
* **Original Value:** Default (`Medium` or `300 ms`)
* **Expected Benefit:** Sets hold response to `Short` (`250-300 ms`), speeding up long-press gestures, Circle to Search activation, and context menus.
* **Risk:** None.
* **Rollback:** Change back to `Medium`.

### Action 4.4: Stock Launcher & Camera Cache Clearing
* **Setting Path:** **Settings → Apps → Manage apps**
  1. Find **System Launcher** (`com.miui.home`) → **Clear data → Clear cache only** (Do NOT tap clear all data).
  2. Find **Camera** (`com.android.camera`) → **Clear data → Clear cache only**.
* **Original Value:** Accumulated cache from previous OS builds.
* **Expected Benefit:** Clears legacy pre-update shader and layout caches that cause first-launch stutter.
* **Risk:** Zero. Cache re-builds cleanly.
* **Rollback:** N/A.

---

## 5. Selective Notification & Doze Unthrottling (Settings-Only)
*Root Cause from Stage 2:* Instagram, Snapchat, and Facebook are throttled in **Standby Bucket 40 (RARE)** and excluded from Doze whitelist. YouTube (Bucket 10) is constrained by HyperOS background freezing.

### Action 5.1: Configure Background Autostart & Battery Saver for Priority Apps
For each app you need instant notifications from (**Instagram, Snapchat, YouTube, WhatsApp**):
1. **Autostart Authorization:**
   * Go to **Settings → Apps → Manage apps → [App Name] → Autostart (or Background Autostart)** → Toggle **ON**.
2. **Battery Saver Policy:**
   * In the same app page, tap **Battery saver** (PowerKeeper setting).
   * Change from *MIUI / HyperOS Battery Saver (recommended)* to **No restrictions**.
3. **Selective Recents Lock Strategy (Critical for 6 GB RAM with Memory Extension = OFF):**
   * > [!IMPORTANT]
     > On 6 GB physical RAM with virtual Memory Extension disabled, locking 4–5 memory-heavy social apps in Recents simultaneously will pin ~1.5 GB to 2.0 GB of unevictable RSS, starving the foreground Camera and causing app reloads or stutter.
     > **Execution Policy:** Test **Autostart ON + No restrictions** first **without** locking all apps in Recents. Only lock **1–2 truly critical apps** (e.g., WhatsApp or primary messaging) in Recents if notifications still show inconsistency during deep sleep.
   * *Procedure (if needed for top 1–2 apps):* Open the app → swipe up and hold to open Recents → long-press the app card → tap the **Lock (padlock) icon**.

### Action 5.2: Verify Google Play Services Battery Policy
* **Setting Path:** **Settings → Apps → Manage apps → Google Play services → Battery saver**
* **Original Value:** HyperOS Battery Saver or No restrictions
* **Expected Benefit:** Ensures FCM push notification delivery socket stays open during deep sleep.
* **Recommended Setting:** **No restrictions**.
* **Rollback:** Change back to *Battery Saver (recommended)*.

### Action 5.3: Keep Non-Essential Chatty Apps Contained
* For shopping, delivery, streaming, and games (e.g., Flipkart, Amazon, Hotstar, Free Fire India):
  * Keep them on **Battery Saver (recommended)** or **Restrict background apps**.
  * Ensure Autostart is **OFF**.
  * *Benefit:* Preserves 6GB RAM headroom exclusively for your priority apps and camera.

---

## 6. Circle to Search Optimization (Step A — Settings & Core Stack)
*Stage 2 Finding:* Circle to Search is 100% Google-native (`com.google.android.googlequicksearchbox`). It suffers from RAM eviction and network latency.

### Action 6.1: Update Core Google Framework
* **Setting Path:** Google Play Store → Manage apps & device → Updates available
* **Instruction:** Verify and update to the latest versions:
  1. **Google** (`com.google.android.googlequicksearchbox`)
  2. **Google Play services** (`com.google.android.gms`)
  3. **Android System WebView** (`com.google.android.webview`)
* **Expected Benefit:** Resolves known memory leaks and visual search protocol latency on Android 16.

### Action 6.2: Clear Google App Stale Cache & Set No Restrictions
* **Setting Path:** **Settings → Apps → Manage apps → Google**
  1. Tap **Clear data → Clear cache only**.
  2. Tap **Battery saver** → Select **No restrictions**.
  3. Ensure **Autostart** is **ON**.
* **Expected Benefit:** Prevents Google App from being unloaded from memory while switching apps, reducing Circle to Search activation latency from 2s+ down to sub-second.
* **Risk:** Minor RAM usage increase (~150MB RSS).
* **Rollback:** Set Battery Saver back to *Battery Saver (recommended)*.

### Action 6.3: Benchmark Re-timing
* After completing 6.1 and 6.2, repeat the 5x timed Circle to Search test and record the new latency numbers.

---

## 7. Network Latency & Connectivity Tuning (Settings-Only)

### Action 7.1: Connect to 5 GHz Wi-Fi Band
* **Setting Path:** **Settings → Wi-Fi**
* **Context:** Stage 2 ICMP ping showed high latency jitter (48ms to 272ms) characteristic of 2.4 GHz congestion or power-save cycling.
* **Instruction:** Connect to your router's **5 GHz SSID**. If your router uses combined smart connect (single SSID for 2.4/5GHz), temporarily separate them or test in close proximity to the router.
* **Expected Benefit:** Cuts local airtime packet jitter down to <10ms, dramatically speeding up visual search and notification dispatching.

### Action 7.2: Private DNS Benchmark
* **Setting Path:** **Settings → More connectivity options → Private DNS**
* **Original Value:** `Off` / `null`
* **Test Option 1 (Cloudflare 1.1.1.1):** Enter `one.one.one.one`
* **Test Option 2 (Google DNS):** Enter `dns.google`
* **Expected Benefit:** Bypasses sluggish ISP DNS resolvers, encrypts DNS queries via DNS-over-TLS (DoT), and cuts domain resolution latency for app push notifications.
* **Risk:** Certain captive portals (public hotel/airport Wi-Fi) or ad-block networks may fail to resolve until temporarily set back to Off.
* **Rollback:** Select **Off** or **Auto**.

### Action 7.3: Mobile Data Stability Check (5G Auto vs LTE)
* **Setting Path:** **Settings → SIM cards & mobile networks → [Your SIM] → Preferred network type**
* **Original Value:** `Prefer 5G`
* **Assessment:** If you are in an area where 5G signal flaps between NSA 5G and 4G LTE, the baseband modem consumes excessive power (MediaTek Baseband consumed 42.3 mAh in Stage 2) and causes brief data drops.
* **Instruction:** If signal strength is weak (<2 bars on 5G), test toggling to **Prefer LTE** for 24 hours. Compare battery drain and data stability.

---

## 8. Gaming Thermal & Performance Discipline (Free Fire India)
*Candidate Package:* `com.garena.game.ffi` (Free Fire India)

### Action 8.1: Game Turbo Profile Configuration
* **Setting Path:** **Security App → Game Turbo (or Settings → Special features → Game Turbo)**
* **Instruction:**
  1. Add **Free Fire India** to the Game Turbo library.
  2. Open Game Turbo in-game sidebar → Select **Performance Mode**.
  3. Enable **Do Not Disturb (DND)** to block call banners and notification overlays during matches.
  4. In Game Turbo Additional Settings for Free Fire India:
     * Set **Touch response** and **Sensitivity to continuous taps** to maximum.
     * Keep **Aiming precision** at default (prevents artificial interpolation jitter).

### Action 8.2: In-Game Graphics vs Thermal Optimization
* In Free Fire India settings:
  * Set Graphics to **Standard** (or Smooth) and High FPS to **High / Max**.
  * Avoid "Ultra" shadows/filters on a 6GB RAM device: Dimensity GPU frequency throttling kicks in once SoC exceeds 55°C, resulting in sudden frame drops mid-combat.

---

## 9. Xiaomi AI Background Containment (Settings-Only First)
*Packages Covered:* `com.xiaomi.aicr`, `com.xiaomi.aiasst.vision`, and `com.xiaomi.aiservice`  
*Policy:* **Do NOT disable or uninstall.** Mark `com.xiaomi.aiservice` as **KEEP**. Apply Settings-only background containment for `com.xiaomi.aicr` and `aiasst.vision`, and observe for 24 hours.

### Action 9.1: Disable Unused AI Feature Toggles in Settings
* **Setting Path:**
  1. **Settings → Additional settings → AI Services / AI Writing / Smart Suggestions** → Turn OFF unused automated suggestion popups.
  2. **Settings → Additional settings → Smart Clipboard** → Turn OFF (stops `com.xiaomi.aicr` from monitoring clipboard changes continuously).
  3. **Settings → Interconnection (HyperMind / Mi Connect)** → If you do not own Xiaomi tablets or laptops, turn OFF HyperMind learning.

### Action 9.2: Restrict Background Activity for `com.xiaomi.aicr`
* **Setting Path:** **Settings → Apps → Manage apps → (Tap 3 dots → Show all apps) → Search "AICR" (`com.xiaomi.aicr`)**
  1. **Autostart:** Turn **OFF**.
  2. **Permissions:** Review and revoke unnecessary background permissions (Location / Contacts).
  3. **Battery saver:** Change from *No restrictions* to **Restrict background activity** (or *Battery Saver*).
* **Original Value:** Present in User Doze Whitelist, Active background service (~106 MB RSS).
* **Expected Benefit:** Frees ~106 MB of active RAM and eliminates persistent background wakeups without breaking Gallery or Camera.
* **Risk:** Features like AI smart writing suggestions in keyboard and automatic smart clipboard will pause. Gallery photo editing and text OCR remain functional via `com.xiaomi.aiservice`.
* **Rollback:** Turn Autostart back ON and set Battery Saver back to *No restrictions*.

### Action 9.3: 24-Hour Observation Gate
* **Gate Requirement:** Keep this configuration active for 24 hours.
* Verify:
  - [ ] Camera opens smoothly and takes photos without delay
  - [ ] Gallery albums, facial clustering, and text extraction work normally
  - [ ] Battery drain rate during screen-off sleep improves
  - [ ] Circle to Search operates at normal/improved speed

---

## Next Steps
1. Review the plan above.
2. Execute sections 1 through 9 at your own pace (starting with Section 2.3 Memory Extension = OFF and Section 5 Notification fixes).
3. Record your interactive baseline numbers (Camera, CTS, Free Fire 10-min match) when ready.
4. Reply when ready to record outcomes or transition to Stage 4 package auditing.
