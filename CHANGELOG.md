# Changelog

All notable changes to this project are documented here.

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2025-08-13
### Added
- Optional `--config <path>` support for merging additional file formats or categories from an INI file
- `--generate-config` to create starter config template next to the script
- Category merging handles custom extensions without overwriting defaults

### Changed
- Help (`--help`) now validated to run alone; prints usage immediately
- Dry-run, undo, target-dir, and config flag compatibility validation improved
- Internal logging behavior tweaked to ensure all key operations are logged

### Fixed
- Minor bug fixes in category folder creation 

---

## [v1.2.0] - 2025-08-07

### Added
- Support for extended file formats Videos, Documents, Audio, Installers, Code
- Smarter summary output for moved files only
- Internal counter improvements

### Changed
- Refactored categorization logic for modularity

---

## [v1.1.0] - 2025-08-06

### Added
- `--target-dir <path>` option for organizing any directory, not just ~/Downloads

### Changed
- Script renamed from `organize_downloads.sh` to `Organizer.sh`
- log file renamed from `downloads_organizer.log` to `organizer.log`
- undo log file renamed from `downloads_undo.log` to `organizer_undo.log`
- Internal adjustments to support target directory flag

### Fixed
- Minor improvements to logging paths and consistency

---

## [v1.0.0] - 2025-07-16

🎉 **First official tagged release**

### Added
- **Organizes files** from `~/Downloads` into 5 categories: PDFs, Images, Archives, ISOs, and Others
- **`--undo` mode** with interactive confirmation to revert moved or renamed files
- **`--dry-run` mode** to preview file organization actions without making changes
- **`--help` flag** displays CLI usage instructions and supported options
- **Conflict resolution**: files with the same name but different content are renamed with a timestamp + short hash to prevent overwriting
- **Duplicate detection**: identical files (based on SHA256 hash) are skipped to avoid redundant moves
- **Logging system**:
  - All actions are logged to `downloads_organizer.log`
  - Undo actions tracked in `downloads_undo.log`
  - Log entries include timestamps, log levels (`INFO`, `DRY RUN`, `ERROR`), and action details
- **Undo mechanism**:
  - Uses structured log playback
  - Supports both `MOVED` and `RENAMED` reversals
  - Prompts user for confirmation before each undo
  - Skips missing files and clears undo log after reversal
- **Filename sanitization**: trims leading and trailing whitespace from all file names before moving
- **Auto-creation of destination folders** if they don’t already exist
- **MIT License** added for open-source clarity

---

_This is the first officially tagged release. Prior development history was tracked but not versioned._

