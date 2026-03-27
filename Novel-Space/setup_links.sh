#!/bin/bash

# Configuration
# This script assumes it is run from the 'Novel-Space/' directory
BASE_DIR="soft_link"
SPECTRUM_BASE="$BASE_DIR/Spectra"
CIF_BASE="$BASE_DIR/All_CIFs"
FIGURE_BASE="$BASE_DIR/figure"

echo "=== XRD-AutoAnalyzer-PyTorch Environment Setup ==="
echo "This script will help you set up symbolic links for the required data directories."

# Helper function to select from a list
select_from_dir() {
    local dir=$1
    local prompt=$2
    local default_item=$3
    
    if [ ! -d "$dir" ]; then
        echo "Warning: Directory $dir not found." >&2
        read -p "$prompt (manual input): " result >&2
        echo "$result"
        return
    fi

    # Use find to get directories and store in an array
    local options=($(find "$dir" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;))
    
    if [ ${#options[@]} -eq 0 ]; then
        echo "No directories found in $dir." >&2
        read -p "$prompt (manual input, or -1 to create): " choice >&2
        if [[ "$choice" == "-1" ]]; then
            read -p "Enter new directory name: " new_name >&2
            mkdir -p "$dir/$new_name"
            echo "$dir/$new_name"
        else
            echo "$choice"
        fi
        return
    fi

    echo "Available options in $dir:" >&2
    echo "  [-1] Create new empty directory" >&2
    local default_index=0
    for i in "${!options[@]}"; do
        if [[ "${options[$i]}" == "$default_item" ]]; then
            default_index=$i
        fi
        printf "  [%d] %s\n" "$i" "${options[$i]}" >&2
    done

    read -p "$prompt [default index: $default_index, or -1 to create]: " choice >&2
    if [[ -z "$choice" ]]; then choice=$default_index; fi

    if [[ "$choice" == "-1" ]]; then
        read -p "Enter new directory name: " new_name >&2
        mkdir -p "$dir/$new_name"
        echo "$dir/$new_name"
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -lt "${#options[@]}" ]; then
        echo "$dir/${options[$choice]}"
    else
        echo "$choice"
    fi
}

# 1. Setup Spectra link
echo "" >&2
echo "--- Step 1: Setting up 'Spectra' link ---" >&2
SPECTRA_TARGET=$(select_from_dir "$SPECTRUM_BASE" "Select Spectra source directory" "Spectra_train")

# 2. Setup All_CIFs link
echo "" >&2
echo "--- Step 2: Setting up 'All_CIFs' link ---" >&2
CIF_TARGET=$(select_from_dir "$CIF_BASE" "Select All_CIFs source directory" "All_CIFs_AlN_4_types")

# 3. Setup figure/real_data link
echo "" >&2
echo "--- Step 3: Setting up 'figure/real_data' link ---" >&2
FIGURE_TARGET=$(select_from_dir "$FIGURE_BASE" "Select figure/real_data source directory" "Spectra_train")
echo $FIGURE_TARGET
# Confirmation
echo ""
echo "Proposed Links:"
echo "  Spectra         -> $SPECTRA_TARGET"
echo "  All_CIFs        -> $CIF_TARGET"
echo "  figure/real_data -> $FIGURE_TARGET"
echo ""
read -p "Apply these changes? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Setup cancelled."
    exit 0
fi

# Execution
echo ""
echo "Creating symbolic links..."

# Novel-Space/Spectra
ln -snf "$SPECTRA_TARGET" "Spectra"
echo "  [OK] Created Spectra link."

# Novel-Space/All_CIFs
ln -snf "$CIF_TARGET" "All_CIFs"
echo "  [OK] Created All_CIFs link."

# Ensure figure directory exists
mkdir -p figure
# Novel-Space/figure/real_data
# The link is relative to Northern-Space/figure/
ln -snf "../$FIGURE_TARGET" "figure/real_data"
echo "  [OK] Created figure/real_data link."

echo ""
echo "Setup complete! Verifying links:"
ls -ld Spectra All_CIFs figure/real_data
