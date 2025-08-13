#!/bin/bash

# === CONFIGURATION ===

# === DEFAULT TARGET-DIR
target_dir="$HOME/Downloads"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log_file="$SCRIPT_DIR/organizer.log"
undo_log_file="$SCRIPT_DIR/organizer_undo.log"

mkdir -p "$(dirname "$log_file")"
mkdir -p "$(dirname "$undo_log_file")"

# === LOGGING FUNCTION === (moved up so it's available early)
function log {
    local level="$1"; local message="$2"
    local timestamp; timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$timestamp [$level] $message" >> "$log_file"
    echo "$message"
}

# ===== FLAG INITIALIZATION =====
help_mode=false
dry_run=false
undo_mode=false
target_dir_arg_set=false
config_file=""
generate_config=false   # optional

# ===== ARG PARSING (single loop) =====
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help) help_mode=true; shift ;;
        --dry-run) dry_run=true; shift ;;
        --undo) undo_mode=true; shift ;;
        --target-dir)
            shift
            if [[ -z "${1:-}" ]]; then
                echo "Error: --target-dir requires a path argument."; exit 1
            fi
            if [[ ! -d "$1" ]]; then
                echo "Error: Provided path '$1' is not a valid directory."; exit 1
            fi
            target_dir="$1"
            target_dir_arg_set=true
            shift
            ;;
        --config)
            shift
            if [[ -z "${1:-}" ]]; then
                echo "Error: --config requires a file path."; exit 1
            fi
            config_file="$1"
            shift
            ;;
        --generate-config)
            generate_config=true; shift ;;
        -*)
            echo "unknown option $1"; exit 1 ;;
        *)
            echo "unexpected argument $1"; exit 1 ;;
    esac
done

# === HELP FLAG COMPATIBILITY VALIDATION ===
if $help_mode && { $dry_run || $undo_mode || [[ "$target_dir_arg_set" == true ]] || [[ -n "$config_file" ]]; }; then
    echo "Error: --help must be used alone."
    exit 1
fi


# === HELP FUNCTION ===
function print_help {
    local help_flag="$1"
    if [[ "$help_flag" == true ]]; then
        cat << _EOF_
Usage: ./organize.sh [OPTION]

Organizes files in a specified directory (Downloads by default) into categorized folders.

Options:
  --target-dir <path>  specify directory to organize (defaults to ~/Downloads)
  --dry-run            Show what would be done without moving files
  --undo               Revert last file organization based on undo log
  --config <path>      Merge additional file formats from an INI file (opt-in)
  --generate-config    Write a starter INI template next to the script and exit
  --help               Display this help message

All activities are logged to $log_file
_EOF_
        exit 0
    fi
}
print_help "$help_mode"

# Optional: generate template INI and exit
if $generate_config; then
    template="$SCRIPT_DIR/filetypes.example.ini"
    cat > "$template" <<'EOF'
# Add extra formats here. One or more extensions per line (space/newline separated).
# Category headers in [Brackets]. Comments start with #.

[Images]
heic avif

[3D]
stl obj fbx
EOF
    echo "Generated template: $template"
    exit 0
fi

# === FLAG COMPATIBILITY VALIDATION ===

# --dry-run and --undo cannot be used together
if $dry_run && $undo_mode; then
    echo "Error: --dry-run and --undo cannot be used together."
    exit 1
fi

# --undo and --target-dir are not allowed together
if $undo_mode && [[ "$target_dir_arg_set" == true ]]; then
    echo "Error: --undo cannot be used with --target-dir."
    exit 1
fi

# --undo and --config are not allowed together
if $undo_mode && [[ -n "$config_file" ]]; then
    echo "Error: --undo cannot be used with --config."
    exit 1
fi

# === CATEGORY SETUP ===
destination_directory="$target_dir/organized"

declare -A FILE_GROUPS=(
    [Images]="jpg jpeg png gif svg webp bmp tiff"
    [Videos]="mp4 mkv mov avi webm flv mpg"
    [Audio]="mp3 wav aac flac ogg m4a"
    [Documents]="pdf doc docx xls xlsx ppt pptx txt csv odt"
    [Archives]="zip rar tar gz bz2 7z xz"
    [Installers]="exe msi deb rpm dmg pkg sh"
    [ISOs]="iso img bin nrg"
    [Code]="py js html css json xml yaml yml sh java c cpp"
)

