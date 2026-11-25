# 🐛 Issue Guidelines — HyperTune

Thank you for helping improve HyperTune! This guide helps you submit clear, actionable issues so maintainers can respond quickly.

---

## 📋 Before Opening an Issue

1. **Search existing issues** — Your problem may already be reported or resolved.
2. **Check the [FAQ](#-frequently-asked-questions)** below for common questions.
3. **Read the [README](README.md)** — Especially the Quick Start Guide and Detailed Technical Diagnoses sections.
4. **Verify your setup** — Ensure ADB is working and you're using the `safe-adb-read.ps1` wrapper.

---

## 🏷️ Issue Types

Use the correct template when opening an issue on GitHub:

### 🐛 Bug Report
Something isn't working as documented.

**Required Information:**
```markdown
### Device Information
- Device Model: [e.g., Redmi Note 14 5G]
- Device Codename: [e.g., beryl]
- HyperOS Version: [e.g., 3.0.303.0.WOQINXM]
- Android Version: [e.g., Android 16]
- RAM: [e.g., 6 GB]

### Environment
- OS: [e.g., Windows 11]
- PowerShell Version: [e.g., 5.1 / 7.4]
- ADB Version: [e.g., 37.0.0]

### Bug Description
A clear and concise description of what the bug is.

### Steps to Reproduce
1. Run command '...'
2. Observe output '...'
3. Expected vs. actual result

### Error Output
```
Paste the exact error message or unexpected output here.
```

### Screenshots / Screen Recordings
If applicable, attach screenshots or recordings.
```

---

### 📱 Device Compatibility Report
You tested HyperTune on a different Xiaomi device and want to share results.

**Required Information:**
```markdown
### Device Information
- Device Model: [e.g., Redmi Note 13 Pro 5G]
- Device Codename: [e.g., garnet]
- HyperOS Version: [e.g., 2.0.x.x]
- Android Version: [e.g., 15]
- SoC: [e.g., Snapdragon 7s Gen 2]
- RAM: [e.g., 8 GB]

### What Worked
- [ ] Stage 1: Pre-Flight & Inventory
- [ ] Stage 2: Read-Only Baselines
- [ ] Stage 3: Zero-Risk Settings Optimization
- [ ] Stage 6: Security Lockdown

### What Didn't Work / Needs Changes
Describe any steps that failed, produced errors, or needed modification.

### Device-Specific Findings
Any unique packages, services, or behaviors specific to your device.

### Baseline Metrics (Before / After)
Share key metrics: RAM pressure, battery drain, notification latency, etc.
```

---

### 💡 Feature Request
You have an idea to improve HyperTune.

**Required Information:**
```markdown
### Feature Description
A clear and concise description of the feature.

### Problem It Solves
What problem does this feature address?

### Proposed Solution
How would you implement this?

### Alternatives Considered
Any alternative approaches you've thought about.

### Device Impact
Which devices / OS versions would benefit?
```

---

### 🔒 Security Vulnerability
> [!CAUTION]
> **DO NOT open a public issue for security vulnerabilities.**
> Follow the [Security Policy](SECURITY.md) and email **ajaymyth@proton.me** directly.

---

## ⚠️ Issue Rules

1. **One issue per report** — Don't combine multiple bugs into one issue.
2. **Be specific** — Vague reports like "it doesn't work" cannot be investigated.
3. **Include device info** — Always state your device model, OS version, and ADB version.
4. **No PII** — Never post real IMEI, serial numbers, MAC addresses, or phone numbers. Use `REDACTED` placeholders.
5. **No dangerous commands** — Don't suggest `pm disable`, `pm uninstall`, or other state-modifying ADB commands as solutions.
6. **Be respectful** — Follow our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## 🏷️ Issue Labels

Maintainers will triage issues with the following labels:

| Label | Description |
|---|---|
| `bug` | Confirmed bug in scripts or documentation |
| `enhancement` | Feature request or improvement |
| `device-report` | New device compatibility report |
| `documentation` | Documentation improvements needed |
| `good first issue` | Beginner-friendly contribution opportunity |
| `help wanted` | Community help needed |
| `duplicate` | Already reported |
| `wontfix` | Out of scope or by design |
| `security` | Security-related (handled privately) |
| `needs-info` | More information needed from reporter |

---

## ❓ Frequently Asked Questions

### "Will this brick my phone?"
**No.** HyperTune uses only read-only ADB diagnostics and Settings-level tuning. Zero system packages are disabled or removed. The framework has a built-in bootloop blacklist to prevent dangerous operations.

### "Does this work on rooted devices?"
HyperTune is designed for **non-rooted** devices. While it may work on rooted devices, we don't test or officially support root-based modifications.

### "Can I use this on Redmi Note 13 / POCO / Mi devices?"
The core diagnostic scripts work on any Xiaomi HyperOS device. However, the Stage 3 optimization plan and bootloop blacklist are currently verified only for the **Redmi Note 14 5G (beryl)**. Device compatibility reports for other models are very welcome!

### "My camera is still slow after optimization."
Camera viewfinder latency on MediaTek Dimensity devices is caused by the ISP hardware pipeline teardown between capture modes. This is a **hardware-level limitation** that cannot be fixed via software. HyperTune's camera settings tuning (Auto HDR OFF, Motion Photo OFF) minimizes the delay but cannot fully eliminate it.

### "My notifications are still delayed."
Ensure you've completed **all** notification steps in the Stage 3 plan:
1. ✅ Set the app to **Autostart ON** in HyperOS settings.
2. ✅ Set the app to **No restrictions** in Battery Saver.
3. ✅ Restart your phone after making changes.
4. ✅ Wait 24 hours for Android Standby Buckets to recalculate.

### "Why not just use a debloating script from XDA?"
Read the [Philosophy section in our README](README.md#-the-philosophy-why-zero-debloat). Blind debloating on HyperOS can cause bootloops, break core features, and void OTA updates. HyperTune proves that all common issues can be resolved without removing a single package.

---

## 🔗 Useful Links

- [README & Quick Start Guide](README.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Stage 3 Optimization Plan](reports/system-optimization-plan.md)
- [Final Summary Report](reports/final-summary.md)

---

*Clear issues lead to fast fixes. Thank you for contributing! — HyperTune 🚀*
