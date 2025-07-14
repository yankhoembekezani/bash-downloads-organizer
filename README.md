[![Shell Script](https://img.shields.io/badge/Bash-4.0+-blue?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/github/license/yankhoembekezani/bash-downloads-organizer)](https://github.com/yankhoembekezani/bash-downloads-organizer/blob/main/LICENSE)
[![Maintained](https://img.shields.io/badge/Maintained-yes-brightgreen.svg)](https://github.com/yankhoembekezani/bash-downloads-organizer)


# Bash Downloads Organizer

A robust and safe Bash script that organizes your downloads folder — with undo, dry-run mode, conflict resolution, and full logging.


---

## Features

- Categorizes files into predefined groups: PDFs, Images, Archives, ISO files, Others  
- Dry-run mode to preview actions without modifying files  
- Structured logging with timestamps, log levels, and detailed messages  
- Automatically creates destination folders if missing  
- Tracks moved files with counters and summaries  
- Sanitizes filenames by trimming unwanted leading/trailing spaces 
- Detects identical files using SHA256 hash comparison to avoid redundant moves  
- Resolves filename conflicts (same name, different content) by auto-renaming files with hash + timestamp suffix
- ***Undo mechanism to revert moved or renamed files interactively***
- ***Records every action to an undo log for safe rollback***
- ***Supports confirmation prompts before each reversal***

---

## Prerequisites

- Bash version 4.0 or higher  
- Unix-like operating system (tested on Linux, macOS)  
- Basic permissions to read/write in `~/Downloads` and log directory  

---

## Usage

```bash
# Move files for real
./organize_downloads.sh

# Preview actions without moving files (dry-run mode)
./organize_downloads.sh --dry-run

# Revert previous file moves (with confirmation prompts)
./organize_downloads.sh --undo

To a undo a specific file only, partial undo support is planned for future versions 

```
---
## Undo Mechanism

- Each move or rename is logged to `downloads_undo.log`

- Running `--undo` will reverse these changes one by one

- You are prompted to confirm each undo action

- Once undone, the log is cleared to prevent double reversions


---

## Logging

- Logs are saved by default to: `~/bash-scripts/downloads_organizer.log`  
- Log entries include timestamps, log level, and descriptive messages  
- Log levels used:
  - `INFO`: Actual file moves  
  - `DRY RUN`: Simulated moves during dry-run  
  - `ERROR`: Failed operations  

### Example log entries

```
2025-06-02 14:33:02 [INFO] moved 'file.pdf' to 'PDFs/'
2025-06-02 14:33:03 [DRY RUN] would move 'image.jpg' to 'Images/'
2025-06-02 14:33:04 [ERROR] failed to move 'badfile.iso' to 'ISO_images/'
```

---

## Installation

```bash
git clone https://github.com/yankhoembekezani/bash-downloads-organizer.git
cd bash-downloads-organizer
chmod +x organize_downloads.sh
```

---

## Limitations

- Organizes files only at the top level of `~/Downloads` (no recursive sorting)  
- Fixed category mappings—no current support for user-defined types  

---

## Planned Features

- + **Partial undo support** for specific files or time windows    
- **Custom log file path via CLI flag** (`--log-file <path>`)  
- **Expanded file type support:** Videos, Audio, Office Documents, Code Files  
- **Configuration file support** for custom categories and extensions  

---

## Contribution

Feel free to open issues or submit pull requests on GitHub for improvements or bug fixes.

