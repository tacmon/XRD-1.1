import numpy as np
import os

# Define paths
data_path = "/root/xrd/XRD-1.0/Novel-Space/XRD.npy"
spectra_dir = "/root/xrd/XRD-1.0/Novel-Space/Spectra"
min_angle = 20.0
max_angle = 60.0
num_points = 4501

# Load data
data = np.load(data_path, allow_pickle=True)
print(data.shape)
# data shape is (2, 250, 4501, 1)
# data[0] is CrSiTe3 (alphabetically first)
# data[1] is Si

# Generate angles
angles = np.linspace(min_angle, max_angle, num_points)

# Extract 3 samples from CrSiTe3
# I'll take a few different indices to be representative
indices = [0, 100, 200]

for i, idx in enumerate(indices):
    spectrum = data[2][idx, :, 0]
    filename = os.path.join(spectra_dir, f"AlN_3_extracted_{i+1}.txt")
    
    # Save in the same format as existing files: angle  intensity
    # Using tab separation and 5-8 decimal places
    np.savetxt(filename, np.column_stack((angles, spectrum)), fmt='%.8f\t%.8f')
    print(f"Saved {filename}")

print("Done! Extracted 3 CrSiTe3 spectra from training data.")
