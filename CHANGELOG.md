# Changelog

All notable changes to this project are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]
### Added
- `hash_file()` function for SHA256-based content comparison
- `sanitize_filename()` to normalize filenames by trimming whitespace
- Enhanced `detect_conflict()` to distinguish true duplicates from content-level conflicts
- Pre-move renaming for files with problematic names (e.g. trailing spaces)
- Code cleanup and improved internal consistency of `move_file()`

---

## [v0.2.0] - 2025-06-13
### Refactored
- Modularized classification and move logic into distinct functions
- Introduced early conflict detection using file presence checks

---

## [v0.1.1] - 2025-06-02
### Added
- Structured logging with timestamps and log levels
- Initial `README.md` and `.gitignore` for project documentation and cleanup

---

## [v0.1.0] - 2025-05-28
### Added
- Initial implementation of the Bash Downloads Organizer
- File categorization by extension (PDFs, Images, Archives, ISOs, Others)
- Basic move logic for sorting downloads

---

