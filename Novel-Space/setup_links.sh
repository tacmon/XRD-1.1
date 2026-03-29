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

# --- Initialization Block ---
INIT_MODE=false
if [[ "$1" == "init" || "$1" == "--init" ]]; then
    INIT_MODE=true
    echo "[Mode: INITIALIZATION]"
fi

# --- Data Preservation (Save current Models/References before switching) ---
if [ -L "All_CIFs" ]; then
    CURRENT_CIF_TARGET=$(readlink "All_CIFs")
    # Migrate Models if it's a non-empty directory
    if [ -d "Models" ] && [ ! -L "Models" ]; then
        if [ "$(ls -A Models 2>/dev/null)" ]; then
            echo "  [INFO] Preserving Models to $CURRENT_CIF_TARGET/Models"
            mkdir -p "$CURRENT_CIF_TARGET/Models"
            mv Models/* "$CURRENT_CIF_TARGET/Models/" 2>/dev/null
        fi
        rm -rf Models
    fi
    # Migrate References if it's a non-empty directory
    if [ -d "References" ] && [ ! -L "References" ]; then
        if [ "$(ls -A References 2>/dev/null)" ]; then
            echo "  [INFO] Preserving References to $CURRENT_CIF_TARGET/References"
            mkdir -p "$CURRENT_CIF_TARGET/References"
            mv References/* "$CURRENT_CIF_TARGET/References/" 2>/dev/null
        fi
        rm -rf References
    fi
fi

# --- Resolution of Targets ---
if [ "$INIT_MODE" = true ]; then
    # 1. Ensure base directories and temp folders exist
    echo "  [INIT] Ensuring directory structure exists in $BASE_DIR/..."
    mkdir -p "$SPECTRUM_BASE/temp"
    mkdir -p "$CIF_BASE/temp"
    mkdir -p "$FIGURE_BASE/temp"

    # 2. Clear temp directories
    echo "  [CLEAN] Clearing contents of temp directories..."
    rm -rf "$SPECTRUM_BASE/temp"/*
    rm -rf "$CIF_BASE/temp"/*
    rm -rf "$FIGURE_BASE/temp"/*
    
    # 3. Set targets to temp
    SPECTRA_TARGET="$SPECTRUM_BASE/temp"
    CIF_TARGET="$CIF_BASE/temp"
    FIGURE_TARGET="$FIGURE_BASE/temp"
else
    # 1. Setup Spectra link
    echo "" >&2
    echo "--- Step 1: Setting up 'Spectra' link ---" >&2
    SPECTRA_TARGET=$(select_from_dir "$SPECTRUM_BASE" "Select Spectra source directory" "temp")

    # 2. Setup All_CIFs link
    echo "" >&2
    echo "--- Step 2: Setting up 'All_CIFs' link ---" >&2
    CIF_TARGET=$(select_from_dir "$CIF_BASE" "Select All_CIFs source directory" "temp")

    # 3. Setup figure/real_data link
    echo "" >&2
    echo "--- Step 3: Setting up 'figure/real_data' link ---" >&2
    FIGURE_TARGET=$(select_from_dir "$FIGURE_BASE" "Select figure/real_data source directory" "temp")

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
fi

# --- Link Application ---
echo ""
echo "Creating symbolic links..."

# Essential Fix: Always rm -rf before linking to prevent subdirectory linking or broken link issues
rm -rf "Spectra"
ln -snf "$SPECTRA_TARGET" "Spectra"
echo "  [OK] Created Spectra link."

rm -rf "All_CIFs"
ln -snf "$CIF_TARGET" "All_CIFs"
echo "  [OK] Created All_CIFs link."

# Novel-Space/Models and References: only link if they exist in the target
rm -rf "Models"
if [ -d "$CIF_TARGET/Models" ]; then
    ln -snf "$CIF_TARGET/Models" "Models"
    echo "  [OK] Linked existing Models from $CIF_TARGET."
else
    echo "  [INFO] No existing Models for this CIF group."
fi

rm -rf "References"
if [ -d "$CIF_TARGET/References" ]; then
    ln -snf "$CIF_TARGET/References" "References"
    echo "  [OK] Linked existing References from $CIF_TARGET."
else
    echo "  [INFO] No existing References for this CIF group."
fi

# Ensure figure directory exists
mkdir -p figure
rm -rf "figure/real_data"
# The link is relative to Northern-Space/figure/
ln -snf "../$FIGURE_TARGET" "figure/real_data"
echo "  [OK] Created figure/real_data link."

echo ""
echo "Setup complete! Verifying links:"
ls -ld Spectra All_CIFs Models References figure/real_data 2>/dev/null
