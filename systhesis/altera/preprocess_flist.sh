#!/bin/bash
# preprocess_flist_enhanced.sh - Enhanced version with more skip patterns

set -e

input_file="$1"
output_file="$2"
project_root="$3"

[ $# -lt 2 ] && { echo "Usage: $0 <input> <output> [project_root]" >&2; exit 1; }
[ -z "$project_root" ] && project_root=$(pwd)

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file not found: $input_file" >&2
    exit 1
fi

# Main processing function
process_flist() {
    local file="$1"
    local parent="$2"
    local depth="${3:-0}"
    
    # Indent for debugging
    local indent=""
    for ((i=0; i<depth; i++)); do
        indent+="  "
    done
    
    echo "${indent}Processing: $file" >&2
    echo "${indent}PROJECT_ROOT: $parent" >&2
    
    while IFS= read -r line || [ -n "$line" ]; do
        # Clean the line
        line="${line%%#*}"
        line="$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        [ -z "$line" ] && continue
        
        echo "${indent}  Line: $line" >&2
        
        # Skip various compiler options and directives
        case "$line" in
            +*)
                echo "${indent}    Skipping compiler option: $line" >&2
                continue
                ;;
            -*)
                # Check if it's -f (file list) or other option
                if [[ "$line" =~ ^-f[[:space:]] ]]; then
                    # Handle -f instructions
                    local nested="${line#-f}"
                    nested="$(echo "$nested" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
                    
                    # Replace PROJECT_ROOT in nested file path
                    nested="${nested//\$\{PROJECT_ROOT\}/$parent}"
                    nested="${nested//\$PROJECT_ROOT/$parent}"
                    
                    echo "${indent}    Found nested filelist: $nested" >&2
                    
                    if [ -f "$nested" ]; then
                        local nested_dir="$(dirname "$(realpath "$nested")")"
                        local nested_parent="$(dirname "$nested_dir")"
                        process_flist "$nested" "$nested_parent" $((depth + 1))
                    else
                        echo "${indent}    Warning: Nested filelist not found" >&2
                    fi
                else
                    echo "${indent}    Skipping option: $line" >&2
                    continue
                fi
                ;;
            *)
                # Regular file path - replace PROJECT_ROOT
                line="${line//\$\{PROJECT_ROOT\}/$parent}"
                line="${line//\$PROJECT_ROOT/$parent}"
                echo "$line"
                echo "${indent}    Output: $line" >&2
                ;;
        esac
    done < "$file"
}

# Output handling
echo "Starting file list preprocessing..." >&2
echo "Input: $input_file" >&2
echo "Output: $output_file" >&2
echo "Project Root: $project_root" >&2

if [ "$output_file" = "/dev/stdout" ]; then
    # Direct output to stdout
    process_flist "$input_file" "$project_root"
else
    # Output to file
    process_flist "$input_file" "$project_root" > "$output_file"
    count=$(wc -l < "$output_file" 2>/dev/null || echo 0)
    echo "Generated $output_file with $count entries" >&2
fi
