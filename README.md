# XRD-AutoAnalyzer-PyTorch 自动化分析工具箱

[简体中文](README.md) | [English](README_en.md)

本项目是一个基于 PyTorch 和卷积神经网络（CNN）的 X 射线衍射（XRD）自动化分析平台。它能够实现从晶体结构下载、合成数据增强、模型训练到实验图谱自动识别的全流程工作流。

---

## 1. 项目架构与安装

### 1.1 安装依赖
在项目根目录下执行以下命令完成环境安装：
```bash
pip install -e .
```

---

## 2. 🚀 快速开始 (Getting Started)

由于为了保持仓库整洁，本项目在 Git 中忽略了所有的符号链接、环境变量和本地数据集。首次使用（或重新克隆）后，请按照以下步骤初始化您的环境：

### Step 1: 配置 API 密钥
在 `Novel-Space/` 目录下创建一个名为 `.env` 的文件，并写入您的 Materials Project API 密钥：
```bash
# Novel-Space/.env
MP_API_KEY=您的真实API密钥
```

### Step 2: 初始化环境链接
在 `Novel-Space/` 目录下运行环境设置脚本。建议第一次使用时使用 `--init` 参数来准备 `temp` 工作区：
```bash
cd Novel-Space
./setup_links.sh --init
```
这会自动创建指向 `soft_link/` 的 `All_CIFs`、`Spectra` 和 `figure` 等符号链接，并确保它们指向干净、独立的实验区。

### Step 3: 开始数据采集推理
环境初始化后，您可以按顺序执行：
1. **下载结构**：`python src/download_mp.py`
2. **生成参考**：`python src/construct_xrd_model.py`
3. **运行模型**：`python src/run_CNN.py`

---

## 3. 环境管理：`setup_links.sh`

为了支持在多套数据集之间无缝切换，本项目提供了强大的环境管理脚本，支持 **交互模式** 与 **自动化初始化模式**。

### 3.1 基础用法
```bash
./setup_links.sh          # 交互式选择数据集
./setup_links.sh --init   # 自动化初始化 (重置环境)
```

### 3.2 功能特性
- **初始化模式 (--init)**：
    - **一键清空**：递归删除 `soft_link/All_CIFs/temp/`、`Spectra/temp/` 和 `figure/temp/` 目录下的所有残留内容。
    - **快速重置**：自动将所有软链接指向上述 `temp` 目录，适合开启全新的实验。
- **自动保存 (Auto-Preserve)**：
    - 在切换数据集或执行初始化前，脚本会自动检测当前 `Novel-Space/` 目录下是否存在非空的 `Models/` 或 `References/`。
    - 如果存在，脚本会先将其内容平移至当前的 `All_CIFs` 目标备份目录中，防止模型权重或参考相数据被意外覆盖。
- **状态恢复 (Auto-Restore)**：
    - 当您切回之前使用过的数据集时，相应的模型和参考数据会被自动链接回工作区。
- **原子化替换**：
    - 脚本在创建链接前会先执行 `rm -rf`，确保软链接不会错误地嵌套在已存在的同名目录中。

---

## 4. 核心工作流

### 4.1 数据准备：`src/download_mp.py`
从 Materials Project 下载指定 ID 的晶体结构.
```bash
python src/download_mp.py
```
*提示：下载的 CIF 会自动保存到当前选定的 `All_CIFs/` 目录中。*

### 4.2 训练阶段：`src/construct_xrd_model.py`
基于 `All_CIFs/` 中的结构生成增强的模拟谱图并训练 CNN 模型。
```bash
python src/construct_xrd_model.py --num_spectra=50 --num_epochs=50 --save
```
- `--save`: 同步保存生成的增强数据集 `XRD.npy`。
- **输出**: 根目录下生成 `Model.pth`。

### 4.3 推理阶段：`src/run_CNN.py`
对 `Spectra/` 中的实验数据进行相位识别。
```bash
python src/run_CNN.py --plot --weights
```
- `--plot`: 自动生成实验谱与匹配相的对比图。
- `--weights`: 执行定量分析，输出质量分数。
- **输出**: 生成 `result.csv`。

---

## 5. 辅助工具箱

| 脚本 | 功能描述 |
| :--- | :--- |
| `src/construct_pdf_model.py` | 训练针对 PDF (Pair Distribution Function) 的模型。 |
| `src/plot_real_spectra.py` | 将所有实验谱图标准化并批量输出为可视化 PNG 图像。 |
| `src/make_gifs.py` | 将 `figure/` 下的时间序列图像合成动态 GIF 动画。 |
| `src/process_results.py` | 对 `result.csv` 进行后处理，筛选指定的主要物质标签。 |
| `src/extract_ranges.py` | 扫描 `Spectra/` 目录，输出所有实验数据的 2-theta 覆盖范围。|
| `src/generate_theoretical_spectra.py` | 基于 CIF 计算理论精确的 XRD 谱，作为识别参考。 |

---

## 6. 开发者备注：路径自动化

本项目所有的 Python 脚本都具备 **Path-Agnostic** 特性。
- 脚本头部集成了自动解析逻辑，无论您是在项目根目录还是 `Novel-Space/` 目录下运行，脚本都会自动将工作路径定位到 `Novel-Space/`。
- 这确保了如 `All_CIFs/` 或 `Models/` 等相对路径在任何运行环境下都能被正确访问。

---

## 7. 关联项目
- [XRD-1.0](https://github.com/tacmon/XRD-1.0)：原始版本。
- [XRD-1.1](https://github.com/tacmon/XRD-1.1)：当前优化版，增强了路径管理与数据集自动化。
