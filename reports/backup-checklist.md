# External Backup Checklist — Redmi Note 14 5G

**Date:** 2026-11-24
**Backup destination:** `D:\PhoneBackups\RedmiNote14\2026-11-24\`
**Device:** Redmi Note 14 5G (beryl) | 109 GB total, 27 GB used, 81 GB free

> [!CAUTION]
> Do NOT proceed to any optimization stage until every item below is checked and you reply **"backup confirmed"**.

---

## Part A — Media & File Backup via ADB Pull

**Prerequisites:**
- Ensure drive `D:\` has at least **40 GB free** (1.5× phone used space)
- Keep phone plugged in via USB in **File Transfer / MTP** mode

**Run these commands in YOUR OWN PowerShell terminal** (not the agent terminal):

```powershell
$date = Get-Date -Format "yyyy-MM-dd"
$dest = "D:\PhoneBackups\RedmiNote14\$date"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$folders = @("DCIM", "Pictures", "Movies", "Download", "Documents", "Music", "Recordings")
foreach ($f in $folders) {
    Write-Host "Backing up /sdcard/$f ..."
    adb -d pull -a "/sdcard/$f" "$dest\$f"
}
```

> [!TIP]
> If any folder stalls or is very large (>5 GB), copy that specific folder via **Windows File Explorer** (phone appears as MTP device) instead, then continue the script for remaining folders.

---

## Part B — Verify Backup Integrity

After the copy completes, run from the REDMI-Optimize workspace root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\verify-backup.ps1 -BackupDir "D:\PhoneBackups\RedmiNote14\2026-11-24"
```

If the script doesn't exist yet, manually verify:
- [ ] Compare file/folder counts between phone and backup (spot-check each folder)
- [ ] Check for unexpected zero-byte files: `Get-ChildItem -Recurse "D:\PhoneBackups\RedmiNote14\2026-11-24" | Where-Object { $_.Length -eq 0 }`
- [ ] Open 3+ random photos from the backup and confirm they display correctly
- [ ] Open 1+ random video and confirm it plays
- [ ] Open 1+ random PDF/document and confirm it opens

---

## Part C — Data That ADB Pull CANNOT Back Up

> [!WARNING]
> `adb pull` copies only files on shared storage (`/sdcard/`). It does **NOT** back up app-private data, encryption keys, banking tokens, 2FA seeds, or app login sessions. You MUST handle these manually.

### Critical Manual Backup Items

- [ ] **Contacts** — Verify synced to Google account, OR export to `.vcf`:
  Phone → Contacts → ⋮ menu → Import/Export → Export to `.vcf` file → copy to backup folder

- [ ] **WhatsApp encrypted chat backup** — WhatsApp → Settings → Chats → Chat backup → Back up now. Verify backup completed successfully. Note: encryption key is tied to your Google account.

- [ ] **SMS / Call log backup** (if you need these) — Use Google One backup OR a trusted app to export

- [ ] **2FA / Authenticator recovery:**
  - [ ] Google Authenticator — Settings → Transfer accounts → Export accounts (screenshot QR codes to secure offline location, NOT cloud), OR ensure cloud sync is ON in Google Authenticator settings
  - [ ] Any other authenticator app — save recovery codes offline

- [ ] **Passkeys & Password Manager** — Verify your Google Password Manager / other password manager is synced and you have the recovery phrase saved offline

- [ ] **Google Photos sync** — Open Google Photos → verify recent photos/videos show the cloud ☁️ checkmark (uploaded), not just device-only

- [ ] **Google account recovery** — Verify at myaccount.google.com that your recovery email and recovery phone number are current

- [ ] **Xiaomi account** — Settings → Xiaomi Account → verify recovery email/phone. Enable Xiaomi Cloud sync for Contacts/Notes if desired.

- [ ] **UPI & Banking apps readiness:**
  - [ ] Confirm your SIM is active in the correct slot
  - [ ] Note down your UPI PIN recovery method (linked bank, debit card last 4 digits)
  - [ ] Google Pay, Kotak 811, Groww, Tradebook — these may require re-login/re-verification if app data is cleared (we will NOT clear these, but prepare just in case)
  - [ ] Keep your registered mobile number and debit card ready

---

## Part D — Final Confirmation

After completing Parts A, B, and C:

- [ ] All media folders copied and verified
- [ ] Zero-byte check passed
- [ ] 3+ random files manually opened and confirmed intact
- [ ] Contacts synced or exported
- [ ] WhatsApp backup completed
- [ ] 2FA recovery codes saved
- [ ] Google/Xiaomi account recovery info verified
- [ ] UPI/Banking readiness confirmed

**→ When all items are checked, reply "backup confirmed" to proceed to Stage 2.**
