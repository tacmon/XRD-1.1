# XRD-AutoAnalyzer-PyTorch 脚本使用说明

本文档介绍了 `Novel-Space` 目录下 Python 脚本的功能和运行方法，该系统利用卷积神经网络（CNN）对 X 射线衍射（XRD）图谱进行自动化物相识别和量化分析。

参考代码：[https://github.com/morethankk/XRD-AutoAnalyzer-PyTorch-full](https://github.com/morethankk/XRD-AutoAnalyzer-PyTorch-full)

## 1. 结构与安装

建议在环境根目录下运行以下命令以安装依赖库（如果尚未安装）：
```bash
pip install -e .
```

所有的主要脚本均位于 `Novel-Space/` 目录下。运行前请务必先进入该文件夹：
```bash
cd Novel-Space
```

### 1.1 环境初始化与软链接设置
为了方便管理不同的数据集和输出路径，项目提供了一个自动化脚本 `setup_links.sh`。该脚本会引导您设置 `Spectra`、`All_CIFs` 和 `figure/real_data` 的软链接。

**运行方法**：
```bash
./setup_links.sh
```
按照提示选择对应的目标文件夹（例如 `soft_link/Spectra_train`）即可完成配置。

## 2. 核心脚本介绍

### (1) `download_mp.py`
**功能**：从 Materials Project 数据库下载指定材料的 CIF 晶体结构文件。
**用法**：
```bash
python download_mp.py
```
- 运行后会有交互式提示 `输入ID：`，输入 MP ID（如 `1234` 代表 `mp-1234`）。
- 默认保存到 `All_CIFs/` 目录。

### (2) `construct_xrd_model.py`
**功能**：生成扩增的虚拟 XRD 图谱训练集，并训练一个基于 PyTorch 的 CNN 模型。
**用法**：
```bash
python construct_xrd_model.py [选项]
```
- **重要选项**：
  - `--num_spectra=N`：每个物相生成的模拟图谱数（默认 50）。
  - `--num_epochs=N`：训练轮数（默认 50）。
  - `--min_angle=N` / `--max_angle=N`：2-theta 范围（默认 20.0 - 60.0）。
- **输出**：训练好的模型文件 `Model.pth`。

### (3) `construct_pdf_model.py`
**功能**：生成模拟的对分布函数（PDF）图谱，并训练独立的 PDF-CNN 模型。
**用法**：
```bash
python construct_pdf_model.py [选项]
```
- **前提**：目录下需已存在 `Model.pth`，脚本会将其重命名并存放到 `Models/` 目录。

### (4) `run_CNN.py`
**功能**：使用训练好的 PyTorch 模型，对 `Spectra/` 目录下的测试图谱进行晶相识别和推断。
**用法**：
```bash
python run_CNN.py [选项]
```
- **重要选项**：
  - `--max_phases=N`：最大识别物相数（默认 3）。
  - `--min_conf=N`：最低置信度阈值（默认 40.0）。
  - `--inc_pdf`：结合 PDF 模型进行集成预测。
  - `--plot`：显示物相匹配的可视化图表。
  - `--weights`：输出预测物相的质量分数。
- **输出**：预测结果保存至 `result.csv`。

## 3. 辅助与工具脚本

### (5) `generate_theoretical_spectra.py`
**功能**：基于 `References/` 中的 CIF 生成平滑的理论 XRD 参考图谱。
**用法**：
```bash
python generate_theoretical_spectra.py
```

### (6) `plot_real_spectra.py`
**功能**：读取 `Spectra/` 下的所有实验数据，按模型基准（如 20-60°, 4501点）进行插值对齐 and 归一化，并输出可视化曲线。
**用法**：
```bash
python plot_real_spectra.py
```
- **输出**：图像保存在 `figure/real_data/` 目录下。

### (7) `extract_sample_from_npy.py`
**功能**：从 `XRD.npy` 训练数据中提取特定的物相（如 CrSiTe3, AlN, Si 等）原始图谱样本，并保存为 `.txt` 格式到 `Spectra/` 目录下。这通常用于验证模型对于训练集中“已知”数据的识别精度。
**用法**：
```bash
python extract_sample_from_npy.py
```
- **注意**：需要在脚本中修改 `indices` 或变量以针对不同的物相进行提取。
- **输出**：`.txt` 数据文件保存在 `Spectra/` 目录下。

### (8) `make_gifs.py`
**功能**：将 `figure/real_data/` 子目录下的多张图谱（如 AlN, BST, CST 等）自动合成为动态 GIF，便于观察识别过程或物相变化。
**用法**：
```bash
python make_gifs.py
```
- **输出**：生成的 GIF 文件保存在 `figure/real_data/gif/` 目录下。

## 4. 典型工作流示例

为了确保系统正确运行，建议遵循以下流程：

1. **进入工作目录**：`cd Novel-Space`
2. **准备参考文件**：将相关的 CIF 文件放置于 `References/` 或使用 `download_mp.py` 获取。
3. **训练模型**：运行 `python construct_xrd_model.py` 生成训练模型 `Model.pth`。
4. **准备待测数据**：确保实验图谱以 `.txt` 或 `.xy` 格式存放在 `Spectra/` 目录下（或其链接的实际目录）。
5. **执行预测**：运行 `python run_CNN.py --plot` 进行晶相识别，并生成包含可视化对比图的 `result.csv`。
6. **分析与可视化**：
   - 运行 `python plot_real_spectra.py` 预备并导出所有待测数据的曲线。
   - 运行 `python make_gifs.py` 合成动态图，直观对比识别效果。
7. **数据提取（可选）**：运行 `python extract_sample_from_npy.py` 提取训练集内样本供对比分析。

---
> [!IMPORTANT]
> 如果遇到问题，请确保在“次级目录”运行，即 `Novel-Space` 目录或者 `Example` 目录，而不是项目根目录。


## 5. 关联项目

本项目是系列工具的一部分，您可以点击下方链接跳转到其他版本：

- [XRD-1.0](https://github.com/tacmon/XRD-1.0)：初始版本，包含完整的辅助脚本和数据处理工具。
- [XRD-1.1](https://github.com/tacmon/XRD-1.1)：（当前项目）精简版，优化了脚本结构并增加了环境自动初始化工作流。


