# Automated SFTP Sync with WinSCP

![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)
![WinSCP](https://img.shields.io/badge/WinSCP-5C8DBC?style=for-the-badge&logo=windows-terminal&logoColor=white)

A robust PowerShell script for continuous file synchronization between an SFTP server and local directory using WinSCP.

## 📋 Prerequisites

1. **Windows OS** (Tested on Windows 10/11/Server)
2. **PowerShell 5.1+**
3. **WinSCP installed** ([Download here](https://winscp.net/eng/download.php))

## 🛠 Setup Guide

### 1. Install WinSCP
- Download and install WinSCP from [official site](https://winscp.net/eng/download.php)
- During installation:
  - Select "Typical" installation
  - Check "Add WinSCP to PATH" (or note the installation path)

### 2. Locate WinSCP.com
After installation, find `WinSCP.com` (console version) typically at:
```
C:\Program Files (x86)\WinSCP\WinSCP.com
```
Or for current user installs:
```
C:\Users\YOUR_USERNAME\AppData\Local\Programs\WinSCP\WinSCP.com
```

### 3. Generate Connection Code
1. Open WinSCP GUI
2. Create a new session with your SFTP details
3. After successful connection:
   - Go to **Session > Generate Session URL/Code**
   - Select **PowerShell** format
   - Copy the connection code (will look similar to below)

Example generated code:
```powershell
open sftp://user:password@example.com/ -hostkey="ssh-rsa 2048 xxxxxxxxx..."
```

## ⚙️ Configuration

Edit these variables in the script:

```powershell
# Path to WinSCP.com executable
$winscpPath = "C:\Program Files (x86)\WinSCP\WinSCP.com"

# Log file location (single file with rotation)
$logFile = "D:\UI\SyncLog.log"

# Remote and local paths
$remotePath = "/Management/Testing"
$localPath = "D:\UI\"

# Sync interval in seconds
$syncInterval = 30

# Replace this with your generated connection code:
$connectionCode = 'open sftp://Automation:%21%21%25TY23@20.219.193:22/ -hostkey="ssh-ed25519 255 4OfXKvs+uNFlQS/FHBSNJZUI"'
```

## 🚀 How to Use

1. Save the script as `SFTP-Sync.ps1`
2. Run in PowerShell:
   ```powershell
   .\SFTP-Sync.ps1
   ```
3. For background execution:
   ```powershell
   Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"SFTP-Sync.ps1`"" -WindowStyle Hidden
   ```

## 🔍 Logging System

- Single log file with automatic rotation (5MB max)
- Log includes:
  - Timestamped sync cycles
  - Success/failure status
  - Last 5 transferred files
  - Error details

Example log:
```
==== SFTP Sync Log ====
2023-11-15 14:30:00 [SYNC] Starting sync cycle
2023-11-15 14:30:05 [SUCCESS] Sync completed
2023-11-15 14:30:05 [FILES] Last transfers:
Transferring '/Changemanagement/Testing/test1.txt' to 'D:\UI\DRTC\test1.txt'
```

## 🔒 Security Best Practices

1. **Credential Security**:
   - Consider using WinSCP's password manager
   - Or encrypt credentials using PowerShell's secure strings

2. **Host Key Verification**:
   - Always verify the host key fingerprint with your server admin
   - Never disable host key checking

3. **File Permissions**:
   - Store the script in a secure location
   - Set appropriate NTFS permissions

## ❓ Troubleshooting

**Common Issues**:
- **WinSCP not found**: Verify the path to `WinSCP.com`
- **Connection errors**: Check hostkey and network connectivity
- **Permission denied**: Verify SFTP user has read access to remote path

**Verbose Debugging**:
Add `/debug` to the WinSCP command:
```powershell
$output = & $winscpPath /log="$logFile" /ini=nul /debug /command $commandScript 2>&1
```
