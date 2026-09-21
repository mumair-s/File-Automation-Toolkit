# File Automation Toolkit

A small cross-platform scripting project that automates two common file-management tasks:

1. **Backup Manager (PowerShell)**: creates filtered, timestamped backups, preserves folder structure, compresses the backup, and records logs and summary reports.
2. **File Organizer (Bash)**: sorts files in a directory into Documents, Images, Scripts, and Others folders based on file type.

I built these scripts to practice turning repetitive file-management tasks into more structured and repeatable workflows while strengthening my scripting, troubleshooting, validation, logging, and error-handling skills.

## Project Structure

```text
File-Automation-Toolkit/
├── Backup-Manager.ps1
├── organize_files.sh
└── README.md
```

## Backup Manager

### Features

- Validates the source and destination directories.
- Creates a timestamped backup folder.
- Filters `.txt`, `.log`, and `.sh` files.
- Preserves the original subdirectory structure.
- Tracks successful copies and copy errors separately.
- Compresses each backup into a ZIP archive.
- Appends backup history to `backup_log.txt`.
- Generates a latest-run summary in `report.txt`.
- Handles empty backups and missing log/report files cleanly.

### Requirements

- Windows PowerShell 5.1+ or PowerShell 7+

### Usage

```powershell
.\Backup-Manager.ps1
```

Choose **Run Backup** from the menu and enter the source and destination directories when prompted.

> The script creates a backup when run. It does not create a Windows Task Scheduler job automatically.

## File Organizer

### Features

- Validates the target directory.
- Creates category folders automatically.
- Sorts common document, image, and script file types.
- Places unrecognized file types in `Others`.
- Handles uppercase/lowercase extensions.
- Avoids silently overwriting an existing file with the same name.
- Displays a count of files moved into each category.

### Requirements

- Bash on Linux, macOS, WSL, or Git Bash

### Usage

```bash
chmod +x organize_files.sh
./organize_files.sh
```

Enter the directory you want to organize when prompted.

## What I Improved

While revisiting the project, I focused on reliability and clearer output. I corrected backup file-count tracking, fixed the size-unit calculation, made failed file copies visible instead of counting them as successes, preserved backup log history, added empty-backup handling, and improved filename-collision handling in the Bash organizer.

## Skills Demonstrated

- PowerShell and Bash scripting
- Workflow automation
- File-system operations
- Input validation
- Error handling
- Logging and reporting
- Troubleshooting and iterative improvement
