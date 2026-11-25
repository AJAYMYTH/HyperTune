# Touch & Network Baseline Report (Stage 2B)

**Device:** Redmi Note 14 5G (beryl / 24094RAD4I)  
**OS Build:** HyperOS OS3.0.303.0.WOQINXM | Android 16  
**Timestamp:** 2026-11-24T00:25 IST  
**Method:** Non-root ADB read-only via `.\scripts\safe-adb-read.ps1`

---

## 1. Display & Touch Latency Configuration
* **Peak Refresh Rate:** `120 Hz` (`settings get system peak_refresh_rate` = 120)
* **Minimum Refresh Rate:** `null` (Dynamic / adaptive panel scaling handled by HyperOS framework)
* **Battery Saver State:** `0` (Disabled — not throttling refresh rate or touch polling)
* **Touch & Hold Delay (`long_press_timeout`):** `300 ms` (Standard default; can be tuned or checked against accessibility settings)
* **Animation Scales:**
  * Window Animation Scale: `1.0x`
  * Transition Animation Scale: `1.0x`
  * Animator Duration Scale: `null` (Android 1.0x default)

### Touch Latency Analysis:
* The panel is running at 120Hz maximum, but adaptive refresh drops frame rates aggressively when idle or within certain apps (Camera, YouTube, Google Maps).
* Animation scale at 1.0x contributes to perceived UI lag on HyperOS with 6GB RAM, where frame transitions wait for system rendering pipelines.
* Hardware factors to verify with user: Screen protector thickness, tempered glass oleophobic wear, and case bezel lip interfering with edge gestures.

---

## 2. Network Latency & DNS Configuration
* **Private DNS Mode:** `null` (Default opportunistic / system resolver)
* **Private DNS Specifier:** `null` (No custom DoT/DoH resolver configured)
* **Data Saver:** Disabled

### Read-Only ICMP Ping Baselines (Redacted Summary):
*Target: 1.1.1.1 (Cloudflare Anycast)*
* Transmitted: 5, Received: 5, Packet Loss: 0%
* RTT Min: `48.0 ms`
* RTT Avg: `161.6 ms`
* RTT Max: `272.6 ms`
* RTT Jitter (mdev): `95.5 ms`
* *Observation:* High latency variance (48ms to 272ms) indicates Wi-Fi channel power-saving mode (WMM-PS / 802.11 DTIM sleep) or RF congestion on 2.4 GHz band.

*Target: 8.8.8.8 (Google Anycast)*
* Transmitted: 5, Received: 5, Packet Loss: 0%
* RTT Min: `46.3 ms`
* RTT Avg: `114.8 ms`
* RTT Max: `268.2 ms`
* RTT Jitter (mdev): `79.8 ms`
* *Observation:* Similar jitter pattern confirming Wi-Fi sleep-wake cycle or interface power management rather than destination routing.

---

## 3. Interactive Touch & Network Verification (To Complete)

### A. Touch Latency & Physical Inspection Check
1. **Screen Protector:** Are you using a thick tempered glass or matte film? `[Yes / No]`
2. **Case:** Does the phone case have raised lips touching the curved/flat glass edges? `[Yes / No]`
3. **Pointer Location Test:**
   * Go to **Settings → Additional settings → Developer options → Pointer Location** (temporary toggle).
   * Drag your finger smoothly in a diagonal zigzag.
   * Do you notice tracking line breaks, jumps, or lag behind your fingertip? `[Smooth / Jumpy / Noticeable Lag]`
   * *(Turn Pointer Location OFF after testing).*

### B. Speed Test Comparison (Wi-Fi vs Mobile Data)
*Run 3 tests on fast.com or Speedtest app:*
* **Wi-Fi (Band: 2.4GHz / 5GHz):**
  * Test 1: Ping `___ ms`, Down `___ Mbps`, Up `___ Mbps`
  * Test 2: Ping `___ ms`, Down `___ Mbps`, Up `___ Mbps`
  * Test 3: Ping `___ ms`, Down `___ Mbps`, Up `___ Mbps`
* **Mobile Data (5G / 4G LTE):**
  * Test 1: Ping `___ ms`, Down `___ Mbps`, Up `___ Mbps`
  * Test 2: Ping `___ ms`, Down `___ Mbps`, Up `___ Mbps`
  * Test 3: Ping `___ ms`, Down `___ Mbps`, Up `___ Mbps`
