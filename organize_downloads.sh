#!/bin/bash

# source and destination directories
directory2organize=~/Downloads
destination_directory=~/Downloads/DEST_DIR1

# create destination folders
mkdir -p "$destination_directory"
mkdir -p "$destination_directory"/{PDFs,Images,Archives,ISO_images,Others}

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
			echo "would move '$(basename "$i")' to 'PDFs/'" 
                else
                    if mv "$i" "PDFs"; then
			    echo "moved '$(basename "$i")' to 'PDFs/'" 
                        ((pdf_count++))
                    else
			    echo "ERROR: failed to move '$(basename "$i")' to 'PDFs/'" 
                    fi
                fi
                ;;

            *.jpg|*.jpeg|*.png)
                if $dry_run; then
			echo "would move '$(basename "$i")' to 'Images'" 
                else
                    if mv "$i" "Images"; then
			    echo "moved '$(basename "$i")' to 'Images'" 
                        ((img_count++))
                    else
                        echo "ERROR: failed to move '$(basename "$i") to 'Images'" 
                    fi
                fi
                ;;  

            *.tar|*.tar.gz|*.rar)
                if $dry_run; then
                    echo "would move '$(basename "$i") to 'Archives'" 
                else
                    if mv "$i" "Archives"; then
                        echo "moved '$i' to 'Archives'" 
                        ((arc_count++))
                    else
                        echo "ERROR: failed to move '$(basename "$i") to 'Archives'" 
                    fi
                fi
                ;;

            *.iso)
                if $dry_run; then
                    echo "would move '$(basename "$i") to 'ISO_images'" 
                else
                    if mv "$i" "ISO_images"; then
                        echo "moved '$i' to 'ISO_images'" 
                        ((iso_count++))
                    else
                        echo "ERROR: failed to move '$(basename "$i") to 'ISO_images'" 
                    fi
                fi
                ;;

            *)
                if $dry_run; then
                    echo "would move '$(basename "$i") to 'Others'" 
                else
                    if mv "$i" "Others"; then
                        echo "moved '$i' to 'Others'" 
                        ((other_count++))
                    else
			    echo "ERROR: failed to move '$(basename "$i")' to 'Others'" 
                    fi
                fi
                ;;
        esac
    fi
done

# displaying results
echo "Summary:"
echo "PDFs: $pdf_count"
echo "Images: $img_count"
echo "Images: $img_count"
echo "Archives: $arc_count"
echo "ISOs: $iso_count"
echo "Others: $other_count"

echo "Organization of files done!" 
