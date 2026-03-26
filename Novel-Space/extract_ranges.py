import os
import csv

def extract_angle_ranges(directory, output_file):
    results = []
    files = [f for f in os.listdir(directory) if f.endswith('.txt')]
    files.sort()

    for filename in files:
        filepath = os.path.join(directory, filename)
        angles = []
        try:
            with open(filepath, 'r') as f:
                for line in f:
                    parts = line.split()
                    if len(parts) >= 1:
                        try:
                            angle = float(parts[0])
                            angles.append(angle)
                        except ValueError:
                            continue
            if angles:
                results.append({
                    'filename': filename,
                    'min_angle': min(angles),
                    'max_angle': max(angles)
                })
        except Exception as e:
            print(f"Error processing {filename}: {e}")

    with open(output_file, 'w', newline='') as csvfile:
        fieldnames = ['filename', 'min_angle', 'max_angle']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in results:
            writer.writerow(row)

if __name__ == "__main__":
    spectra_dir = "./Spectra"
    output_path = "./angle_ranges.csv"
    extract_angle_ranges(spectra_dir, output_path)
    print(f"Results saved to {output_path}")
