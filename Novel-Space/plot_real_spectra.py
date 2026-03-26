"""
plot_real_spectra.py
====================
读取 ./Novel-Space/Spectra 中的所有测试数据，
复用 run_xrd_model.py 中的插值和归一化处理（对齐到 20-60度，4501个点），
并将其输出为曲线形图表，保存在 ./Novel-Space/figure/real_data 下面。

用法：
    cd /root/xrd/XRD-1.0/Novel-Space
    python plot_real_spectra.py
"""

import os
import sys

os.environ["OMP_NUM_THREADS"] = "1"
os.environ["OPENBLAS_NUM_THREADS"] = "1"
os.environ["MKL_NUM_THREADS"] = "1"

import numpy as np
import joblib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

script_dir = os.path.dirname(os.path.abspath(__file__))

def load_spectrum(filepath, angle_grid):
    """
    与 run_xrd_model.py 相同的读取和预处理逻辑
    """
    data = np.loadtxt(filepath)

    # 兼容单列（仅强度）和双列（角度 + 强度）格式
    if data.ndim == 1:
        intensity_raw = data.astype(float)
        if len(intensity_raw) == len(angle_grid):
            intensity_interp = intensity_raw
        else:
            from scipy.signal import resample
            intensity_interp = resample(intensity_raw, len(angle_grid))
    else:
        angles    = data[:, 0].astype(float)
        intensity = data[:, 1].astype(float)

        mask = (angles >= angle_grid[0] - 0.1) & (angles <= angle_grid[-1] + 0.1)
        angles    = angles[mask]
        intensity = intensity[mask]

        if len(angles) < 2:
            raise ValueError(f"文件 {filepath} 中有效角度范围内数据点不足。")

        intensity_interp = np.interp(angle_grid, angles, intensity)

    # 最大值归一化
    max_val = intensity_interp.max()
    if max_val > 0:
        intensity_interp = intensity_interp / max_val

    return intensity_interp

def main():
    os.chdir(script_dir)
    
    spectra_dir = "Spectra"
    model_path = "Model_ML.pkl"
    out_dir = os.path.join("figure", "real_data")
    
    if not os.path.exists(spectra_dir):
        print(f"[ERROR] 找不到目录: {spectra_dir}")
        return
        
    if not os.path.exists(model_path):
        print(f"[ERROR] 找不到模型 {model_path}，无法获取角度基准网格。")
        return
        
    os.makedirs(out_dir, exist_ok=True)
    
    print(f"[INFO] 正在获取基准网格配置 {model_path} ...")
    bundle = joblib.load(model_path)
    min_angle = bundle['min_angle']
    max_angle = bundle['max_angle']
    n_points = bundle['n_points']
    
    angle_grid = np.linspace(min_angle, max_angle, n_points)
    
    spectrum_files = sorted([
        f for f in os.listdir(spectra_dir)
        if f.lower().endswith('.txt') or f.lower().endswith('.xy')
    ])
    
    print(f"[INFO] 找到 {len(spectrum_files)} 个真实光谱文件，开始画图...")
    
    success_count = 0
    for fname in spectrum_files:
        fpath = os.path.join(spectra_dir, fname)
        try:
            # 执行插值 + 归一化
            spec_interp = load_spectrum(fpath, angle_grid)
            
            fig, ax = plt.subplots(figsize=(8, 4))
            ax.plot(angle_grid, spec_interp, color='darkorange', linewidth=1.2)
            ax.set_xlim(min_angle, max_angle)
            ax.set_ylim(-0.05, 1.05)
            ax.set_xlabel('2θ (degree)')
            ax.set_ylabel('Normalized Intensity')
            ax.set_title(f'Real Measured XRD: {fname} (Interpolated)')
            
            plt.tight_layout()
            out_path = os.path.join(out_dir, fname.replace('.txt', '.png').replace('.xy', '.png'))
            fig.savefig(out_path, dpi=120)
            plt.close(fig)
            
            success_count += 1
            if success_count % 5 == 0:
                print(f"  ...已完成 {success_count}/{len(spectrum_files)} 张图")
                
        except Exception as e:
            print(f"[WARNING] 处理文件 {fname} 时出错: {e}")
            
    print(f"\n[DONE] 真实数据的预处理光谱图均已保存！")
    print(f"       共输出 {success_count} 张图像存放到: {os.path.abspath(out_dir)}")

if __name__ == '__main__':
    main()
