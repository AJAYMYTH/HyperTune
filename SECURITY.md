# 🔒 Security Policy — HyperTune

> **HyperTune** takes device safety extremely seriously. This framework is specifically engineered to be **non-destructive**, **read-only**, and **zero-risk** to your Redmi Note 14 5G.

---

## 🛡️ Built-In Security Architecture

HyperTune enforces the following security boundaries by design:

| Layer | Protection |
|---|---|
| **ADB Wrapper** | All commands routed through `scripts/safe-adb-read.ps1` — blocks shell chaining, command injection, and state-modifying subcommands. |
| **PII Redaction** | Real-time local regex scrubbing of IMEI, serial numbers, MAC addresses, IP addresses, phone numbers, and email addresses before terminal display. |
| **Bootloop Blacklist** | 15+ critical HyperOS and Android packages are **absolutely blacklisted** from disable, uninstall, or data-clear operations. |
| **Zero Package Removal** | The framework achieves all optimizations through Settings-level tuning — **0 system packages are disabled or removed**. |
| **Post-Session Lockdown** | Stage 6 protocol mandates USB debugging revocation, Developer Options disable, and UPI/banking app verification. |

---

## 📋 Supported Versions

| Version | Device | OS | Supported |
|---|---|---|---|
| `1.0.x` | Redmi Note 14 5G (beryl) | HyperOS 3.0 / Android 16 | ✅ Fully supported |
| Future | Other Xiaomi HyperOS devices | HyperOS 2.x / 3.x | 🔜 Community contributions welcome |

---

## 🚨 Reporting a Vulnerability

If you discover a security vulnerability in HyperTune's scripts, safety guardrails, or PII redaction logic, please report it responsibly:

### How to Report

1. **DO NOT** open a public GitHub issue for security vulnerabilities.
2. **Email:** Send a detailed report to **[contact.javaliajayakumar@gmail.com](mailto:contact.javaliajayakumar@gmail.com)** with the subject line: `[HyperTune Security] <Brief Description>`.
3. **Include:**
   - A clear description of the vulnerability.
   - Steps to reproduce the issue.
   - The potential impact on user devices or data.
   - Any suggested fix or mitigation.

### Response Timeline

| Action | Timeline |
|---|---|
| Acknowledgment of your report | Within **48 hours** |
| Initial assessment and triage | Within **5 business days** |
| Fix development and testing | Within **14 business days** |
| Public disclosure (after fix is merged) | Coordinated with reporter |

### What Qualifies as a Security Issue

- ✅ Bypass of the read-only ADB wrapper (`safe-adb-read.ps1`)
- ✅ Failure of PII redaction (IMEI, serial, MAC, phone number leaking to terminal or logs)
- ✅ Commands that could inadvertently modify device state (disable packages, change settings)
- ✅ Bootloop blacklist bypass or missing critical packages
- ✅ Script injection or shell escape vulnerabilities

### What Does NOT Qualify

- ❌ Feature requests or enhancement suggestions (use [GitHub Issues](../../issues))
- ❌ Questions about device optimization steps (use [GitHub Discussions](../../discussions))
- ❌ Issues caused by user deviation from the documented workflow

---

## 🔐 Security Best Practices for Users

When using HyperTune on your device:

1. **Always complete Stage 6 (Security Lockdown)** after finishing optimization.
2. **Never leave USB debugging enabled** when not actively using this framework.
3. **Revoke USB debugging authorizations** after every session.
4. **Store backups on external drives** — never in cloud-synced or workspace directories.
5. **Verify your UPI and banking apps** launch cleanly after any changes.
6. **Do not run raw `adb` commands** outside the `safe-adb-read.ps1` wrapper.

---

## 🏆 Hall of Fame

We gratefully acknowledge security researchers who help keep HyperTune safe:

*No reports yet — be the first!*

---

*Security is not a feature; it's a foundation. — HyperTune*
