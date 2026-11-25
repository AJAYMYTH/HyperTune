# scripts/safe-adb-read.ps1
# Deterministic read-only ADB wrapper with local PII redaction.
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AdbArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not $AdbArgs -or $AdbArgs.Count -eq 0) {
    Write-Error "No ADB arguments provided."
    exit 1
}

$joined = ($AdbArgs -join " ").Trim()

# 1. Block shell chaining, subshells, piping, and redirection
if ($joined -match '[;&|><`$]') {
    Write-Error "BLOCKED: Shell chaining, piping, or redirection characters are not allowed."
    exit 1
}

# 2. Block all write, state-modifying, file-transfer, and privileged commands
$blockedPattern = '(?i)(^|\s)(uninstall|disable|disable-user|enable|hide|unhide|clear|put|setprop|push|pull|install|install-existing|install-multiple|reboot|root|unroot|remount|fastboot|sideload|wipe|rm|mv|cp|chmod|chown|delete|force-stop|kill|kill-all|revoke|grant|bugreport|backup|restore|tcpip|connect|pair)(\s|$)'
if ($joined -match $blockedPattern) {
    Write-Error "BLOCKED: Write, transfer, or privileged command rejected by read-only guard."
    exit 1
}

$blockedSubcommands = '(?i)\b(appops\s+set|device_config\s+(put|delete|reset)|settings\s+(put|delete)|cmd\s+package\s+(uninstall|compile|bg-dexopt-job|install|clear)|cmd\s+netpolicy\s+set|am\s+(start|broadcast|force-stop|kill|set-standby-bucket)|pm\s+(clear|disable|disable-user|enable|uninstall|install|grant|revoke|hide|unhide|trim-caches))\b'
if ($joined -match $blockedSubcommands) {
    Write-Error "BLOCKED: State-modifying Android subcommand rejected by read-only guard."
    exit 1
}

# 3. Block bare 'getprop'
if ($joined -match '(?i)\bgetprop\s*$') {
    Write-Error "BLOCKED: Bare 'getprop' is not allowed. Request one safe property key."
    exit 1
}

# 4. Block high-PII dumpsys targets
$piiDumpsys = '(?i)\bdumpsys\s+(notification|account|telecom|telephony\.registry|sms|isms|wifi|connectivity|location|clipboard|contacts|usagestats|phone|iphonesubinfo)\b'
if ($joined -match $piiDumpsys) {
    Write-Error "BLOCKED: High-PII dumpsys target rejected."
    exit 1
}

# 5. Verify adb exists
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    Write-Error "ADB not found in PATH."
    exit 1
}

# 6. Execute read-only ADB command
$rawOutput = (& adb @AdbArgs 2>&1 | Out-String)
$exitCode = $LASTEXITCODE

# 7. Redact PII locally BEFORE stdout reaches the AI agent
$clean = $rawOutput `
    -replace '([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})', '[REDACTED_EMAIL]' `
    -replace '\b([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})\b', '[REDACTED_MAC]' `
    -replace '\b(?:\d{1,3}\.){3}\d{1,3}\b', '[REDACTED_IP]' `
    -replace '\+\d{1,3}[\s-]?\d{8,12}\b', '[REDACTED_PHONE]' `
    -replace '\b\d{15}\b', '[REDACTED_IMEI]' `
    -replace '(?i)(\[?(?:ro\.serialno|ro\.boot\.serialno|ril\.serialnumber|persist\.sys\.miui\.imei|ro\.ril\.miui\.imei\d*|SSID|BSSID|imei|imsi|iccid|line1number|android_id)\]?\s*[:=]\s*)\[?[^\]\r\n,;]+\]?', '$1[REDACTED]' `
    -replace '(?m)^[a-zA-Z0-9]{6,24}(\s+(device|unauthorized|offline)\b)', '[REDACTED_SERIAL]$1'

Write-Output $clean
exit $exitCode