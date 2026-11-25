---
name: external-backup-guide
description: Guide the user through creating and verifying a copy-only phone media backup OUTSIDE the Antigravity workspace and outside OneDrive, and generate reports/backup-checklist.md for non-ADB app data.
---

# External Backup Guide

## Core Security Rules
- Phone backups MUST live OUTSIDE the Antigravity workspace folder (e.g., `D:\PhoneBackups\RedmiNote14\<YYYY-MM-DD>`) and OUTSIDE OneDrive-synced directories (`Desktop`, `Documents`, `Pictures`).
- Never access, scan, or read personal media folders from inside the agent.
- Never move or delete files on the phone during backup. Copy-only.
- Never claim `adb pull` is a full phone backup (it does NOT back up app-private data, banking tokens, WhatsApp encryption keys, or Authenticator seeds).
- Never mark backup complete until counts, sizes, zero-byte checks, and manual sample-file open checks pass.

## Workflow
1. Check local free disk space on the user's target backup drive (or ask user to verify they have >= 1.5x the phone's used `/data` size free).
2. Provide exact copy-only commands for the user to run in their OWN local Windows PowerShell terminal:
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
   Note: If any folder is large or stalls over `adb pull` on Windows, advise copying that folder via USB MTP/File Transfer and still running verification.
3. Instruct the user to run the local verification script from their own terminal:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\verify-backup.ps1 -BackupDir "D:\PhoneBackups\RedmiNote14\<YYYY-MM-DD>"
   ```
4. Write `reports/backup-checklist.md` containing manual checklists for data ADB cannot back up:
   - [ ] Contacts synced to Google/exported to `.vcf`
   - [ ] WhatsApp encrypted chat backup completed & verified
   - [ ] SMS/Call log backup (if needed)
   - [ ] 2FA / Authenticator apps (Google/Microsoft/Authy) recovery codes saved offline
   - [ ] Passkeys & Password Manager synced and recovery phrase verified
   - [ ] Google Photos sync status verified
   - [ ] Google & Xiaomi account recovery email/phone verified
   - [ ] UPI & Banking apps: SIM active in slot, debit card/UPI PIN recovery notes ready in case re-login is triggered
   - [ ] Backup verification script passed (counts match, 0 unexpected zero-byte files)
   - [ ] 3+ random photos/videos/PDFs manually opened from the backup folder and confirmed intact
5. STOP and wait for the user to explicitly reply `"backup confirmed"` before proceeding to any optimization or package changes.
