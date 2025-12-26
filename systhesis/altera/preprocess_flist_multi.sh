#!/bin/bash
# preprocess_flist_multi.sh - Process multiple file lists

set -e

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <output_file> <input_file1> [input_file2 ...] [project_root]" >&2
    exit 1
fi

OUTPUT_FILE="$1"
shift
INPUT_FILES=("$@")

# Last argument might be project_root
PROJECT_ROOT=""
if [ $# -gt 1 ] && [ -d "${@: -1}" ]; then
    PROJECT_ROOT="${@: -1}"
    INPUT_FILES=("${INPUT_FILES[@]:0:$((${#INPUT_FILES[@]}-1))}")
fi

[ -z "$PROJECT_ROOT" ] && PROJECT_ROOT=$(pwd)

echo "Preprocessing multiple file lists..." >&2
echo "Output: $OUTPUT_FILE" >&2
echo "Inputs: ${INPUT_FILES[@]}" >&2
echo "Project Root: $PROJECT_ROOT" >&2

# Create temp file
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

# Process a single file list
process_single_list() {
    local input_file="$1"
    local parent_dir="$2"
    local depth="${3:-0}"
    
    local indent=""
    for ((i=0; i<depth; i++)); do
        indent+="  "
    done
    
    echo "${indent}Processing: $input_file" >&2
    
    if [ ! -f "$input_file" ]; then
        echo "${indent}Warning: File not found: $input_file" >&2
        return
    fi
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Clean line
        line="${line%%#*}"
        line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        [ -z "$line" ] && continue
        
        # Skip compiler options
        if [[ "$line" == +* ]] || [[ "$line" == -* && ! "$line" =~ ^-f[[:space:]] ]]; then
            echo "${indent}  Skipping: $line" >&2
            continue
        fi
        
        # Replace PROJECT_ROOT
        line="${line//\$\{PROJECT_ROOT\}/$parent_dir}"
        line="${line//\$PROJECT_ROOT/$parent_dir}"
        
        # Handle -f instructions
        if [[ "$line" =~ ^-f[[:space:]] ]]; then
            local nested_file="${line#-f}"
            nested_file="$(echo "$nested_file" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
            
            if [ -f "$nested_file" ]; then
                local nested_dir="$(dirname "$(realpath "$nested_file")")"
                local nested_parent="$(dirname "$nested_dir")"
                process_single_list "$nested_file" "$nested_parent" $((depth + 1))
            fi
        else
            echo "$line" >> "$TEMP_FILE"
        fi
    done < "$input_file"
}

# Process all input files
for input_file in "${INPUT_FILES[@]}"; do
    # If input_file is relative, make it absolute relative to project root
    if [[ ! "$input_file" =~ ^/ ]]; then
        input_file="$PROJECT_ROOT/$input_file"
    fi
    process_single_list "$input_file" "$PROJECT_ROOT"
done

# Remove duplicates and sort
sort -u "$TEMP_FILE" > "${TEMP_FILE}.sorted"

# Output
if [ "$OUTPUT_FILE" = "/dev/stdout" ]; then
    cat "${TEMP_FILE}.sorted"
else
    mv "${TEMP_FILE}.sorted" "$OUTPUT_FILE"
    echo "Generated $OUTPUT_FILE with $(wc -l < "$OUTPUT_FILE") entries" >&2
fi

rm -f "${TEMP_FILE}.sorted"
