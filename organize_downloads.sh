#!/bin/bash

# === CONFIGURATION ===
directory2organize=~/Downloads
destination_directory=~/Downloads/DEST_DIR1
log_file=~/bash-scripts/downloads_organizer.log

# === CATEGORY SETUP ===
categories=(PDFs Images Archives ISO_images Others)
for category in "${categories[@]}"; do
    mkdir -p "$destination_directory/$category"
done

# === LOGGING FUNCTION ===
function log {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp [$level] $message" >> "$log_file"
    echo "$message"
}

# === CONFLICT DETECTION ===
function detect_conflict {
    local target_file="$1"
    [[ -e "$target_file" ]]
}

# === FILE MOVE FUNCTION ===
function move_file {
    local source_file="$1"
    local target_dir="$2"
    local category="$3"
    local filename
    filename=$(basename "$source_file")
    local target_path="${target_dir}/${filename}"

    if detect_conflict "$target_path"; then
        if $dry_run; then
            log "DRY RUN" "conflict: '$filename' already exists in '$category/'"
        else
            log "INFO" "skipped moving '$filename' due to conflict in '$category/'"
        fi
    else
        if $dry_run; then
            log "DRY RUN" "would move '$filename' to '$category/'"
        elif mv "$source_file" "$target_dir"; then
            log "INFO" "moved '$filename' to '$category/'"
            case "$category" in
                PDFs)       ((pdf_count++)) ;;
                Images)     ((img_count++)) ;;
                Archives)   ((arc_count++)) ;;
                ISO_images) ((iso_count++)) ;;
                Others)     ((other_count++)) ;;
            esac
        else
            log "ERROR" "failed to move '$filename' to '$category/'"
        fi
    fi
}

# === DRY RUN FLAG ===
dry_run=false
[[ "$1" == "--dry-run" ]] && dry_run=true

# === COUNTERS ===
pdf_count=0; img_count=0; arc_count=0; iso_count=0; other_count=0

# === FILE CLASSIFICATION ===
for file in "$directory2organize"/*; do
    [[ -f "$file" ]] || continue
    case "$file" in
        *.pdf)                move_file "$file" "$destination_directory/PDFs" "PDFs" ;;
        *.jpg|*.jpeg|*.png)   move_file "$file" "$destination_directory/Images" "Images" ;;
        *.tar|*.tar.gz|*.rar) move_file "$file" "$destination_directory/Archives" "Archives" ;;
        *.iso)                move_file "$file" "$destination_directory/ISO_images" "ISO_images" ;;
        *)                    move_file "$file" "$destination_directory/Others" "Others" ;;
    esac
done

# === SUMMARY OUTPUT ===
if ! $dry_run; then
    echo -e "\nSummary:"
    echo "PDFs: $pdf_count"
    echo "Images: $img_count"
    echo "Archives: $arc_count"
    echo "ISOs: $iso_count"
    echo "Others: $other_count"
    echo "Organization of files done!"
else
    echo -e "\nDry run complete. No files were moved."
fi

