# 🤝 Contributing to HyperTune

Thank you for your interest in making HyperTune better! Whether you're fixing a typo, adding support for a new Xiaomi device, improving diagnostic scripts, or writing documentation — every contribution matters.

---

## 📋 Table of Contents

- [Code of Conduct](#-code-of-conduct)
- [How Can I Contribute?](#-how-can-i-contribute)
- [Getting Started](#-getting-started)
- [Development Setup](#-development-setup)
- [Safety Rules (MANDATORY)](#-safety-rules-mandatory)
- [Pull Request Process](#-pull-request-process)
- [Commit Message Convention](#-commit-message-convention)
- [Issue Guidelines](#-issue-guidelines)
- [Device Report Template](#-device-report-template)
- [Style Guide](#-style-guide)

---

## 📜 Code of Conduct

This project follows our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold a respectful and inclusive community.

---

## 💡 How Can I Contribute?

### 🐛 Report Bugs
- Found a script error or incorrect diagnostic output? [Open an issue](../../issues/new?template=bug_report.md).
- Include your device model, HyperOS version, and the exact error output.

### 📱 Add Device Support
- Own a different Xiaomi HyperOS device? Run the diagnostics and submit your baselines!
- Create a new device profile under a `devices/<codename>/` directory.

### 📝 Improve Documentation
- Fix typos, clarify instructions, or translate docs into other languages.
- Improve the technical diagnoses with additional forensic evidence.

### 🔧 Enhance Scripts
- Improve `safe-adb-read.ps1` with better PII redaction patterns.
- Add new read-only diagnostic commands to the allowed list.
- Port scripts to Bash/Zsh for macOS and Linux users.

### 🧪 Verify Optimization Steps
- Test the Stage 3 optimization plan on your device and report results.
- Provide before/after battery stats, RAM metrics, or screen recordings.

---

## 🚀 Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/HyperTune.git
   cd HyperTune
   ```
3. **Create a branch** for your contribution:
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. Make your changes, test them, and commit.
5. **Push** your branch and open a Pull Request.

---

## 🛠️ Development Setup

### Prerequisites
- Windows 10 / 11 with PowerShell 5.1 or PowerShell 7+
- Android SDK Platform-Tools (`adb`) on your system `PATH`
- Git installed and configured

### Verify Your Setup
```powershell
# Check ADB is available
adb version

# Check PowerShell version
$PSVersionTable.PSVersion

# Test the safe wrapper (with a device connected)
powershell -ExecutionPolicy Bypass -File .\scripts\safe-adb-read.ps1 devices
```

---

## 🛡️ Safety Rules (MANDATORY)

> [!CAUTION]
> **Every contribution MUST comply with these non-negotiable safety rules.** Pull requests that violate any of these will be rejected immediately.

### 1. Read-Only ADB Only
- All diagnostic commands **must** go through `scripts/safe-adb-read.ps1`.
- **NEVER** include raw `adb shell` commands that modify device state.
- **NEVER** add `pm disable`, `pm uninstall`, `settings put`, `setprop`, or `appops set` to any script.

### 2. Respect the Bootloop Blacklist
- Do not recommend disabling, uninstalling, or clearing data on any package listed in the [Bootloop Blacklist](README.md#️-core-safety-guardrails--blacklist).
- If adding a new device profile, include device-specific blacklisted packages.

### 3. Privacy First
- **NEVER** commit real IMEI, serial numbers, MAC addresses, phone numbers, or email addresses.
- Use placeholder values: `REDACTED_IMEI`, `XX:XX:XX:XX:XX:XX`, `+91-XXXX-XXXXXX`.
- Ensure PII redaction works correctly if modifying `safe-adb-read.ps1`.

### 4. No Root Required
- All scripts and instructions must work on **non-rooted** devices.
- Do not assume `su`, Magisk, or custom recovery access.

### 5. Test Before Submitting
- Run your scripts against a real device or verify with mock output.
- Ensure no regressions in PII redaction or command blocking.

---

## 🔄 Pull Request Process

1. **Ensure** your code follows the [Safety Rules](#-safety-rules-mandatory) above.
2. **Update** documentation if your change affects user-facing behavior.
3. **Test** your changes on a real device (preferred) or with documented mock data.
4. **Fill out** the PR template completely:
   - What does this PR do?
   - What device/OS was it tested on?
   - Does it comply with all safety rules? (Checklist)
5. **Request a review** from a maintainer.
6. **Address feedback** promptly and push fixes to the same branch.

### PR Checklist
- [ ] No raw ADB write commands added
- [ ] Bootloop blacklist respected
- [ ] No PII in committed files
- [ ] Works on non-rooted devices
- [ ] Documentation updated (if applicable)
- [ ] Tested on a real device (state which device and OS version)

---

## 📝 Commit Message Convention

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

### Types
| Type | Description |
|---|---|
| `feat` | New feature or device support |
| `fix` | Bug fix in scripts or documentation |
| `docs` | Documentation-only changes |
| `refactor` | Code restructuring without behavior change |
| `test` | Adding or updating test scripts |
| `chore` | Maintenance, CI/CD, or build changes |
| `security` | Security-related fixes or improvements |

### Examples
```
feat(scripts): add Linux/macOS bash port of safe-adb-read
fix(redaction): handle IPv6 addresses in PII scrubber
docs(readme): add Redmi Note 13 Pro device profile
security(wrapper): block additional state-modifying ADB subcommands
```

---

## 📋 Issue Guidelines

When opening an issue, please use the appropriate template:

- **🐛 Bug Report:** Script errors, incorrect diagnostics, PII leaks
- **📱 Device Report:** New device baselines and optimization results
- **💡 Feature Request:** New diagnostic commands, script improvements, platform ports
- **❓ Question:** General questions about the optimization workflow

Include as much detail as possible:
- Device model, codename, and HyperOS/Android version
- Exact error messages or unexpected output
- Steps to reproduce the issue

---

## 📱 Device Report Template

Adding support for a new device? Create a directory and include:

```
devices/<codename>/
├── device-info.md        # Model, SoC, RAM, storage, OS version
├── baselines/            # Stage 2 diagnostic outputs
├── optimization-plan.md  # Device-specific Stage 3 steps
└── blacklist.md          # Device-specific bootloop-critical packages
```

---

## 🎨 Style Guide

### Markdown
- Use ATX-style headers (`#`, `##`, `###`).
- Use fenced code blocks with language identifiers (````powershell`, ````bash`, ````text`).
- Use tables for structured data comparisons.
- Use emoji sparingly for section headers only (not inline).

### PowerShell Scripts
- Use `PascalCase` for function names and parameters.
- Include comment-based help (`<# .SYNOPSIS ... #>`) for all functions.
- Use `Write-Host` with color for user-facing output; `Write-Verbose` for debug.
- Always include `-ErrorAction Stop` for critical operations.

### Reports
- Begin with a YAML-style metadata header (device, date, stage).
- Use consistent metric formatting (e.g., `5.48 GB`, `120 Hz`, `33.4°C`).
- Include `✅`, `⚠️`, or `❌` status indicators for pass/warn/fail results.

---

## 🙏 Thank You

Every contribution — from a one-line typo fix to a full device profile — helps the Xiaomi community optimize their phones safely. We appreciate your time and expertise!

---

*Built with care by the HyperTune community. 🚀*
