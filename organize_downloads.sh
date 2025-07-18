#!/bin/bash

# === CONFIGURATION ===
directory2organize=~/Downloads
destination_directory=~/Downloads/DEST_DIR1
log_file=~/bash-scripts/downloads_organizer.log
undo_log_file=~/bash-scripts/downloads_undo.log

# === CATEGORY SETUP ===
categories=(PDFs Images Archives ISO_images Others)
for category in "${categories[@]}"; do
    mkdir -p "$destination_directory/$category"
done

# ===== FLAG INITIALIZATION =====

# === HELP FLAG ===
help_mode=false
[[ "$1" == "--help" ]] && help_mode=true

# === DRY RUN FLAG ===
dry_run=false
[[ "$1" == "--dry-run" ]] && dry_run=true

# === UNDO FLAG ===
undo_mode=false
[[ "$1" == "--undo" ]] && undo_mode=true

# === COUNTERS ===
pdf_count=0; img_count=0; arc_count=0; iso_count=0; other_count=0

# === HELP FUNCTION ===
function help {
    local help_flag="$1"

    if [[ "$help_flag" == true ]]; then
        cat << _EOF_
Usage: ./organize_downloads.sh [OPTION]

Organizes files in ~/Downloads into categorized folders.

Options:
  --dry-run      Show what would be done without moving files
  --undo         Revert last file organization based on undo log
  --help         Display this help message

All activities are logged to ~/bash-scripts/downloads_organizer.log
_EOF_
exit 0
    fi
}
help "$help_mode"


# === LOGGING FUNCTION ===
function log {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp [$level] $message" >> "$log_file"
    echo "$message"
}

# === HASH FUNCTION ===
function hash_file {
	local file="$1"
	sha256sum "$file" | awk '{print $1}'
}

# === CONFLICT DETECTION FUNCTION ===
function detect_conflict {
	local target_file="$1"
	local source_file="$2"
	local src_filename tgt_filename
	tgt_filename=$(basename "$target_file")
	src_filename=$(basename "$source_file")

if [[ -e "$target_file" ]]; then
	local hash_src=$(hash_file "$source_file")
	local hash_tgt=$(hash_file "$target_file")

	if [[ "$hash_src" == "$hash_tgt" ]]; then
		log "INFO" "duplicate detected: '$src_filename' and '$tgt_filename'"
		return 2 # Duplicate
	else
		return 1 # Conflict
	fi
fi

return 0 # No conflict

}

# === SANITIZE FILENAME FUNCTION ===
function sanitize_filename {
	local raw="$1"
	
	# Strip leading and trailing whitespace
	echo "$raw" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# === CONFLICT RESOLUTION FUNCTION ===
function resolve_conflict_and_move {
    local source_file="$1"
    local target_dir="$2"
    local filename
    filename=$(basename "$source_file")

    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)

    local hash_suffix
    hash_suffix=$(sha256sum "$source_file" | awk '{print substr($1,1,8)}')

    extension="${filename##*.}"
    basename="${filename%.*}"

    if [[ "$filename" == "$extension" ]]; then
    	new_filename="${filename}_conflict_${timestamp}_${hash_suffix}"
    else
    	new_filename="${basename}_conflict_${timestamp}_${hash_suffix}.${extension}"
    fi

    local new_target_path="${target_dir}/${new_filename}"

    if $dry_run; then
        log "DRY RUN" "conflict: '$filename' already exists with different content"
        log "DRY RUN" "would rename and move as: '$new_filename'"
    else
        if mv "$source_file" "$new_target_path"; then
            log "INFO" "resolved conflict by renaming and moving to: '$new_filename'"
	    echo "RENAMED|$source_file|$new_target_path" >> "$undo_log_file"
            echo "$new_filename"
            return 0
        else
            log "ERROR" "failed to move '$filename' to '$new_filename'"
            return 1
        fi
    fi
}

# === MOVE FILE FUNCTION ===
function move_file {
    local source_file="$1"
    local target_dir="$2"
    local category="$3"
    local filename
    filename=$(basename "$source_file")
    local target_path="${target_dir}/${filename}"

    detect_conflict "$target_path" "$source_file"
    conflict_status=$?

    if [[ $conflict_status -eq 1 ]]; then
        # Conflict — different content, same name
        resolved_name=$(resolve_conflict_and_move "$source_file" "$target_dir")
        if [[ $? -eq 0 && ! $dry_run ]]; then
            case "$category" in
                PDFs)       ((pdf_count++)) ;;
                Images)     ((img_count++)) ;;
                Archives)   ((arc_count++)) ;;
                ISO_images) ((iso_count++)) ;;
                Others)     ((other_count++)) ;;
            esac
        fi

    elif [[ $conflict_status -eq 2 ]]; then
        # Duplicate file — identical content
        log "INFO" "skipped moving '$filename'; identical file already exists in '$category/'"

    else
        # No conflict — move file normally
        if $dry_run; then
            log "DRY RUN" "would move '$filename' to '$category/'"
        elif mv "$source_file" "$target_dir"; then
            log "INFO" "moved '$filename' to '$category/'"
	    echo "MOVED|$source_file|$target_path" >> "$undo_log_file"
	
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

# === UNDO MODE HANDLING ===
if $undo_mode; then
    if [[ ! -f "$undo_log_file" ]]; then
        echo "No undo log found. Nothing to undo."
        exit 0
    fi

apply_all=false # undo all option
    while IFS="|" read -r action src dst; do
        echo "DEBUG: Undoing $action from '$dst' back to '$src'"

	if [[ -f "$dst" ]]; then
    		if ! $apply_all; then
        		echo -n "Undo $action? Move '$dst' → '$src'? [y/N/a]: "
        		read -r confirm < /dev/tty

        	case "$confirm" in
            		[Yy]) ;;
            		[Aa]) apply_all=true ;;
            		*) echo "⏭ Skipped: $dst"; continue ;;
        	esac
    	fi

    	if mv "$dst" "$src"; then
        	echo "✔ Undone: $dst → $src"
    	else
        	echo "✖ Failed to move: $dst"
    	fi
	else
    		echo "⚠ Missing: $dst not found."
	fi

    done < <(tac "$undo_log_file")

    > "$undo_log_file"
    echo "Undo complete."
    exit 0
fi

# === FILE CLASSIFICATION ===
for file in "$directory2organize"/*; do
    [[ -f "$file" ]] || continue

   clean_name=$(sanitize_filename "$(basename "$file")")
    clean_path="$(dirname "$file")/$clean_name"
    if [[ "$file" != "$clean_path" ]]; then
        mv "$file" "$clean_path"
        file="$clean_path"
    fi
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

