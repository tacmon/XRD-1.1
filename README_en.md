# XRD-AutoAnalyzer-PyTorch Automated Analysis Toolbox

[English](README_en.md) | [简体中文](README.md)

This project is an automated analysis platform for X-ray Diffraction (XRD) based on PyTorch and Convolutional Neural Networks (CNN). It provides a full workflow covering crystal structure downloading, synthetic data augmentation, model training, and automated phase identification from experimental patterns.

---

## 1. Project Architecture and Installation

### 1.1 Installation
Execute the following command in the project root directory to install the environment:
```bash
pip install -e .
```

---

## 2. 🚀 Quick Start (Getting Started)

To keep the repository clean, all symbolic links, environment variables, and local datasets are ignored by Git. After the initial clone (or re-cloning), follow these steps to initialize your environment:

### Step 1: Configure API Key
Create a file named `.env` in the `Novel-Space/` directory and add your Materials Project API key:
```bash
# Novel-Space/.env
MP_API_KEY=your_actual_api_key_here
```

### Step 2: Initialize Environment Links
Run the environment setup script in the `Novel-Space/` directory. For the first-time setup, it is recommended to use the `--init` parameter to prepare the `temp` workspace:
```bash
cd Novel-Space
./setup_links.sh --init
```
This will automatically create symbolic links such as `All_CIFs`, `Spectra`, and `figure` pointing to the `soft_link/` storage, ensuring a clean and independent experimental area.

### Step 3: Start Data Acquisition and Inference
Once the environment is initialized, you can execute the following in order:
1. **Download Structures**: `python src/download_mp.py`
2. **Construct Reference/Model**: `python src/construct_xrd_model.py`
3. **Run Inference**: `python src/run_CNN.py`

---

## 3. Environment Management: `setup_links.sh`

To support seamless transitions between multiple datasets, this project provides a powerful environment management script that supports both **Interactive Mode** and **Automated Initialization Mode**.

### 3.1 Basic Usage
```bash
./setup_links.sh          # Interactively select datasets
./setup_links.sh --init   # Automated initialization (Reset environment)
```

### 3.2 Key Features
- **Initialization Mode (--init)**:
    - **One-Click Cleanup**: Recursively deletes all contents in `soft_link/All_CIFs/temp/`, `Spectra/temp/`, and `figure/temp/`.
    - **Quick Reset**: Automatically points all symbolic links to these `temp` directories, ideal for starting fresh experiments.
- **Auto-Preserve**:
    - Before switching datasets or executing initialization, the script checks for non-empty `Models/` or `References/` directories in the local `Novel-Space/`.
    - If found, it migrates their contents to the current `All_CIFs` target backup directory to prevent accidental data loss.
- **Auto-Restore**:
    - When switching back to a previously used dataset, the corresponding models and reference data are automatically re-linked to the workspace.
- **Atomic Replacement**:
    - The script executes `rm -rf` before creating links, ensuring symlinks are never incorrectly nested inside existing directories.

---

## 4. Core Workflow

### 4.1 Data Preparation: `src/download_mp.py`
Download crystal structures from the Materials Project using specific IDs.
```bash
python src/download_mp.py
```
*Tip: Downloaded CIFs are automatically saved to the currently selected `All_CIFs/` directory.*

### 4.2 Training Phase: `src/construct_xrd_model.py`
Generate augmented synthetic spectra based on structures in `All_CIFs/` and train the CNN model.
```bash
python src/construct_xrd_model.py --num_spectra=50 --num_epochs=50 --save
```
- `--save`: Simultaneously saves the augmented dataset `XRD.npy`.
- **Output**: Generates `Model.pth` in the root directory.

### 4.3 Inference Phase: `src/run_CNN.py`
Perform phase identification on experimental data in `Spectra/`.
```bash
python src/run_CNN.py --plot --weights
```
- `--plot`: Automatically generates comparison plots between experimental patterns and matching phases.
- `--weights`: Performs quantitative analysis and outputs mass fractions.
- **Output**: Generates `result.csv`.

---

## 5. Auxiliary Toolbox

| Script | Description |
| :--- | :--- |
| `src/construct_pdf_model.py` | Trains models specifically for PDF (Pair Distribution Function). |
| `src/plot_real_spectra.py` | Normalizes all experimental patterns and batch outputs them as PNG images. |
| `src/make_gifs.py` | Compiles time-series images under `figure/` into animated GIFs. |
| `src/process_results.py` | Post-processes `result.csv` to filter for specific primary material labels. |
| `src/extract_ranges.py` | Scans `Spectra/` to output the 2-theta coverage ranges of all experimental data. |
| `src/generate_theoretical_spectra.py` | Calculates theoretically exact XRD patterns based on CIFs for reference identification. |

---

## 6. Developer Notes: Path Automation

Every Python script in this project is **Path-Agnostic**.
- Automated resolution logic is integrated into the script headers. Whether you run them from the project root or the `Novel-Space/` directory, the script will automatically set the working path to `Novel-Space/`.
- This ensures that relative paths like `All_CIFs/` or `Models/` are correctly accessed regardless of the execution environment.

---

## 7. Related Projects
- [XRD-1.0](https://github.com/tacmon/XRD-1.0): Original version.
- [XRD-1.1](https://github.com/tacmon/XRD-1.1): Current optimized version with enhanced path management and dataset automation.
