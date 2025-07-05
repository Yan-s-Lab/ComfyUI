#!/bin/bash

# 最小化启动脚本

set -e

# 运行用户的配置代理脚本
cd /root
if [ ! -f "/root/user-scripts/set-proxy.sh" ] ; then
    mkdir -p /root/user-scripts
    cp /runner-scripts/set-proxy.sh.example /root/user-scripts/set-proxy.sh
else
    echo "[INFO] 执行配置代理脚本……"

    chmod +x /root/user-scripts/set-proxy.sh
    source /root/user-scripts/set-proxy.sh
fi ;

# 下载 ComfyUI 与 Manager，不下载扩展，不下载模型文件
cd /root
if [ ! -f "/root/.download-complete" ] ; then
    echo "########################################"
    echo "[INFO] 下载 ComfyUI & Manager..."
    echo "########################################"

    set +e

    git clone https://gh-proxy.com/https://github.com/comfyanonymous/ComfyUI.git || git -C ComfyUI pull --ff-only
    cd /root/ComfyUI
    git reset --hard "$(git tag | grep -e '^v' | sort -V | tail -1)"

    cd /root/ComfyUI/custom_nodes
    git clone --depth=1 https://gh-proxy.com/https://github.com/ltdrdata/ComfyUI-Manager.git || git -C ComfyUI-Manager pull --ff-only

    set -e

    # 设置 workflow 预设功能
    if [ -d "/root/ComfyUI-Example-Workflows" ]; then
        echo "[INFO] 设置预设 workflow 文件..."

        # 1. 创建正确的custom_nodes目录结构（API访问）
        mkdir -p /root/ComfyUI/custom_nodes/ComfyUI-Example-Workflows/example_workflows

        # 创建__init__.py文件使其成为有效的Python模块
        echo "# ComfyUI Example Workflows Module" > /root/ComfyUI/custom_nodes/ComfyUI-Example-Workflows/__init__.py

        if [ -f "/root/ComfyUI-Example-Workflows/flux_dev.json" ]; then
            # 复制到example_workflows子目录（用于workflow模板发现和API访问）
            cp /root/ComfyUI-Example-Workflows/flux_dev.json /root/ComfyUI/custom_nodes/ComfyUI-Example-Workflows/example_workflows/
        fi
        if [ -f "/root/ComfyUI-Example-Workflows/sd3.5_text_encoders_example.json" ]; then
            # 复制到example_workflows子目录（用于workflow模板发现和API访问）
            cp /root/ComfyUI-Example-Workflows/sd3.5_text_encoders_example.json /root/ComfyUI/custom_nodes/ComfyUI-Example-Workflows/example_workflows/
        fi

        # 2. 创建用户目录结构并复制JSON文件
        mkdir -p /root/user/default/workflows
        if [ -f "/root/ComfyUI-Example-Workflows/flux_dev.json" ]; then
            cp /root/ComfyUI-Example-Workflows/flux_dev.json /root/user/default/workflows/
        fi
        if [ -f "/root/ComfyUI-Example-Workflows/sd3.5_text_encoders_example.json" ]; then
            cp /root/ComfyUI-Example-Workflows/sd3.5_text_encoders_example.json /root/user/default/workflows/
        fi

        # 3. 复制带元数据的图片到input目录（拖拽加载）
        mkdir -p /root/input
        if [ -d "/root/ComfyUI-Example-Workflows/meta_data_images" ]; then
            cp /root/ComfyUI-Example-Workflows/meta_data_images/*.png /root/input/ 2>/dev/null || true
        fi

        echo "[INFO] Workflow 预设完成！"
        echo "  - JSON文件: /root/user/default/workflows/"
        echo "  - 元数据图片: /root/input/"
        echo "  - API模板: /root/ComfyUI/custom_nodes/ComfyUI-Example-Workflows/example_workflows/"
    fi

    touch /root/.download-complete
fi ;

# 运行用户的预启动脚本
cd /root
if [ ! -f "/root/user-scripts/pre-start.sh" ] ; then
    mkdir -p /root/user-scripts
    cp /runner-scripts/pre-start.sh.example /root/user-scripts/pre-start.sh
else
    echo "[INFO] 执行预启动脚本……"

    chmod +x /root/user-scripts/pre-start.sh
    source /root/user-scripts/pre-start.sh
fi ;


echo "########################################"
echo "[INFO] 启动 ComfyUI..."
echo "########################################"

# 显示workflow使用指南
if [ -f "/runner-scripts/show-workflow-info.sh" ]; then
    chmod +x /runner-scripts/show-workflow-info.sh
    bash /runner-scripts/show-workflow-info.sh
fi

# 使得 .pyc 缓存文件集中保存
export PYTHONPYCACHEPREFIX="/root/.cache/pycache"
# 使得 PIP 安装新包到 /root/.local
export PIP_USER=true
# 添加上述路径到 PATH
export PATH="${PATH}:/root/.local/bin"
# 不再显示警报 [WARNING: Running pip as the 'root' user]
export PIP_ROOT_USER_ACTION=ignore

cd /root

python3 ./ComfyUI/main.py --listen --port 8188 ${CLI_ARGS}
