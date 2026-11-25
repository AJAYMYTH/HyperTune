---
name: change-control-and-verify
description: Enforce human-executed single-item change control, zero-risk-first ordering, post-change device regression testing, immediate rollback on degradation, change-log auditing, and post-session security lockdown.
---

# Change Control, Regression Testing & Security Lockdown

## Prerequisites Before ANY Package Change
Verify all four gates are satisfied:
1. External backup confirmed by user (`"backup confirmed"`).
2. Stage 2 baseline reports exist (`device-baseline.md`, `touch-and-network-baseline.md`, `notification-and-gaming-baseline.md`, `ai-and-cts-baseline.md`).
3. Stage 3 zero-risk Settings fixes have been tested and re-measured first (storage >=20% free, `msa`/`System Daemon` revoked, Memory Extension OFF test, ART `bg-dexopt-job`, animations `0.5x`, refresh rate `120Hz`, selective notification/Doze fixes, Circle to Search Step A, Game Turbo).
4. Target package is NOT on the HyperOS bootloop blacklist and is documented in `reports/package-review.csv`.

## Single-Item Change Protocol (Repeat for Every Single Change)
1. **Capture Original State:** Run read-only check via `safe-adb-read.ps1` (e.g., package enabled state or setting value).
2. **Present Change Card:**
   - Target item & original state
   - Purpose & expected measurable gain
   - Risk & known dependencies
   - Exact single command for the **user** to run in their local terminal:
     - Prefer: `adb -d shell pm disable-user --user 0 <pkg>`
     - Last resort only (if disable blocked and verified `OPTIONAL`): `adb -d shell pm uninstall -k --user 0 <pkg>`
   - Exact rollback command:
     - `adb -d shell pm enable --user 0 <pkg>`
     - Or `adb -d shell cmd package install-existing <pkg>`
3. **Wait for Approval & Manual Execution:** Never run write commands from the agent. If user declines, record "Skipped by user" and move on without retrying.
4. **Verify State Read-Only:** Confirm the new state via `safe-adb-read.ps1`.
5. **Run Regression Test Suite** (guide user to verify after EVERY change; NO real financial transactions during testing):
   - [ ] Stock Camera cold-start & preview (no stutter/crash)
   - [ ] Recents open/clear animation & app switching
   - [ ] Circle to Search trigger & timing (mandatory after any AI/Google change)
   - [ ] Battery drain & idle temperature normal
   - [ ] Wi-Fi & 5G/4G mobile data connectivity
   - [ ] Outgoing/incoming call & SMS working
   - [ ] Fingerprint/biometric unlock responsive
   - [ ] Priority notifications arriving on time
   - [ ] System Settings -> About Phone -> HyperOS Updater opens cleanly
   - [ ] Banking / UPI app opens cleanly to login/biometric prompt (do not transact)
6. **Rollback Gate:** If ANY check worsens or breaks, STOP all further changes and instruct the user to run the rollback command immediately, then re-verify.
7. **Audit Log:** Append a redacted entry (timestamp, item, original state, command run, rollback command, before/after metrics, test result, kept/rolled-back status) to `reports/change-log.md`.

## Stage 6: Mandatory Post-Session Security Lockdown
After optimization is complete and stability is verified:
1. Instruct user to unplug the USB cable.
2. Settings -> Additional settings -> Developer options -> **Revoke USB debugging authorizations** -> Confirm.
3. Turn **USB debugging** -> **OFF**.
4. Turn **Developer options** -> **OFF** (warn user that some HyperOS builds reset animation scale to 1x when Developer options is turned off; if a UPI/banking app flags Developer options, keep Developer options OFF).
5. Confirm UPI/banking apps launch cleanly.
6. Write final redacted summary to `reports/final-summary.md` and update `MEMORY.md`.
