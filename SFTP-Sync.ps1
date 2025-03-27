# Configuration
$winscpPath = "C:\Users\Admin\AppData\Local\Programs\WinSCP\WinSCP.com"
$logFile = "D:\UI\SyncLog.log"  # Single log file
$remotePath = "/Mmanagement/Testing"
$localPath = "D:\UI\"
$syncInterval = 30 # Seconds between sync checks

# Ensure local directory exists
if (-not (Test-Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath -Force | Out-Null
}

# Initialize log file with header
"==== SFTP Sync Log ====" | Out-File $logFile
"Started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -Append $logFile

# Continuous sync loop
while ($true) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp [SYNC] Starting sync cycle" | Out-File -Append $logFile

    try {
        # Build minimal WinSCP command script
        $commandScript = @"
option batch abort
option confirm off
open sftp://Automation:%21%21%25TY23@20.219.193:22/ -hostkey="ssh-ed25519 255 4OfXKvs+uNFlQS/FHBSNJZUI"
synchronize local -transfer=ascii -delete "$localPath" "$remotePath"
exit
"@

        # Execute WinSCP with direct logging
        $output = & $winscpPath /log="$logFile" /ini=nul /command $commandScript 2>&1
        $exitCode = $LASTEXITCODE

        # Minimal logging
        if ($exitCode -eq 0) {
            "$timestamp [SUCCESS] Sync completed" | Out-File -Append $logFile
            # Extract just the transferred files from log
            $transferred = Select-String -Path $logFile -Pattern "Transferring '.*' to" -SimpleMatch | 
                          Select-Object -Last 5
            if ($transferred) {
                "$timestamp [FILES] Last transfers:" | Out-File -Append $logFile
                $transferred.Line | Out-File -Append $logFile
            }
        } else {
            "$timestamp [ERROR] Code $exitCode - $($output[-1])" | Out-File -Append $logFile
        }
    }
    catch {
        "$timestamp [FATAL] $($_.Exception.Message)" | Out-File -Append $logFile
    }

    # Rotate log if too large (>5MB)
    if ((Get-Item $logFile).Length -gt 5MB) {
        $archiveLog = "D:\UI\DRTC\SyncLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        Move-Item $logFile $archiveLog -Force
        "==== Log rotated - New log started ====" | Out-File $logFile
    }

    Start-Sleep -Seconds $syncInterval
}
