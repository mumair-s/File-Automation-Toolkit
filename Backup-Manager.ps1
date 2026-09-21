# ==========================================
# PowerShell Script - Backup Manager
# ==========================================

$LOG_FILE = Join-Path $PSScriptRoot "backup_log.txt"
$REPORT_FILE = Join-Path $PSScriptRoot "report.txt"
$ALLOWED_EXTENSIONS = @(".txt", ".log", ".sh")

# ==========================================
# 1. User Input & Validation
# ==========================================
function Get-Directories {
    while ($true) {
        $sourceInput = Read-Host "Enter source directory"

        if (Test-Path -LiteralPath $sourceInput -PathType Container) {
            $script:SRC = (Resolve-Path -LiteralPath $sourceInput).Path.TrimEnd('\')
            break
        }

        Write-Output "Invalid source directory. Try again."
    }

    $destinationInput = Read-Host "Enter destination directory"

    if (-not (Test-Path -LiteralPath $destinationInput -PathType Container)) {
        Write-Output "Destination does not exist. Creating..."
        New-Item -ItemType Directory -Path $destinationInput -Force | Out-Null
    }

    $script:DEST = (Resolve-Path -LiteralPath $destinationInput).Path.TrimEnd('\')
}

# ==========================================
# 2. Timestamped Backup Folder
# ==========================================
function Create-BackupFolder {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $script:BACKUP_DIR = Join-Path $DEST "backup_$timestamp"
    New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
}

# ==========================================
# 3. File Filtering & Copying
# ==========================================
function Copy-Files {
    $script:FILE_COUNT = 0
    $script:COPY_ERRORS = 0

    $files = Get-ChildItem -LiteralPath $SRC -Recurse -File -ErrorAction Stop |
        Where-Object { $_.Extension.ToLower() -in $ALLOWED_EXTENSIONS }

    foreach ($file in $files) {
        # Preserve the file's directory structure inside the backup folder.
        $relativePath = $file.FullName.Substring($SRC.Length).TrimStart('\')
        $targetPath = Join-Path $BACKUP_DIR $relativePath
        $targetDir = Split-Path -Parent $targetPath

        if (-not (Test-Path -LiteralPath $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }

        try {
            Copy-Item -LiteralPath $file.FullName -Destination $targetPath -ErrorAction Stop
            $script:FILE_COUNT++
        }
        catch {
            $script:COPY_ERRORS++
            Write-Output "Could not copy: $($file.FullName)"
        }
    }
}

# ==========================================
# 4. Compression
# ==========================================
function Compress-Backup {
    $script:ZIP_PATH = "$BACKUP_DIR.zip"
    Compress-Archive -Path $BACKUP_DIR -DestinationPath $ZIP_PATH -Force -ErrorAction Stop
}

# ==========================================
# 5. Logging System
# ==========================================
function Log-Backup {
    $backupFiles = Get-ChildItem -LiteralPath $BACKUP_DIR -Recurse -File
    $sizeBytes = ($backupFiles | Measure-Object -Property Length -Sum).Sum

    if ($null -eq $sizeBytes) {
        $sizeBytes = 0
    }

    $sizeKB = "{0:N2} KB" -f ($sizeBytes / 1KB)

    Add-Content $LOG_FILE "-----------------------------"
    Add-Content $LOG_FILE "Date: $(Get-Date)"
    Add-Content $LOG_FILE "Source: $SRC"
    Add-Content $LOG_FILE "Backup Folder: $BACKUP_DIR"
    Add-Content $LOG_FILE "Archive: $ZIP_PATH"
    Add-Content $LOG_FILE "Files Copied: $FILE_COUNT"
    Add-Content $LOG_FILE "Copy Errors: $COPY_ERRORS"
    Add-Content $LOG_FILE "Total Size: $sizeKB"
}

# ==========================================
# 6. Report Generation
# ==========================================
function Generate-Report {
    $files = @(Get-ChildItem -LiteralPath $BACKUP_DIR -Recurse -File)
    $totalFiles = $files.Count

    if ($totalFiles -gt 0) {
        $largestFile = $files | Sort-Object Length -Descending | Select-Object -First 1
        $largestFileText = "$($largestFile.Name) ({0:N2} KB)" -f ($largestFile.Length / 1KB)
    }
    else {
        $largestFileText = "N/A"
    }

    $txtCount = @($files | Where-Object { $_.Extension -eq ".txt" }).Count
    $logCount = @($files | Where-Object { $_.Extension -eq ".log" }).Count
    $shCount = @($files | Where-Object { $_.Extension -eq ".sh" }).Count

    Set-Content $REPORT_FILE "=========== BACKUP REPORT ==========="
    Add-Content $REPORT_FILE "Date: $(Get-Date)"
    Add-Content $REPORT_FILE "Source: $SRC"
    Add-Content $REPORT_FILE "Backup Folder: $BACKUP_DIR"
    Add-Content $REPORT_FILE "Archive: $ZIP_PATH"
    Add-Content $REPORT_FILE "Total Files: $totalFiles"
    Add-Content $REPORT_FILE "Copy Errors: $COPY_ERRORS"
    Add-Content $REPORT_FILE "Largest File: $largestFileText"
    Add-Content $REPORT_FILE ".txt files: $txtCount"
    Add-Content $REPORT_FILE ".log files: $logCount"
    Add-Content $REPORT_FILE ".sh files: $shCount"
    Add-Content $REPORT_FILE "====================================="
}

# ==========================================
# Run Full Backup Process
# ==========================================
function Run-Backup {
    try {
        Get-Directories
        Create-BackupFolder
        Copy-Files
        Compress-Backup
        Log-Backup
        Generate-Report

        Write-Output ""
        Write-Output "Backup completed."
        Write-Output "Files copied: $FILE_COUNT"
        Write-Output "Copy errors: $COPY_ERRORS"
        Write-Output "Archive created: $ZIP_PATH"
    }
    catch {
        Write-Output "Backup failed: $($_.Exception.Message)"
    }
}

# ==========================================
# Menu System
# ==========================================
while ($true) {
    Write-Output ""
    Write-Output "===== Backup Manager ====="
    Write-Output "1. Run Backup"
    Write-Output "2. View Logs"
    Write-Output "3. View Latest Report"
    Write-Output "4. Exit"
    Write-Output "=========================="

    $choice = Read-Host "Choose an option"

    switch ($choice) {
        "1" { Run-Backup }
        "2" {
            if (Test-Path -LiteralPath $LOG_FILE) {
                Get-Content -LiteralPath $LOG_FILE
            }
            else {
                Write-Output "No backup log has been created yet."
            }
        }
        "3" {
            if (Test-Path -LiteralPath $REPORT_FILE) {
                Get-Content -LiteralPath $REPORT_FILE
            }
            else {
                Write-Output "No report has been created yet."
            }
        }
        "4" {
            Write-Output "Exiting..."
            exit
        }
        default { Write-Output "Invalid option. Try again." }
    }
}
