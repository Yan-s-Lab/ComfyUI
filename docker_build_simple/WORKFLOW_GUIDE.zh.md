# ComfyUI Docker Workflow预设使用指南

## 🚀 快速开始

本Docker镜像预设了Flux Dev和SD3.5两个高质量的workflow模板，让您无需复杂配置即可快速开始使用ComfyUI。

## 📦 启动容器

```bash
# 启动容器（使用GPU）
docker run -p 8188:8188 --gpus all your-comfyui-image
```

启动后访问：http://localhost:8188

## 🎨 使用预设Workflow

### 方法一：通过Workflow Browser（推荐）

1. **打开Workflow Browser**
   - 在ComfyUI界面左上角点击 **"Workflow"** 菜单
   - 选择 **"Browse Templates"**

2. **选择预设模板**
   - 在弹出的对话框中找到 **"ComfyUI-Example-Workflows"** 分类
   - 您会看到两个预设模板：
     - `flux_dev` - Flux Dev模型workflow
     - `sd3.5_text_encoders_example` - SD3.5模型workflow

3. **加载Workflow**
   - 点击任意一个workflow模板
   - 页面会自动加载并显示完整的可视化节点图

### 方法二：拖拽图片加载

1. 在左侧文件浏览器中找到 `input` 目录
2. 将以下图片拖拽到工作区：
   - `flux_dev.png` - 包含Flux workflow的元数据图片
   - `sd3.5.png` - 包含SD3.5 workflow的元数据图片
3. ComfyUI会自动解析图片中的workflow信息并加载

### 方法三：文件选择加载

1. 使用快捷键 `Ctrl + O` 打开文件选择对话框
2. 导航到 `/root/user/default/workflows/` 目录
3. 选择对应的JSON文件：
   - `flux_dev.json`
   - `sd3.5_text_encoders_example.json`

## ⚙️ 自定义和配置

### 1. 修改提示词（Prompt）
- 在workflow中找到文本输入节点
- 修改 `positive prompt` 和 `negative prompt`
- 根据您的创作需求调整描述文字

### 2. 调整节点参数
- 点击任意节点查看和修改参数
- 常见可调整参数：
  - 图像尺寸（width/height）
  - 采样步数（steps）
  - CFG Scale
  - 种子值（seed）

### 3. 自定义节点流程
- **添加节点**：右键点击空白区域选择要添加的节点
- **连接节点**：拖拽节点输出端口到其他节点的输入端口
- **删除连接**：点击连接线然后按Delete键
- **重新排列**：拖拽节点到合适位置

## 📁 模型文件配置

### ⚠️ 重要提示
预设workflow中的模型和CLIP需要您手动下载并放置到正确位置。

### Flux Dev Workflow所需文件

1. **主模型文件**
   ```bash
   # 下载flux-dev模型到checkpoints目录
   sudo mv flux-dev.safetensors /root/models/checkpoints/
   ```

2. **CLIP文件**
   ```bash
   # 下载并移动CLIP文件
   sudo mv t5xxl_fp16.safetensors /root/models/clip/
   sudo mv clip_l.safetensors /root/models/clip/
   ```

### SD3.5 Workflow所需文件

1. **主模型文件**
   ```bash
   # 下载SD3.5模型到checkpoints目录
   sudo mv sd3.5_large.safetensors /root/models/checkpoints/
   ```

2. **文本编码器文件**
   ```bash
   # 下载并移动文本编码器文件
   sudo mv clip_l.safetensors /root/models/clip/
   sudo mv clip_g.safetensors /root/models/clip/
   sudo mv t5xxl_fp16.safetensors /root/models/clip/
   ```

### 文件权限注意事项

**必须使用 `sudo` 命令移动文件**，否则会出现权限问题：

```bash
# ✅ 正确方式
sudo mv model_file.safetensors /root/models/checkpoints/

# ❌ 错误方式（会导致权限错误）
mv model_file.safetensors /root/models/checkpoints/
```

## 📂 目录结构说明

```
/root/
├── input/                          # 带元数据的图片文件
│   ├── flux_dev.png               # Flux workflow图片
│   └── sd3.5.png                  # SD3.5 workflow图片
├── user/default/workflows/         # JSON workflow文件
│   ├── flux_dev.json              # Flux workflow JSON
│   └── sd3.5_text_encoders_example.json  # SD3.5 workflow JSON
├── models/                         # 模型文件目录
│   ├── checkpoints/               # 主模型文件
│   ├── clip/                      # CLIP和文本编码器
│   ├── vae/                       # VAE文件
│   └── ...
└── ComfyUI/custom_nodes/
    └── ComfyUI-Example-Workflows/ # API模板目录
        └── example_workflows/
            ├── flux_dev.json
            └── sd3.5_text_encoders_example.json
```

## 🔧 故障排除

### 模型文件未找到
- **问题**：节点显示红色，提示找不到模型文件
- **解决**：确认模型文件已下载并使用 `sudo` 移动到正确目录

