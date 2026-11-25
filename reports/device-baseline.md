# Device Baseline Report (Stage 2A)

**Device:** Redmi Note 14 5G (beryl / 24094RAD4I)  
**OS Build:** HyperOS OS3.0.303.0.WOQINXM | Android 16  
**Timestamp:** 2026-11-24T00:25 IST  
**Method:** Non-root ADB read-only via `.\scripts\safe-adb-read.ps1`

---

## 1. Storage Health (`/data`)
* Command: `df -h /data`
* **Total Capacity:** 109 GB
* **Used:** 27 GB (26%)
* **Available:** 81 GB (74% free)
* **Assessment:** Storage headroom is excellent (>20% threshold satisfied). Storage exhaustion is not the cause of current UI or camera latency.

---

## 2. Battery & Charging State
* Command: `dumpsys battery`
* **Battery Level:** 32% (Capacity Level: Normal/3)
* **Health:** Good (Status 2, Health 2)
* **Temperature:** 34.1°C (Idle/charging on 500mA USB)
* **Voltage:** 3835 mV
* **Charge Counter:** 1,609,504 µAh
* **Technology:** Li-poly
* **Power Source:** USB standard rate (500mA @ 5V)

### Battery Drain Summary (`dumpsys batterystats --charged` Top Consumers)
*Logging interval: 2h 22m on battery, 2h 0m screen-on (84.7% active screen time)*
* **Total Computed Drain:** 1461 mAh
  * **Screen:** 310 mAh
  * **CPU Total:** 1008 mAh (Screen-on: 918 mAh, Screen-off: 44.7 mAh)
  * **Mobile Radio / Cell:** 19.8 mAh
  * **Audio / Video / Camera:** ~35 mAh combined

#### Top Power Consumers by Package / UID:
1. **UID 1000 (`android.uid.system`):** **333 mAh** (CPU time: 2h 54m) — System Server, SurfaceFlinger, PowerKeeper, and HyperOS background daemons.
2. **UID 0 (`root / kernel`):** **140 mAh** (CPU time: 1h 18m) — Kernel worker threads, hardware IRQs, and heavy **ZRAM compression/decompression cycles** handling 2.0 GB of swapped app memory.
3. **UID 10342 (`com.whatsapp`):** **53.8 mAh** (Foreground: 13.4 mAh, Foreground Service: 35.5 mAh) — Active chat, media sync, and notification listener.
4. **UID 10334 (`com.instagram.android`):** **47.8 mAh** (Foreground: 32.2 mAh, Background: 10.3 mAh) — Feed rendering and background worker retries.
5. **UID 1082 (`MediaTek Telephony / Carrier Daemon`):** **42.3 mAh** (CPU time: 21m 1s) — Cellular baseband interop and radio signal management.
6. **UID 10145 (`com.google.android.gms`):** **39.1 mAh** (Background: 21.3 mAh, FGS: 14.1 mAh) — Play Services synchronization, location, and FCM transport.
7. **UID 10280 (`com.google.android.providers.media.module`):** **37.9 mAh** (CPU time: 22m 45s) — Media scanning and gallery storage indexing.
8. **UID 10144 (`com.xiaomi.aicr`):** Active background cognition service (`com.xiaomi.aicr:cognitionService`) consuming constant CPU slices.

---

## 3. RAM & LMK Pressure (`dumpsys meminfo`)
* **Total Physical RAM Reported:** 5,609,316 KB (~5.48 GB usable / 6.0 GB hardware)
* **RAM Status:** Normal
* **Used RAM:** 4,786,770 KB (~4.68 GB)
  * Used PSS: 3,374,572 KB
  * Kernel Used: 1,412,198 KB
* **Free RAM:** 3,136,051 KB
  * Cached PSS: 1,020,747 KB
  * Cached Kernel: 2,050,112 KB
  * Pure Free: 65,192 KB (~64 MB)
* **Tuning Limits:** Large 512, OOM threshold 322,560 KB (~315 MB), restore limit 107,520 KB (~105 MB).

