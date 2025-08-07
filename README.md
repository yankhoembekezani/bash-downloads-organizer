[![Shell Script](https://img.shields.io/badge/Bash-4.0+-blue?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/github/license/yankhoembekezani/bash-downloads-organizer)](https://github.com/yankhoembekezani/bash-downloads-organizer/blob/main/LICENSE)
[![Maintained](https://img.shields.io/badge/Maintained-yes-brightgreen.svg)](https://github.com/yankhoembekezani/bash-downloads-organizer)


# Organizer.sh

A robust and safe Bash script that organizes your `~/Downloads` folder — with undo, dry-run mode, customizable target directory, conflict resolution, and full logging.

---

## Features

- Organizes files into categories: PDFs, Images, Archives, ISOs, Others
- Custom target directory support using `--target-dir <path>`
- Dry-run mode to preview actions before making any changes  
- Undo mode to safely revert moved or renamed files with confirmation prompts  
- Conflict resolution: auto-renames files if name exists but content differs  
- Skips identical files using SHA256 hash checks  
- Logging: detailed logs with timestamps and log levels  
- `--help` flag for quick usage guidance
- Automatically creates destination folders if missing  

---

## Prerequisites

- Bash version 4.0 or higher  
- Unix-like operating system (tested on Linux and macOS)  
- Read/write permissions in the source and target directories 

---

## Installation

```bash
git clone https://github.com/yankhoembekezani/bash-downloads-organizer.git
cd bash-downloads-organizer
chmod +x organize.sh
```
---

## Usage

```bash
# Organize ~/Downloads by default
./organize.sh

# Organize a different directory
./organize.sh --target-dir /path/to/folder

# Preview actions without moving files 
./organize.sh --dry-run

# Revert previous file moves or renames
./organize.sh --undo

# Show help
./organize.sh --help 

```
---

## Undo Mechanism

- Each move or rename is recorded in `organizer_undo.log`

- `--undo` will reverse these changes one by one

- You are prompted to confirm each undo action (`y`,`n`, or `a` for all)

- Once undone, the log is cleared to prevent duplicate reversions

---

## Logging

- Logs are saved to: `~/bash-scripts/organizer.log`  
- Log entries include timestamps, log level, and descriptive messages  
- Log levels used:
  - `INFO`: Actual file moves  
  - `DRY RUN`: Simulated moves (dry-run mode)  
  - `ERROR`: Failed operations  

### Example log entries

```
2025-06-02 14:33:02 [INFO] moved 'file.pdf' to 'PDFs/'
2025-06-02 14:33:03 [DRY RUN] would move 'image.jpg' to 'Images/'
2025-06-02 14:33:04 [ERROR] failed to move 'badfile.iso' to 'ISO_images/'

```

---

##  Implementation Notes

These internal behaviours (not exposed as user-facing features)

 - Filenames are sanitized (removes leading/trailing whitespace)
 - Uses SHA256 hashing to detect duplicate files
 - Renames conflicting files with timestamp + hash suffix
 - Tracks and summarizes moved files counts per category

---

## Limitations

- Organizes only top level files in `~/Downloads` (no recursive sorting)  
- Category mappings are fixed-user-defined types not yet supported  

---

## Planned Features

- Config file support for custom categories and file extensions
- Partial undo support (by file or time window)
- Expanded file type support: video, audio, office documents, code files
  
---

## Contribution

Pull requests and issue reports are welcome.
Help improve features, fix bugs, or enhance documentation.

---

## License

This project is licensed under the MIT License.  
See the [LICENSE](LICENSE) file for full details.