### 权限错误
- **问题**：无法访问模型文件
- **解决**：使用 `sudo chown -R root:root /root/models/` 修复权限

### 内存不足
- **问题**：生成图片时出现内存错误
- **解决**：
  - 降低图像分辨率
  - 减少批次大小
  - 使用 `--lowvram` 或 `--cpu` 参数启动

### Workflow加载失败
- **问题**：点击模板后没有反应
- **解决**：
  - 刷新浏览器页面
  - 检查浏览器控制台是否有错误信息
  - 确认容器正常运行

## 📖 参考资源

- **模型下载**：
  - Flux Dev: [Hugging Face](https://huggingface.co/black-forest-labs/FLUX.1-dev)
  - SD3.5: [Hugging Face](https://huggingface.co/stabilityai/stable-diffusion-3.5-large)

- **ComfyUI文档**：[官方文档](https://github.com/comfyanonymous/ComfyUI)

## 💡 使用技巧

1. **保存自定义workflow**：修改后使用 `Ctrl + S` 保存您的自定义workflow
2. **分享workflow**：生成的图片包含完整workflow信息，可直接分享给他人
3. **批量生成**：调整批次大小参数可一次生成多张图片
4. **实验参数**：尝试不同的采样器和参数组合获得最佳效果

---

🎉 **开始您的AI艺术创作之旅吧！** 如有问题，请检查上述故障排除部分或查阅相关文档。

本Docker镜像预设了多个高质量的workflow示例，让您无需复杂配置即可快速开始使用ComfyUI。

## 预设的Workflow

### 1. Flux Dev Workflow
- **文件**: `flux_dev.json`
- **模型**: Flux Dev
- **功能**: 高质量图像生成
- **特点**: 支持详细的文本提示，生成质量优秀

### 2. SD3.5 Text Encoders Workflow  
- **文件**: `sd3.5_text_encoders_example.json`
- **模型**: Stable Diffusion 3.5
- **功能**: 多文本编码器图像生成
- **特点**: 更好的文本理解和图像质量

## 使用方法

### 方法一：拖拽图片加载（推荐）

1. 启动ComfyUI后，打开Web界面 (http://localhost:8188)
2. 在左侧文件浏览器中找到 `input` 目录
3. 将预设的PNG图片（如 `flux_dev.png`, `sd3.5.png`）直接拖拽到工作区
4. ComfyUI会自动解析图片中的workflow元数据并加载完整的工作流

### 方法二：JSON文件加载

1. 使用快捷键 `Ctrl + O` 打开文件选择对话框
2. 导航到 `/root/user/default/workflows/` 目录
3. 选择需要的JSON文件（如 `flux_dev.json`）
4. 点击加载即可

### 方法三：API模板访问

1. 访问API端点: `http://localhost:8188/workflow_templates`
2. 查看可用的workflow模板列表
3. 通过API调用获取具体的workflow内容

## 文件位置说明

```
/root/
├── input/                          # 带元数据的图片文件
│   ├── flux_dev.png               # Flux workflow图片
│   └── sd3.5.png                  # SD3.5 workflow图片
├── user/default/workflows/         # JSON workflow文件
│   ├── flux_dev.json              # Flux workflow JSON
│   └── sd3.5_text_encoders_example.json  # SD3.5 workflow JSON
└── ComfyUI/custom_nodes/
    └── ComfyUI-Example-Workflows/ # API模板目录
        ├── flux_dev.json
        ├── sd3.5_text_encoders_example.json
        └── meta_data_images/
            ├── flux_dev.png
            └── sd3.5.png
```

## 快速开始

1. **启动容器**:
   ```bash
   docker run -p 8188:8188 your-comfyui-image
   ```

2. **访问Web界面**: 
   打开浏览器访问 `http://localhost:8188`

3. **加载预设workflow**:
   - 最简单：直接拖拽 `input` 目录中的PNG图片到工作区
   - 或者使用 `Ctrl + O` 加载JSON文件

4. **开始创作**:
   - 修改提示词
   - 调整参数
   - 点击"Queue Prompt"生成图像

## 注意事项

- 首次使用需要下载对应的模型文件
- 确保有足够的GPU内存运行所选模型
- 可以根据需要修改workflow参数
- 生成的图片会自动保存workflow信息，方便分享

## 自定义Workflow

您可以：
1. 修改现有workflow并保存
2. 创建新的workflow
3. 将自己的workflow图片放入 `input` 目录
4. 将JSON文件放入 `user/default/workflows/` 目录

## 故障排除

- **模型未找到**: 检查模型文件是否正确下载到 `models` 目录
- **内存不足**: 尝试降低批次大小或图像分辨率
- **workflow加载失败**: 确认JSON文件格式正确且所需节点已安装

## 技术支持

如有问题，请检查：
1. Docker容器日志
2. ComfyUI控制台输出
3. 模型文件完整性
4. 网络连接状态
