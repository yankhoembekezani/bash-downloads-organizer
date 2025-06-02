# Bash Downloads Organizer

A Bash script that organizes files in your `~/Downloads` directory by file type.

---

## Features

- Categorizes files into predefined groups: PDFs, Images, Archives, ISO files, Others  
- Dry-run mode to preview actions without modifying files  
- Structured logging with timestamps, log levels, and detailed messages  
- Automatically creates destination folders if missing  
- Tracks moved files with counters and summaries  

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
```

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
- No automatic handling of duplicate filenames (files with the same name may be overwritten)  

---

## Planned Features

- **Auto-renaming duplicates** to prevent overwriting  
- **Undo mechanism** to revert file moves  
- **Custom log file path via CLI flag** (`--log-file <path>`)  
- **Expanded file type support:** Videos, Audio, Office Documents, Code Files  
- **Configuration file support** for custom categories and extensions  

---

## Contribution

Feel free to open issues or submit pull requests on GitHub for improvements or bug fixes.

