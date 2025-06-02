#!/bin/bash

# source and destination directories
directory2organize=~/Downloads
destination_directory=~/Downloads/DEST_DIR1

# create destination folders
mkdir -p "$destination_directory"
mkdir -p "$destination_directory"/{PDFs,Images,Archives,ISO_images,Others}

#logging
log_file=~/bash-scripts/downloads_organizer.log

function log {
	local level="$1"
	local message="$2"
	local timestamp
	timestamp=$(date '+%Y-%m-%d %H:%M:%S')

	echo "$timestamp [$level] $message" >> "$log_file"
	echo "$message"

}

# dry-run mode
dry_run=false
[[ "$1" == "--dry-run" ]] && dry_run=true

# counters
pdf_count=0; img_count=0; arc_count=0; iso_count=0; other_count=0

# iterate over files
for i in "$directory2organize"/*; do
    if [[ -f "$i" ]]; then
        case "$i" in
            *.pdf)
                if $dry_run; then
			log "DRY RUN:" "would move '$(basename "$i")' to 'PDFs/'" 
                else
                    if mv "$i"  "$destination_directory/PDFs"; then
			    log "INFO:" "moved '$(basename "$i")' to 'PDFs/'" 
                        ((pdf_count++))
                    else
			    log "ERROR:" "failed to move '$(basename "$i")' to 'PDFs/'" 
                    fi
                fi
                ;;

            *.jpg|*.jpeg|*.png)
                if $dry_run; then
			log "DRY RUN:" "would move '$(basename "$i")' to 'Images'" 
                else
                    if mv "$i"  "$destination_directory/Images"; then
			    log "INFO:" "moved '$(basename "$i") to 'Images'" 
                        ((img_count++))
                    else
                        log "ERROR:" "failed to move '$(basename "$i")' to 'Images'" 
                    fi
                fi
                ;;  

            *.tar|*.tar.gz|*.rar)
                if $dry_run; then
                    log "DRY RUN:" "would move '$(basename "$i")' to 'Archives'" 
                else
                    if mv "$i"  "$destination_directory/Archives"; then
                        log "INFO:" "moved '$i' to 'Archives'" 
                        ((arc_count++))
                    else
                        log "ERROR:" "failed to move '$(basename "$i")' to 'Archives'" 
                    fi
                fi
                ;;

            *.iso)
                if $dry_run; then
                    log "DRY RUN:" "would move '$(basename "$i")' to 'ISO_images'" 
                else
                    if mv "$i"  "$destination_directory/ISO_images"; then
                        log "INFO:" "moved '$i' to 'ISO_images'" 
                        ((iso_count++))
                    else
                        log "ERROR:" "failed to move '$(basename "$i")' to 'ISO_images'" 
                    fi
                fi
                ;;

            *)
                if $dry_run; then
                    log "DRY RUN:" "would move '$(basename "$i")' to 'Others'" 
                else
                    if mv "$i"  "$destination_directory/Others"; then
                        log "INFO:" "moved '$i' to 'Others'" 
                        ((other_count++))
                    else
			    log "ERROR:" "failed to move '$(basename "$i")' to 'Others'" 
                    fi
                fi
                ;;
        esac
    fi
done

# displaying results
if ! $dry_run; then
    echo "Summary:"
    echo "PDFs: $pdf_count"
    echo "Images: $img_count"
    echo "Archives: $arc_count"
    echo "ISOs: $iso_count"
    echo "Others: $other_count"
    echo "Organization of files done!"
else
    echo "Dry run complete. No files were moved."
fi

