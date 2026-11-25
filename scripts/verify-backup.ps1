# scripts/verify-backup.ps1
# Verifies an EXTERNAL phone media backup folder (counts, sizes, zero-byte check,
# phone count comparison, and random sample files for manual open-check).
# Run this script manually in your own PowerShell terminal.

param(
    [Parameter(Mandatory = $true)]
    [string]$BackupDir,

    [switch]$ShowSamplePaths
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $BackupDir)) {
    Write-Error "Backup directory does not exist: $BackupDir"
    exit 1
}

$resolvedBackup = (Resolve-Path -LiteralPath $BackupDir).Path
$workspaceRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path

# Safety check: backup must NOT live inside the Antigravity workspace
if ($resolvedBackup.StartsWith($workspaceRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    Write-Warning "SECURITY WARNING: Your backup folder is INSIDE the Antigravity workspace!"
    Write-Warning "Move it outside (e.g., D:\PhoneBackups\RedmiNote14) so the AI agent cannot access personal media."
}

$folders = @("DCIM", "Pictures", "Movies", "Download", "Documents", "Music", "Recordings")
$adbAvailable = $null -ne (Get-Command adb -ErrorAction SilentlyContinue)
$phoneConnected = $false

if ($adbAvailable) {
    $devOut = (& adb devices 2>&1 | Out-String)
    $deviceLines = ($devOut -split "`r?`n") | Where-Object { $_ -match '\s+device$' }
    if ($deviceLines.Count -eq 1) {
        $phoneConnected = $true
    }
}

Write-Host "=== External Backup Verification Report ===" -ForegroundColor Cyan
Write-Host ("Timestamp       : {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
Write-Host ("Phone connected : {0}" -f $phoneConnected)
Write-Host ""

$totalLocalFiles = 0
$totalLocalBytes = [int64]0
$totalZeroByte = 0
$allNonEmptyFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]

$rows = @()
foreach ($folder in $folders) {
    $localPath = Join-Path $resolvedBackup $folder
    $localCount = 0
    $localBytes = [int64]0
    $zeroCount = 0

    if (Test-Path -LiteralPath $localPath) {
        $files = @(Get-ChildItem -LiteralPath $localPath -File -Recurse -ErrorAction SilentlyContinue)
        $localCount = $files.Count
        foreach ($f in $files) {
            $localBytes += $f.Length
            if ($f.Length -eq 0) {
                $zeroCount++
            } else {
                $allNonEmptyFiles.Add($f)
            }
        }
    }

    $phoneCountStr = "N/A"
    $status = "LOCAL_ONLY"
    if ($phoneConnected) {
        $rawCount = (& adb -d shell "if [ -d /sdcard/$folder ]; then find /sdcard/$folder -type f 2>/dev/null | wc -l; else echo 0; fi" 2>$null | Out-String).Trim()
        if ($rawCount -match '^\d+$') {
            $phoneCount = [int]$rawCount
            $phoneCountStr = "$phoneCount"
            if ($localCount -eq $phoneCount) {
                $status = "MATCH"
            } elseif ($localCount -gt $phoneCount) {
                $status = "MORE_LOCAL"
            } else {
                $status = "MISMATCH_CHECK"
            }
        } else {
            $status = "PHONE_READ_ERR"
        }
    }

    $totalLocalFiles += $localCount
    $totalLocalBytes += $localBytes
    $totalZeroByte += $zeroCount

    $rows += [PSCustomObject]@{
        Folder      = $folder
        LocalFiles  = $localCount
        PhoneFiles  = $phoneCountStr
        SizeMB      = [math]::Round($localBytes / 1MB, 2)
        ZeroByte    = $zeroCount
        Status      = $status
    }
}

$rows | Format-Table -AutoSize

Write-Host ("Total Local Files : {0}" -f $totalLocalFiles)
Write-Host ("Total Size        : {0} GB ({1} MB)" -f [math]::Round($totalLocalBytes / 1GB, 2), [math]::Round($totalLocalBytes / 1MB, 2))
Write-Host ("Zero-Byte Files   : {0}" -f $totalZeroByte)
Write-Host ""

if ($allNonEmptyFiles.Count -gt 0) {
    Write-Host "=== Manual Sample-Open Check (Open 3 files yourself to confirm integrity) ===" -ForegroundColor Yellow
    $sampleCount = [math]::Min(3, $allNonEmptyFiles.Count)
    $samples = Get-Random -InputObject $allNonEmptyFiles -Count $sampleCount
    $idx = 1
    foreach ($s in $samples) {
        if ($ShowSamplePaths) {
            Write-Host ("  [{0}] {1} ({2} KB)" -f $idx, $s.FullName, [math]::Round($s.Length / 1KB, 1))
        } else {
            $relFolder = ($s.DirectoryName.Substring($resolvedBackup.Length)).TrimStart('')
            Write-Host ("  [{0}] Folder: {1} | Ext: {2} | Size: {3} KB (re-run with -ShowSamplePaths to display exact paths locally)" -f $idx, $relFolder, $s.Extension, [math]::Round($s.Length / 1KB, 1))
        }
        $idx++
    }
} else {
    Write-Warning "No non-empty files found in the backup directory!"
}

Write-Host ""
Write-Host "Reminder: adb pull only copies shared storage (/sdcard). Complete reports/backup-checklist.md for WhatsApp, Authenticator, Passkeys, Contacts, and Banking/UPI before typing 'backup confirmed'." -ForegroundColor Green
