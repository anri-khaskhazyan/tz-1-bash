#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_directory> <output_directory>"
    exit 1
fi

input_dir="$1"
output_dir="$2"

if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory '$input_dir' does not exist."
    exit 1
fi

if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

copy_files() {
    local source_dir="$1"
    local dest_dir="$2"
    local file_counter=0
    
    while IFS= read -r -d '' file; do
        file_basename=$(basename -- "$file")
        dest_file="$dest_dir/$file_basename"
        
        if [ -e "$dest_file" ]; then
            dest_file="$dest_dir/${file_basename%.*}_$file_counter.${file_basename##*.}"
            ((file_counter++))
        fi
        
        cp --backup=numbered "$file" "$dest_file"
        
    done < <(find "$source_dir" -type f -print0)
}

copy_files "$input_dir" "$output_dir"

echo "Files copied successfully."
