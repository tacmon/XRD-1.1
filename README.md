# XRD-AutoAnalyzer-PyTorch 自动化分析工具箱

本项目是一个基于 PyTorch 和卷积神经网络（CNN）的 X 射线衍射（XRD）自动化分析平台。它能够实现从晶体结构下载、合成数据增强、模型训练到实验图谱自动识别的全流程工作流。

---

## 1. 项目架构与安装

### 1.1 安装依赖
在项目根目录下执行以下命令完成环境安装：
```bash
pip install -e .
```

### 1.2 目录结构
经过优化，所有的执行脚本均存放在 `src/` 目录下，而数据与模型保持在工作区根部，结构如下：
```text
Novel-Space/
├── src/            # 所有 Python 执行脚本
├── All_CIFs -> ... # 当前使用的晶体结构库 (软链接)
├── Spectra -> ...  # 待测/训练图谱目录 (软链接)
├── Models -> ...   # 已训练的模型权重 (自动管理)
├── References -> ..# 生成的参考相数据 (自动管理)
├── figure/         # 可视化输出目录
└── setup_links.sh  # 环境初始化与数据集切换工具
```

---

## 2. 环境管理：`setup_links.sh`

为了支持在多套数据集（如不同的材料体系）之间无缝切换，本项目提供了强大的环境管理脚本。

**运行方法**：
```bash
./setup_links.sh
```

**功能特性**：
- **数据集切换**：快速更改 `Spectra` 和 `All_CIFs` 指向的目标文件夹。
- **自动保存 (Auto-Preserve)**：在切换数据集前，脚本会自动检测并移动当前工作区中的 `Models/` 和 `References/` 到对应的原始备份目录，防止模型被覆盖。
- **状态恢复 (Auto-Restore)**：当您切回之前训练过的数据集时，相应的模型和参考数据会被自动链接回工作区。

---

## 3. 核心工作流

### 3.1 数据准备：`src/download_mp.py`
从 Materials Project 下载指定 ID 的晶体结构。
```bash
python src/download_mp.py
```
*提示：下载的 CIF 会自动保存到当前选定的 `All_CIFs/` 目录中。*

### 3.2 训练阶段：`src/construct_xrd_model.py`
基于 `All_CIFs/` 中的结构生成增强的模拟谱图并训练 CNN 模型。
```bash
python src/construct_xrd_model.py --num_spectra=50 --num_epochs=50 --save
```
- `--save`: 同步保存生成的增强数据集 `XRD.npy`。
- **输出**: 根目录下生成 `Model.pth`。

### 3.3 推理阶段：`src/run_CNN.py`
对 `Spectra/` 中的实验数据进行相位识别。
```bash
python src/run_CNN.py --plot --weights
```
- `--plot`: 自动生成实验谱与匹配相的对比图。
- `--weights`: 执行定量分析，输出质量分数。
- **输出**: 生成 `result.csv`。

---

## 4. 辅助工具箱

| 脚本 | 功能描述 |
| :--- | :--- |
| `src/construct_pdf_model.py` | 训练针对 PDF (Pair Distribution Function) 的模型。 |
| `src/plot_real_spectra.py` | 将所有实验谱图标准化并批量输出为可视化 PNG 图像。 |
| `src/make_gifs.py` | 将 `figure/` 下的时间序列图像合成动态 GIF 动画。 |
| `src/process_results.py` | 对 `result.csv` 进行后处理，筛选指定的主要物质标签。 |
| `src/extract_ranges.py` | 扫描 `Spectra/` 目录，输出所有实验数据的 2-theta 覆盖范围。|
| `src/generate_theoretical_spectra.py` | 基于 CIF 计算理论精确的 XRD 谱，作为识别参考。 |

---

## 5. 开发者备注：路径自动化

本项目所有的 Python 脚本都具备 **Path-Agnostic** 特性。
- 脚本头部集成了自动解析逻辑，无论您是在项目根目录还是 `Novel-Space/` 目录下运行，脚本都会自动将工作路径定位到 `Novel-Space/`。
- 这确保了如 `All_CIFs/` 或 `Models/` 等相对路径在任何运行环境下都能被正确访问。

---

## 6. 关联项目
- [XRD-1.0](https://github.com/tacmon/XRD-1.0)：原始版本。
- [XRD-1.1](https://github.com/tacmon/XRD-1.1)：当前优化版，增强了路径管理与数据集自动化。
