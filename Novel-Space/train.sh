#!/bin/bash

# Configuration
# This script assumes it is run from the 'Novel-Space/' directory
BASE_DIR=$(pwd)
SRC_DIR="src"

echo "=== XRD-AutoAnalyzer: Training Workflow ==="

# 1. Environment Check
if [ ! -d "$SRC_DIR" ]; then
    echo "Error: 'src/' directory not found. Please run this script from 'Novel-Space/'."
    exit 1
fi

# 2. Cleanup current CIFs
echo "Step 1: Cleaning up current dataset in All_CIFs/..."
rm -rf All_CIFs/*
echo "  [OK] All_CIFs directory is now empty."

# 3. Interactive Download Loop
echo ""
echo "Step 2: Preparing to download crystal structures (CIFs) from Materials Project."
echo "Please have your MP-IDs ready (e.g., mp-1, mp-661)."

while true; do
    echo ""
    read -p "Do you want to download a new CIF via Materials Project? [Y/n]: " choice
    choice=${choice:-Y} # Default to Y

    if [[ "$choice" =~ ^[Nn]$ ]]; then
        echo "Finished downloading structures."
        break
    fi

    # Run the download script
    # Note: download_mp.py will prompt for the ID
    python3 "$SRC_DIR/download_mp.py"
    
    if [ $? -ne 0 ]; then
        echo "  [Warning] Download script returned an error. Please check your API key and MP-ID."
    fi
done

# Check if we actually have any CIFs before training
if [ ! "$(ls -A All_CIFs 2>/dev/null)" ]; then
    echo "Error: No CIF files found in All_CIFs/. Cannot proceed with training."
    exit 1
fi

# 4. Model Training
echo ""
echo "Step 3: Starting XRD Model Training..."
echo "  (This will simulate 50 spectra per phase and save XRD.npy)"
python3 "$SRC_DIR/construct_xrd_model.py" --num_spectra=50 --save

if [ $? -eq 0 ]; then
    echo "  [OK] XRD Model training complete."
else
    echo "  [Error] XRD Model training failed."
    exit 1
fi

echo ""
echo "Step 4: Starting PDF Model Training..."
python3 "$SRC_DIR/construct_pdf_model.py"

if [ $? -eq 0 ]; then
    echo "  [OK] PDF Model training complete."
else
    echo "  [Error] PDF Model training failed."
    exit 1
fi

echo ""
echo "=== Training Workflow Complete! ==="
echo "Models and References are now ready for inference."