# === MERGE EXTRA FILETYPES FROM CONFIG (only if --config was provided) ===
if [[ -n "$config_file" ]]; then
    if [[ ! -f "$config_file" ]]; then
        echo "Error: Config file '$config_file' does not exist."; exit 1
    fi
    log "INFO" "Merging formats from config: $config_file"
    current_category=""
    while IFS= read -r line; do
        line="${line%%#*}"
        line="$(echo "$line" | xargs)"
        [[ -z "$line" ]] && continue

        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            current_category="${BASH_REMATCH[1]}"
            [[ -z "${FILE_GROUPS[$current_category]+_}" ]] && FILE_GROUPS[$current_category]=""
        elif [[ -n "$current_category" ]]; then
            for token in $line; do
                ext="${token#.}"
                ext="${ext,,}"
                if [[ ! " ${FILE_GROUPS[$current_category]} " =~ " $ext " ]]; then
                    FILE_GROUPS[$current_category]+=" $ext"
                fi
            done
        fi
    done < "$config_file"
fi

# Create destination subfolders for all categories (post-merge)
for category in "${!FILE_GROUPS[@]}"; do
    mkdir -p "$destination_directory/$category"
done
mkdir -p "$destination_directory/Others"

# === DIRECTORY TO ORGANIZE ===
if [[ -d "$target_dir" && -w "$target_dir" ]]; then
    directory2organize="$target_dir"
else
    echo "ERROR: '$target_dir' is not a writable directory"
    exit 1
fi

# === COUNTERS ===
declare -A CATEGORY_COUNTERS  # empty; lazy-init in move_file

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
    echo "$raw" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# === CONFLICT RESOLUTION FUNCTION ===
function resolve_conflict_and_move {
    local source_file="$1"
    local target_dir="$2"
    local filename; filename=$(basename "$source_file")

    local timestamp; timestamp=$(date +%Y%m%d_%H%M%S)
    local hash_suffix; hash_suffix=$(sha256sum "$source_file" | awk '{print substr($1,1,8)}')

    local extension="${filename##*.}"
    local basename="${filename%.*}"

    local new_filename
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
    local filename; filename=$(basename "$source_file")
    local target_path="${target_dir}/${filename}"

    detect_conflict "$target_path" "$source_file"
    local conflict_status=$?

    if [[ $conflict_status -eq 1 ]]; then
        resolve_conflict_and_move "$source_file" "$target_dir"
        if [[ $? -eq 0 && ! $dry_run ]]; then
            : "${CATEGORY_COUNTERS[$category]:=0}"
            ((CATEGORY_COUNTERS["$category"]++))
        fi

    elif [[ $conflict_status -eq 2 ]]; then
        log "INFO" "skipped moving '$filename'; identical file already exists in '$category/'"

    else
        if $dry_run; then
            log "DRY RUN" "would move '$filename' to '$category/'"
        elif mv "$source_file" "$target_dir"; then
            log "INFO" "moved '$filename' to '$category/'"
            echo "MOVED|$source_file|$target_path" >> "$undo_log_file"
            : "${CATEGORY_COUNTERS[$category]:=0}"
            ((CATEGORY_COUNTERS["$category"]++))
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

            mkdir -p "$(dirname "$src")"
            if mv "$dst" "$src"; then
                echo "✔ Undone: $dst → $src"
            else
                echo "✖ Failed to move: $dst" >&2
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
shopt -s nullglob
for file in "$directory2organize"/*; do
    [[ -f "$file" ]] || continue

    clean_name=$(sanitize_filename "$(basename "$file")")
    clean_path="$(dirname "$file")/$clean_name"
    if [[ "$file" != "$clean_path" ]]; then
        if ! mv "$file" "$clean_path"; then
            log "ERROR" "failed to rename '$file' to sanitized version"
            continue
        fi
        file="$clean_path"
    fi

    ext="${file##*.}"
    ext="${ext,,}"

    category_found=false
    for category in "${!FILE_GROUPS[@]}"; do
        for valid_ext in ${FILE_GROUPS[$category]}; do
            if [[ "$ext" == "$valid_ext" ]]; then
                move_file "$file" "$destination_directory/$category" "$category"
                category_found=true
                break 2
            fi
        done
    done

    if ! $category_found; then
        move_file "$file" "$destination_directory/Others" "Others"
    fi
done
shopt -u nullglob

# === SUMMARY OUTPUT ===
if ! $dry_run; then
    echo -e "\nOrganized file summary:"
    for moved_category in "${!CATEGORY_COUNTERS[@]}"; do
        count="${CATEGORY_COUNTERS[$moved_category]}"
        if [[ "$count" -gt 0 ]]; then
            echo "$moved_category: $count"
        fi
    done | sort -k2 -nr
    echo "Organization of files done!"
else
    echo -e "\nDry run complete. No files were moved."
fi