### Top RAM Consumers (RSS / PSS Analysis):
1. `system` (PID 1765): 586 MB RSS
2. `com.android.systemui` (PID 3558): 403 MB RSS
3. `com.instagram.android` (PID 24654): 364 MB RSS (Cached PSS: 291 MB)
4. `com.miui.securitycenter.remote` + `com.miui.securitycenter` + UI: Combined ~630 MB RSS across processes
5. `com.google.android.gms` (GMS core + persistent + UI + identitycredentials): Combined ~844 MB RSS
6. `com.miui.home` (PID 9214): 266 MB RSS
7. `com.google.android.googlequicksearchbox` (Google App, interactor, search): Combined ~495 MB RSS
8. `com.whatsapp` (PID 23247): 195 MB RSS

### Key Takeaway for 6GB RAM:
The device has very low pure unreserved free memory (65 MB). Android relies heavily on swapping into ZRAM.

---

## 4. Swap & HyperOS Memory Extension Analysis
* **Total Swap / ZRAM Configured:** 6,291,452 KB (~6.0 GB)
* **ZRAM Physical RAM Occupied:** 647,256 KB (~632 MB)
* **Compressed Data Stored in Swap:** 2,047,956 KB (~2.0 GB)
* **Compression Ratio:** ~3.16:1
* **Memory Extension Status:** **ENABLED (Set to ~6GB virtual RAM)**
* **Performance Impact:**
  * HyperOS Memory Extension allocates a large swap space. While it allows keeping more background apps without instant process killing, compressing and decompressing pages on CPU cores creates I/O bottlenecks and CPU latency spikes when launching heavy apps (like Camera) or switching apps in Recents.
  * This matches Objective 1 ("Recents clear lag and stock Camera cold-start/preview lag on 6GB RAM").

---

## 5. Thermal Baseline (`dumpsys thermalservice`)
* **Thermal Status:** 1 (Light elevation / skin threshold monitoring)
* **HAL Reported Temperatures:**
  * Battery: 33.4°C - 36.6°C
  * Skin: 35.8°C (HAL current) / 44.7°C (peak sensor logged)
  * Power Amplifier: 35.8°C
  * USB Port: 37.0°C
  * SoC / CPU / GPU Core Sensors: ~52.4°C
* **Static Thresholds:**
  * CPU/GPU throttling starts at 85.0°C
  * Battery warning starts at 50.0°C
  * Skin throttling warning starts at 43.0°C - 45.0°C
* **Assessment:** The phone is currently well within safe thermal operational limits.
  * **Root Cause of Idle SoC Temperature (52.4°C):**
    1. **Silicon Junction Sensor:** On MediaTek Dimensity architectures, the SoC/CPU/GPU thermal reporting reflects peak internal silicon junction temperature, not external housing or battery heat.
    2. **Post-Active State:** The device had just completed **2 hours of continuous screen-on time (84.7%)** right before diagnostics commenced.
    3. **Background Media Indexing & ZRAM Activity:** Batterystats confirmed `com.google.android.providers.media.module` was running active CPU cycles (22m), and kernel threads (UID 0) were actively compressing memory into ZRAM.
    4. **Charging State:** Connected to 500mA USB, which activates the battery charge controller (`charger-cooler` level 2).
    5. Exterior skin temperature (35.8°C) and battery temperature (33.4°C - 34.1°C) remained cool and comfortable, confirming no runaway thermal dissipation.

---

## 6. Interactive User Benchmarks (To Fill In)
Please execute these on-device tests and record your observations:

### A. Camera Cold-Start Benchmark (5 Runs)
*Procedure: Clear Camera from Recents, wait 5 seconds, tap Camera icon, measure time until live viewfinder displays clearly without frame drops.*
* Run 1: `_____ s`
* Run 2: `_____ s`
* Run 3: `_____ s`
* Run 4: `_____ s`
* Run 5: `_____ s`
* **Average:** `_____ s`
* **Preview Stutter Observed:** [ ] Yes / [ ] No

### B. Recents Clear Lag
*Procedure: Open 5 apps (Settings, Chrome, Camera, Instagram, WhatsApp), swipe up and hold to open Recents, tap "X" (Clear All).*
* Observed animation stutter or delay: `____________________`
* Time for launcher home icons to fully reappear and accept touch: `_____ s`
