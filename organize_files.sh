#!/bin/bash

read -r -p "Enter directory path: " dir

if [ ! -d "$dir" ]; then
    echo "Error: Directory does not exist"
    exit 1
fi

mkdir -p "$dir/Documents" "$dir/Images" "$dir/Scripts" "$dir/Others"

doc=0
img=0
scr=0
oth=0

# Prevent an unmatched * from being treated as a literal filename.
shopt -s nullglob

for file in "$dir"/*; do
    if [ ! -f "$file" ]; then
        continue
    fi

    filename=$(basename "$file")
    extension="${filename##*.}"
    extension=$(printf '%s' "$extension" | tr '[:upper:]' '[:lower:]')

    case "$extension" in
        pdf|doc|docx|txt|md)
            target="$dir/Documents"
            category="doc"
            ;;
        jpg|jpeg|png|gif)
            target="$dir/Images"
            category="img"
            ;;
        sh|py|ps1)
            target="$dir/Scripts"
            category="scr"
            ;;
        *)
            target="$dir/Others"
            category="oth"
            ;;
    esac

    destination="$target/$filename"

    # Avoid silently overwriting a file with the same name.
    if [ -e "$destination" ]; then
        base="${filename%.*}"
        ext="${filename##*.}"

        if [ "$base" = "$ext" ]; then
            destination="$target/${filename}_$(date +%Y%m%d_%H%M%S)"
        else
            destination="$target/${base}_$(date +%Y%m%d_%H%M%S).${ext}"
        fi
    fi

    if mv -- "$file" "$destination"; then
        case "$category" in
            doc) doc=$((doc + 1)) ;;
            img) img=$((img + 1)) ;;
            scr) scr=$((scr + 1)) ;;
            oth) oth=$((oth + 1)) ;;
        esac
    else
        echo "Warning: Could not move $filename"
    fi
done

echo ""
echo "Organization complete."
echo "Documents: $doc"
echo "Images: $img"
echo "Scripts: $scr"
echo "Others: $oth"
